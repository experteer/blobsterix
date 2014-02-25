require 'fileutils'

module Blobsterix
  module Storage
    class Distributor < Storage
      include Blobsterix::Logable

      def initialize(*paths)
        @storages = paths.map{|path| FileSystem.new(path) }
        @local_storage = @storages[0]
      end

      def list(bucket="root")
        @local_storage.list(bucket)
      end

      def bucket_exist(bucket="root")
        @local_storage.bucket_exist(bucket)
      end

      def get(bucket, key)
        @storages.each {|storage|
          metaData = storage.get(bucket, key)
          copy_to_local(bucket, key, metaData) if not_local(storage) and metaData.valid
          return metaData if metaData.valid
        }
        Blobsterix::Storage::BlobMetaData.new
      end

      def put(bucket, key, value)
        result = nil
        @storages.each {|storage|
          r = storage.put(bucket, key, value)
          result = r if !not_local(storage)
        }
        result
      end

      def create(bucket)
        result = nil
        @storages.each {|storage|
          r = storage.create(bucket)
          result = r if !not_local(storage)
        }
        result
      end

      def delete(bucket)
        @local_storage.delete(bucket)
      end

      def delete_key(bucket, key)
        @local_storage.delete_key(bucket, key)
      end

      private
        def copy_to_local(bucket, key, metaData)
          @local_storage.put(bucket, key, metaData)
        end
        def not_local(storage)
          storage != @local_storage
        end
    end
end