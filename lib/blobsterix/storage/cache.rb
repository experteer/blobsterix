module Blobsterix
  module Storage
    class Cache
      include Blobsterix::Logable

      def invalidation
        each_meta_file do |meta_file|
          blob_access = Blobsterix::SimpleProxy.new(proc do
            meta_to_blob_access(FileSystemMetaData.new(meta_file))
          end)
          if Blobsterix.cache_checker.call(blob_access, File.atime(meta_file), File.ctime(meta_file))
            invalidate(blob_access, true)
          end
        end
      end

      def initialize(path)
        @path = Pathname.new(path)
        FileUtils.mkdir_p(@path) unless Dir.exist?(@path)
        FileUtils.touch File.join(@path, ".keep")
      end

      def get(blob_access)
        FileSystemMetaData.new(cache_file_path(blob_access))
      end

      def put_raw(blob_access, data)
        FileSystemMetaData.new(cache_file_path(blob_access), :bucket => blob_access.bucket, :id => blob_access.id, :trafo => blob_access.trafo, :accept_type => "#{blob_access.accept_type}").write do|f|
          f.write(data)
        end
      end

      def put_stream(blob_access, stream)
        FileSystemMetaData.new(cache_file_path(blob_access), :bucket => blob_access.bucket, :id => blob_access.id, :trafo => blob_access.trafo, :accept_type => "#{blob_access.accept_type}").write do |f|
          FileUtils.copy_stream(stream, f)
        end
      end

      def put(blob_access, path)
        target_path = cache_file_path(blob_access)
        FileUtils.mkdir_p(File.dirname(target_path))
        FileUtils.cp(path, target_path, :preserve => false)
        FileSystemMetaData.new(target_path, :bucket => blob_access.bucket, :id => blob_access.id, :trafo => blob_access.trafo, :accept_type => "#{blob_access.accept_type}")
      end

      def delete(blob_access)
        FileSystemMetaData.new(cache_file_path(blob_access)).delete if exists?(blob_access)
      end

      def exists?(blob_access)
        valid = File.exist?(cache_file_path(blob_access))
        valid ? Blobsterix.cache_hit(blob_access) : Blobsterix.cache_miss(blob_access)
        valid
      end

      # invalidates all!!! formats of a blob_access
      def invalidate(blob_access, delete_single = false)
        if delete_single
          FileSystemMetaData.new(cache_file_path(blob_access)).delete
        else
          cache_path(blob_access).entries.each do|cache_file|
            unless cache_file.to_s.match(/\.meta$/) || cache_file.directory?
              base_name = cache_file.to_s
              FileSystemMetaData.new(cache_path(blob_access).join(cache_file)).delete if base_name.match(cache_file_base(blob_access))
            end
          end if Dir.exist?(cache_path(blob_access))
        end
      end

      private

      def each_meta_file
        Blobsterix::DirectoryList.each(@path) do|file_path, file|
          cache_file = file_path.join file
          if block_given? && !cache_file.to_s.match(/\.meta$/)
            yield cache_file
            cache_file
          end
        end
      end

      def meta_to_blob_access(meta_file)
        BlobAccess.new(:bucket => meta_file.payload["bucket"], :id => meta_file.payload["id"], :trafo => meta_file.payload["trafo"], :accept_type => AcceptType.new(meta_file.payload["accept_type"] || ""))
      end

      def cache_file_path(blob_access)
        cache_path(blob_access).join(cache_file_name(blob_access))
      end

      def cache_file_name(blob_access)
        [cache_file_base(blob_access), Murmur.Hash64B(blob_access.identifier).to_s].join("_")
      end

      def cache_file_base(blob_access)
        "#{blob_access.bucket}_#{blob_access.id.gsub("/", "_")}"
      end

      def cache_path(blob_access)
        @path.join(hash_filename(cache_file_base(blob_access)))
      end

      def hash_filename(filename)
        Murmur.map_filename(filename)
      end
    end
  end
end
