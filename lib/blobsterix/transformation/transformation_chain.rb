module Blobsterix::Transformations
	class TransformationChain
		attr_reader :logger
		def initialize(key, input_data, logger)
			@key = key
			@input_data = input_data
			@transformations = []
			@logger = logger
		end

		def cache
			@cache ||= Blobsterix.cache
		end

		def cache_key()
			@key
		end

		def last_type()
			return Blobsterix::AcceptType.new(@input_data.mimetype) if @transformations.empty?
			@transformations.last[0].output_type
		end

		def add(transfo, value)
			return if transfo == nil
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
				@transformations << [trafo, nil] if trafo != nil
			end
			@transformations << [Transformation.new(logger), nil] if @transformations.empty?
		end

		def file_path()
			@file_path ||= cache.path_prepare(cache_key)
		end
	end
end