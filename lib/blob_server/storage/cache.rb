module BlobServer
	module Storage
		class Cache
			def initialize(path="../cache")
				@path = path
				@metaData = {}
			end
			def path()
				@path
			end
			def get(key)
				@metaData[key] ||= FileSystemMetaData.new(path, key)
			end
			def put(key, data)
				FileUtils.mkdir_p(File.dirname(File.join(path, key)))
				File.open(File.join(path, key), "wb") {|f|
					f.write(data)
				}
			end
			def delete(key)
				File.delete(File.join(path, key)) if exists?(key)
			end
			def exists?(key)
				File.exist?(File.join(path, key))
			end
		end
	end
end