module BlobServer
	module Storage
		class BucketList
			attr_accessor :buckets

			def initialize()
				@buckets = []
				yield self if block_given?
			end

			def to_xml()
				date = Date.today
				xml = Nokogiri::XML::Builder.new do |xml|
					xml.ListAllMyBucketsResult(:xmlns => "http://doc.s3.amazonaws.com/#{date.year}-#{date.month}-#{date.day}") {
						xml.Buckets {
							buckets.each{|entry|
								entry.insert_xml(xml)
							}
						}
					}
				end
				xml.to_xml
			end
		end
	end
end