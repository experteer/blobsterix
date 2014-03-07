module Blobsterix::Transformations
	#a TransormationManager cares about:
	class TransformationManager
		include Blobsterix::Logable

		def initialize()
			auto_load
		end

		def storage
			@storage ||= Blobsterix.storage
		end

		def cache
			@cache ||= Blobsterix.cache
		end

		def add(trafo)
			transformation = (trafo.is_a?(String) ? ::Blobsterix::Transformations::Impl::const_get(trafo).new : trafo)
			transformations << transformation if transformations.select{|trafo|trafo.name === transformation.name}.empty?
			self
		end

		def run(blob_access)

			wait_for_transformation(blob_access) if transformation_in_progress?(blob_access)

			return cache.get(blob_access) if cache.exists?(blob_access)

			cue_transformation(blob_access)

			EM.defer(Proc.new {
				run_transformation(blob_access)
			}, Proc.new {
				finish_connection(blob_access.identifier)
			})

			Fiber.yield
			
			cache.exists?(blob_access) ? cache.get(blob_access) : Blobsterix::Storage::BlobMetaData.new
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
			end

			def transformation_in_progress?(blob_access)
				running_transformations.has_key?(blob_access.identifier)
			end

			def auto_load()
				Blobsterix::Transformations::Impl.constants.each{|c|
					add(c.to_s)
				}
			end

			def get_original_file(blob_access)
				blob_access_original=Blobsterix::BlobAccess.new(:bucket => blob_access.bucket,:id => blob_access.id)
				unless cache.exists?(blob_access_original)
					metaData = storage.get(blob_access.bucket, blob_access.id)
					cache.put(blob_access_original, metaData.data) if metaData.valid
				end
				cache.get(blob_access_original)
			end

			def run_transformation(blob_access)
				logger.debug "Transforamtion: load #{blob_access}"

				metaData = blob_access.source || get_original_file(blob_access)

				if metaData.valid
					chain = TransformationChain.new(blob_access, metaData, logger)
					blob_access.trafo.each {|trafo_pair|
						chain.add(findTransformation(trafo_pair[0], chain.last_type), trafo_pair[1])
					}
					chain.finish(blob_access.accept_type, findTransformation_out(chain.last_type, blob_access.accept_type))

					chain.do(cache)
				end
			end

			def finish_connection(preferred_key)
				running_transformations[preferred_key].each{|fiber|
					fiber.resume
				}
				running_transformations.delete(preferred_key)
			end

			def findTransformation(name, input_type)
				trafos = transformations.select{|trafo| trafo.name === name and trafo.input_type.is?(input_type)}
				trafos.empty? ? nil : trafos[0]
			end

			def findTransformation_out(input_type, output_type)
				trafos = transformations.select{|trafo|
					trafo.input_type.is?(input_type) and trafo.output_type.equal?(output_type)
				}
				trafos.empty? ? nil : trafos[0]
			end
	end
end