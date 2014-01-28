module BlobServer
	module Storage
		class Cache
			def initialize(path="../cache")
				@path = path
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
				FileSystemMetaData.new(path, Murmur.map_filename(key))
			end
			def put(key, data)
				File.open(path_prepare(key), "wb") {|f|
					f.write(data)
				}
			end
			def delete(key)
				File.delete(path(key)) if exists?(key)
			end
			def exists?(key)
				File.exist?(path(key))
			end
		end
	end
end