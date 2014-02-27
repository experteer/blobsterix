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
        FileSystemMetaData.new(cache_path(blob_access))
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
        valid ? Blobsterix.cache_hit(blob_access) : Blobsterix.cache_miss(blob_access)
        valid
			end

			private

      def cache_path(blob_access)
        File.join(@path, hash_filename("#{blob_access.bucket}_#{blob_access.id.gsub("/","_")}"), blob_access.identifier) 
      end

      #invalidates all!!! formats of a blob_access
			def invalidate(blob_access, all=false)
			end

      def hash_filename(filename)
        hash = Murmur.Hash64B(filename)
        bits =  hash.to_s(2)
        parts = []
        6.times { |index|
          len = 11
          len = bits.length if len >= bits.length
          value = bits.slice!(0, len).to_i(2).to_s(16).rjust(3,"0")
          parts.push(value)
        }
        parts.join("/")
      end
		end
	end
end