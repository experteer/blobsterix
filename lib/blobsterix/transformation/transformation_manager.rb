module BlobServer::Transformations
	class TransformationManager
		def initialize()
			@transformations = []
			@running_transformations = {}
			auto_load
		end
		def add(trafo)
			transformation = (trafo.is_a?(String) ? ::BlobServer::Transformations::Impl::const_get(trafo).new : trafo)
			@transformations << transformation if @transformations.select{|trafo|trafo.name === transformation.name}.empty?
			self
		end
		def run(input)
			return BlobServer::Storage::BlobMetaData.new if not prepare_input(input)

			preferred_key = input[:target] || cache_key(input[:bucket], input[:id], input[:trafo], input[:type])

			if @running_transformations.has_key?(preferred_key)
				@running_transformations[preferred_key] << Fiber.current
				puts "Transformation exists wait for it to finish"
				Fiber.yield
			end

			return BlobServer.cache.get(preferred_key) if BlobServer.cache.exists?(preferred_key)

			@running_transformations[preferred_key] = [Fiber.current]

			EM.defer(Proc.new {
				run_transformation(preferred_key, input)
			}, Proc.new {
				finish_connection(preferred_key)
			})

			Fiber.yield

			#puts "Finish connection: #{Fiber.current.id}"
			
			BlobServer.cache.exists?(preferred_key) ? BlobServer.cache.get(preferred_key) : BlobServer::Storage::BlobMetaData.new
		end
		def cache_key(bucket, id, trafo, accept_type)
			puts "Calc cache key[#{trafo}]"
			key = "#{bucket}_#{id.gsub("/","_")}_#{trafo.map {|trafo_pair|"#{trafo_pair[0]}_#{trafo_pair[1]}"}.join(",")}.#{accept_type.subtype}"
			puts "Done calc cache key"
			key
		end
		private
			def auto_load()
				BlobServer::Transformations::Impl.constants.each{|c|
					add(c.to_s)
				}
			end
			def get_original_file(bucket, id)
				key = [bucket, id.gsub("/", "_")].join("_")
				if not BlobServer.cache.exists?(key)
					metaData = BlobServer.storage.get(bucket, id)
					BlobServer.cache.put(key, metaData.data) if metaData.valid
				end
				BlobServer.cache.get(key)
			end
			def run_transformation(preferred_key, input)
				puts "Load: #{input[:bucket]}, #{input[:id]}"

				metaData = input[:source] || get_original_file(input[:bucket], input[:id])

				if metaData.valid
					chain = TransformationChain.new(preferred_key, metaData)
					input[:trafo].each {|trafo_pair|
						chain.add(findTransformation(trafo_pair[0], chain.last_type), trafo_pair[1])
					}
					chain.finish(input[:type], findTransformation_out(chain.last_type, input[:type]))

					chain.do()
				end
			end
			def finish_connection(preferred_key)
				@running_transformations[preferred_key].each{|fiber|
					fiber.resume
				}
				@running_transformations.delete(preferred_key)
			end
			def findTransformation(name, input_type)
				#puts "find trafo: #{name}, #{input_type.inspect}"
				trafos = @transformations.select{|trafo| trafo.name === name and trafo.input_type.is?(input_type)}
				trafos.empty? ? nil : trafos[0]
			end
			def findTransformation_out(input_type, output_type)
				#puts "find trafo: #{input_type.inspect}, #{output_type.inspect}"
				trafos = @transformations.select{|trafo| 
					#puts "Check trafo: #{trafo.inspect}"
					trafo.input_type.is?(input_type) and trafo.output_type.equal?(output_type)
				}
				trafos.empty? ? nil : trafos[0]
			end

			def prepare_input(input)
				if input[:trafo].is_a?(String)
					trafo = []

					input[:trafo].split(",").each{|command|
						parts = command.split("_")
						key = parts.delete_at(0)
						trafo << [key, parts.join("_")]
					}
					input[:trafo] = trafo
				end

				input[:type] = BlobServer::AcceptType.new(input[:type]) if input[:type].is_a?(String) or input[:type].is_a?(Array)
				true
			end
	end
end