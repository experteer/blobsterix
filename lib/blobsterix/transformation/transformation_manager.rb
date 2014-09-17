module Blobsterix::Transformations
  # a TransormationManager cares about:
  class TransformationManager
    include Blobsterix::Logable

    def initialize
      auto_load
    end

    def add(trafo)
      transformation = (trafo.is_a?(String) ? ::Blobsterix::Transformations::Impl.const_get(trafo).new : trafo)
      transformations << transformation if transformations.select { |trafo|trafo.name === transformation.name }.empty?
      self
    end

    def run(blob_access)
      blob_access = wait_for_transformation(blob_access) if transformation_in_progress?(blob_access)

      return blob_access.get if blob_access.get.valid

      cue_transformation(blob_access)

      blob_access = run_transformation(blob_access)

      blob_access.get.valid ? blob_access.get : Blobsterix::Storage::BlobMetaData.new
    end

    private

    def running_transformations
      @running_transformations ||= {}
    end

    def transformations
      @transformations ||= []
    end

    def wait_for_transformation(blob_access)
      running_transformations[blob_access.identifier] << Fiber.current
      logger.debug "Transformation: wait for it to finish #{blob_access}"
      Fiber.yield
    end

    def cue_transformation(blob_access)
      running_transformations[blob_access.identifier] = [Fiber.current]
      blob_access
    end

    def uncue_transformation(blob_access)
      running_transformations.delete(blob_access.identifier)
      blob_access
    end

    def transformation_in_progress?(blob_access)
      running = running_transformations.key?(blob_access.identifier)
      running
    end

    def auto_load
      Blobsterix::Transformations::Impl.constants.each do|c|
        add(c.to_s)
      end
    end

    def run_transformation(blob_access)
      logger.debug "Transformation: build #{blob_access}"

      metaData = blob_access.source || Blobsterix::BlobAccess.new(:bucket => blob_access.bucket, :id => blob_access.id).get

      return uncue_transformation(blob_access) unless metaData.valid

      chain = TransformationChain.new(blob_access, metaData, logger)

      blob_access.trafo.each do|trafo_pair|
        chain.add(findTransformation(trafo_pair[0], chain.last_type), trafo_pair[1])
      end

      chain.finish(blob_access.accept_type, findTransformation_out(chain.last_type, blob_access.accept_type))

      if chain.target_blob_access.get.valid
        uncue_transformation(blob_access)
        chain.target_blob_access
      else
        logger.debug "Transformation: run #{blob_access}"
        EM.defer(proc do
          begin
            chain.do
          rescue => e
            e
          end
        end, proc do|result|
          finish_connection(result, blob_access)
        end)

        result = Fiber.yield
        fail result if result.is_a? Exception
        result
      end
    end

    def finish_connection(result, blob_access)
      logger.debug "Transformation: done #{blob_access} finish connections"
      running_transformations[blob_access.identifier].each do|fiber|
        fiber.resume(result)
      end
      uncue_transformation(blob_access)
    end

    def findTransformation(name, input_type)
      trafos = transformations.select { |trafo| trafo.name === name && trafo.input_type.is?(input_type) }
      trafos.empty? ? nil : trafos[0]
    end

    def findTransformation_out(input_type, output_type)
      trafos = transformations.select do|trafo|
        trafo.input_type.is?(input_type) && trafo.output_type.equal?(output_type)
      end
      trafos.empty? ? nil : trafos[0]
    end
  end
end
