module BlobServer::Transformations
	class TransformationChain
		def initialize(key, input_data)
			@key = key
			@input_data = input_data
			@transformations = []
		end

		def cache_key()
			@key
		end

		def last_type()
			return BlobServer::AcceptType.new(@input_data.mimetype) if @transformations.empty?
			@transformations.last[0].output_type
		end

		def add(transfo, value)
			return if transfo == nil
			#puts "added transformation"
			@transformations << [transfo, value]
		end

		def do()
			tmpFiles = (@transformations.size-1).times.map{|index|
				Tempfile.new("#{cache_key}_#{index}")
			}
			keys = tmpFiles.map{|f| f.path }
			keys <<  file_path
			last_key = "#{@input_data.path}"


			@transformations.each{|trafo|
				new_key = keys.delete_at(0)
				trafo[0].transform(last_key, new_key, trafo[1])
				last_key = new_key
			}

			tmpFiles.each { |f|
				f.close
				f.unlink
			}
		end

		def finish(accept_type, trafo)
			if @transformations.empty? or (not @transformations.last[0].output_type.equal?(accept_type) and not @transformations.last[0].is_format?)
				#puts "Trafos: #{@transformations}"
				@transformations << [trafo, nil] if trafo != nil
			end
			@transformations << [Transformation.new, nil] if @transformations.empty?
		end

		def file_path()
			@file_path ||= BlobServer.cache.path_prepare(cache_key)
		end
	end
end