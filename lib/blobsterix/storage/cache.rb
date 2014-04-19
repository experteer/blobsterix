module Blobsterix
  module Storage
    class Cache
      include Blobsterix::Logable

      def invalidation
        each_meta_file do |meta_file|
          blob_access=meta_to_blob_access(meta_file)
          if Blobsterix.cache_checker.call(blob_access,meta_file.last_accessed,meta_file.last_modified)
            invalidate(blob_access, true)
          end
        end
      end
      def initialize(path)
        @path = Pathname.new(path)
        FileUtils.mkdir_p(@path) if !Dir.exist?(@path)
      end

      def get(blob_access)
        FileSystemMetaData.new(cache_file_path(blob_access))
      end

      def put(blob_access, data)
        FileSystemMetaData.new(cache_file_path(blob_access),:bucket => blob_access.bucket, :id => blob_access.id, :trafo => blob_access.trafo, :accept_type => "#{blob_access.accept_type}").write() {|f|
          f.write(data)
        }
      end

      def delete(blob_access)
        FileSystemMetaData.new(cache_file_path(blob_access)).delete if exists?(blob_access)
      end

      def exists?(blob_access)
        valid = File.exist?(cache_file_path(blob_access))
        valid ? Blobsterix.cache_hit(blob_access) : Blobsterix.cache_miss(blob_access)
        valid
      end

      #invalidates all!!! formats of a blob_access
      def invalidate(blob_access, delete_single=false)
        if delete_single
          FileSystemMetaData.new(cache_file_path(blob_access)).delete
        else
          cache_path(blob_access).entries.each {|cache_file|
            unless cache_file.to_s.match(/\.meta$/) || cache_file.directory?
              FileSystemMetaData.new(cache_path(blob_access).join(cache_file)).delete if cache_file.to_s.match(cache_file_name(blob_access))
            end
          } if Dir.exist?(cache_path(blob_access))
        end
      end

      private

      def each_meta_file
        Dir.glob(@path.join("**/*")).each {|file|
          cache_file = Pathname.new file
          if block_given? && !cache_file.to_s.match(/\.meta$/) && !cache_file.directory?
            yield FileSystemMetaData.new(cache_file)
            cache_file
          end
        }
      end

      def meta_to_blob_access(meta_file)
        BlobAccess.new(:bucket => meta_file.payload["bucket"], :id => meta_file.payload["id"], :trafo => meta_file.payload["trafo"], :accept_type => AcceptType.new(meta_file.payload["accept_type"]||""))
      end

      def cache_file_path(blob_access)
        cache_path(blob_access).join(cache_file_name(blob_access))
      end

      def cache_file_name(blob_access)
        Murmur.Hash64B(blob_access.identifier)
      end

      def cache_path(blob_access)
        @path.join(hash_filename("#{blob_access.bucket}_#{blob_access.id.gsub("/","_")}"))
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
