module Blobsterix
  module Storage
    class Storage
      def list(_bucket = "root", _opts = {})
        Nokogiri::XML::Builder.new do |xml|
          xml.Error "no such bucket"
        end
      end

      def bucket_exist(_bucket = "root")
        false
      end

      def get(_bucket, _key)
        Blobsterix::Storage::BlobMetaData.new
      end

      def put(_bucket, _key, _value, _opts = {})
        Blobsterix::Storage::BlobMetaData.new
      end

      def create(_bucket)
        Nokogiri::XML::Builder.new do |_xml|
        end
      end

      def delete(_bucket)
        nil
      end

      def delete_key(_bucket, _key)
        nil
      end
    end
  end
end
