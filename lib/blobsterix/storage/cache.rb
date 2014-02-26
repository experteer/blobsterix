module Blobsterix
	module Storage
		class Cache
      include Blobsterix::Logable

      def invalidation
      	each_meta_file do |meta_file|
      		blob_access=meta_to_blob_access(meta_file)
      		if Blobsterix.cache_checker.call blob_access,accessed_at,created_at
             invalidate(blob_access)
      		end
      	end
      end
			def initialize(path)
				@path = path
			end

			def get(blob_access)
        begin
          raise StandardError.new
        rescue StandardError => e
          puts e.backtrace
        end
				meta = FileSystemMetaData.new(cache_path(blob_access))
        meta.valid ? logger.info("Cache: hit #{blob_access}") : logger.info("Cache: miss #{blob_access}")
        meta
			end

			def put(blob_access, data)
				invalidate(blob_access,true)
				FileSystemMetaData.new(cache_path(blob_access),:bucket => blob_access.bucket, :id => blob_access.id, :trafo => blob_access.trafo, :accept_type => "#{blob_access.accept_type}").write() {|f|
					f.write(data)
				}
			end

			def delete(blob_access)
				invalidate(blob_access,true)
				FileSystemMetaData.new(cache_path(blob_access)).delete if exists?(blob_access)
			end

			def exists?(blob_access)
				valid = File.exist?(cache_path(blob_access))
        valid ? logger.info("Cache: hit #{blob_access}") : logger.info("Cache: miss #{blob_access}")
        valid
			end

			private

      def cache_path(blob_access)
        File.join(@path, Murmur.hash_filename("#{blob_access.bucket}_#{blob_access.id.gsub("/","_")}"), blob_access.identifier) 
      end

      #invalidates all!!! formats of a blob_access
			def invalidate(blob_access, all=false)
			end
		end
	end
end