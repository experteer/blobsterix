module BlobServer
	module Storage
		class FileSystemMetaData < BlobMetaData
			def initialize(base, key)
				puts "New MetaData for #{key}"
				@base = base
				@key = key
				@last_modified = ""
			end
			def check(key)
				@key === key
			end
			def etag()
				if @last_modified === last_modified
					@etag ||= Digest::MD5.hexdigest(data)
				else
					@last_modified = last_modified
					@etag = Digest::MD5.hexdigest(data)
				end
			end
			def mimetype()
				(@mimetype ||= get_mime).type
			end
			def mediatype()
				(@mediatype ||= get_mime).mediatype
			end
			def data()
				#puts "Do a file read"
				File.exists?(File.join(@base, @key)) ? File.read(File.join(@base, @key)) : ""
			end
			def path()
				File.join(@base, @key)
			end
			def size()
				File.exists?(File.join(@base, @key)) ? File.join(@base, @key).size : 0
			end
			def last_modified()
				File.ctime(File.join(@base, @key)).strftime("%Y-%m-%dT%H:%M:%S.000Z")
			end
			def header()
				{"Etag" => etag, "Content-Type" => mimetype, "Last-Modified" => last_modified, "Cache-Control" => "max-age=#{60*60*24}", "Expires" => (Time.new+(60*60*24)).strftime("%Y-%m-%dT%H:%M:%S.000Z")}
			end
			def valid()
				File.exists?(File.join(@base, @key))
			end

			private
				def get_mime()
					#puts "mime for #{File.join(@base, @key)}"
					@mimeclass ||= (MimeMagic.by_magic(File.open(File.join(@base, @key))) if File.exists?(File.join(@base, @key)) )|| MimeMagic.new("text/plain")
				end
		end
	end
end