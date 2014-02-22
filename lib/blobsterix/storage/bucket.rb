module Blobsterix
	module Storage
		class Bucket
			attr_accessor :name, :creation_date, :contents
			def initialize(name, date)
				@name = name
				@creation_date = date
				@contents = []
				yield self if block_given?
			end
			def to_xml()
				date = Date.today
				xml = Nokogiri::XML::Builder.new do |xml|
						xml.ListBucketResult(:xmlns => "http://doc.s3.amazonaws.com/#{date.year}-#{date.month}-#{date.day}") {
							xml.Name name
							xml.Prefix
							xml.Marker
							xml.MaxKeys 1000
							xml.IsTruncated false
								contents.each{|entry|
									entry.insert_xml(xml)
								}
						}

				end
				xml.to_xml
			end
			def insert_xml(xml)
				xml.Bucket{
					xml.Name name
					xml.CreationDate creation_date
				}
			end
		end
	end
end