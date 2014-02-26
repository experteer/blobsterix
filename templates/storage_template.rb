module Blobsterix
  module Storage
    class $ClassNameStorage < Storage
      def list(bucket="root")
        Nokogiri::XML::Builder.new do |xml|
          xml.Error "no such bucket"
        end
      end
      def bucket_exist(bucket="root")
        false
      end
      def get(bucket, key)
        Blobsterix::Storage::BlobMetaData.new
      end
      def put(bucket, key, value)
        Blobsterix::Storage::BlobMetaData.new
      end
      def create(bucket)
        Nokogiri::XML::Builder.new do |xml|
        end
      end
      def delete(bucket)
        nil
      end
      def delete_key(bucket, key)
        nil
      end
    end
  end
end