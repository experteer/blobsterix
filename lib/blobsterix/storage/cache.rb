module Blobsterix
	module Storage
		class Cache
      include Blobsterix::Loggable


			def initialize(logger, path="../cache")
				@path = path
				@logger = logger
			end

			def path_prepare(key)
				p = path(key)
				FileUtils.mkdir_p(File.dirname(p))
				p
			end

			def path(key=nil)
				key ? File.join(@path, Murmur.map_filename(key)) : @path
			end

			def get(key)
				FileSystemMetaData.new(path(key))
			end

			def put(key, data)
				FileSystemMetaData.new(path(key)).write() {|f|
					f.write(data)
				}
			end

			def delete(key)
				FileSystemMetaData.new(path(key)).delete if exists?(key)
			end

			def exists?(key)
				File.exist?(path(key))
			end
		end
	end
end