module Blobsterix::Transformations
  class TransformationChain
    attr_reader :logger, :target_blob_access

    def initialize(blob_access, input_data, logger)
      @blob_access = blob_access
      @target_blob_access = nil
      @input_data = input_data
      @transformations = []
      @logger = logger
    end

    def cache
      @cache ||= Blobsterix.cache
    end

    def last_type
      return Blobsterix::AcceptType.new(@input_data.mimetype) if @transformations.empty?
      @transformations.last[0].output_type
    end

    def add(transfo, value)
      return if transfo.nil?
      @transformations << [transfo, value]
    end

    def do
      with_tempfiles do |keys|
        last_key = "#{@input_data.path}"

        begin
          current_transformation = nil
          @transformations.each do|trafo|

            current_transformation = trafo

            new_key = keys.delete_at(0)
            trafo[0].transform(last_key, new_key, trafo[1])
            last_key = new_key
          end
        rescue StandardError => e
          logger.error "Transformation: #{current_transformation} failed with #{e.message}"
          break
        end

        cache.put(@target_blob_access, last_key)
        @target_blob_access.reset!
      end unless @target_blob_access.get.valid

      @target_blob_access
    end

    def finish(accept_type, trafo)
      if @transformations.empty? || (!@transformations.last[0].output_type.equal?(accept_type) && !@transformations.last[0].is_format?)
        @transformations << [trafo, nil] if !trafo.nil? && trafo.is_format?
      end
      accept_type =  @transformations.empty? || !@transformations.last[0].is_format? ? nil : @transformations.last[0].output_type
      @target_blob_access = Blobsterix::BlobAccess.new(:bucket => @blob_access.bucket, :id => @blob_access.id, :trafo => @transformations.map { |trafo, value| [trafo.name, value] }, :accept_type => accept_type)
    end

    private

    def with_tempfiles
      tmpFiles = @transformations.size.times.map do|index|
        Tempfile.new("blobsterix_#{Thread.current.object_id}_#{index}")
      end
      keys = tmpFiles.map(&:path)

      yield keys

      tmpFiles.each do |f|
        f.close
        f.unlink
      end
    end
  end
end
