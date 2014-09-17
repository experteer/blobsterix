module Blobsterix
  module Storage
    class Bucket
      attr_accessor :name, :creation_date, :contents, :truncated, :next_marker, :marker
      def initialize(name, date)
        @name = name
        @creation_date = date
        @contents = []
        @truncated = false
        yield self if block_given?
      end

      def to_xml
        date = Date.today
        xml = Nokogiri::XML::Builder.new do |xml|
          xml.ListBucketResult(:xmlns => "http://doc.s3.amazonaws.com/#{date.year}-#{date.month}-#{date.day}") do
            xml.Name name
            xml.Prefix
            xml.Marker marker
            xml.NextMarker next_marker
            xml.MaxKeys 1000
            xml.KeyCount contents.length
            xml.IsTruncated truncated
            contents.each do|entry|
              entry.insert_xml(xml)
            end
          end

        end
        xml.to_xml
      end

      def insert_xml(xml)
        xml.Bucket do
          xml.Name name
          xml.CreationDate creation_date
        end
      end
    end
  end
end
