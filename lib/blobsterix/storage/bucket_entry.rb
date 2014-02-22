module Blobsterix
	module Storage
		class BucketEntry
			attr_accessor :key, :last_modified, :etag, :size, :storage_class, :mimetype, :fullpath
			def initialize(key)
				@key = key
				@last_modified = "2009-10-12T17:50:30.000Z"
				@etag = "&quot;fba9dede5f27731c9771645a39863328&quot;"
				@size = "0"
				@storage_class = "STANDARD"
				@mimetype = "none"
				@fullpath = ""
				yield self if block_given?
			end

			def insert_xml(xml)
				xml.Contents{
					xml.Key key
					xml.LastModified last_modified
					xml.ETag etag
					xml.Size size
					xml.StorageClass storage_class
					xml.MimeType mimetype
					xml.FullPath fullpath
				}
			end
		end
	end
end