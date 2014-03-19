module Blobsterix
	module Storage
		class FileSystemMetaData < BlobMetaData
		include Blobsterix::Logable

			def initialize(path_, payload={})
				@payload=payload
				@path = path_
				@last_modified = ""
				load_meta_file
			end

			def to_s
				@path
			end

			def check(key)
				@key === key
			end

			def etag
				if @last_modified === last_modified
					@etag ||= Digest::MD5.hexdigest(data)
				else
					@last_modified = last_modified
					@etag = Digest::MD5.hexdigest(data)
				end
			end

			def mimetype
				(@mimetype ||= get_mime.type)
			end

			def mediatype
				(@mediatype ||= get_mime.mediatype)
			end

			def data
				# begin
				# 	raise StandardError.new
				# rescue StandardError => e
				# 	puts "VERY EXPENSIVE FILE READ"
				# 	puts e.backtrace
				# end
				# logger.info "VERY EXPENSIVE FILE READ"
				File.exists?(path) ? File.read(path) : ""
			end

			def path
				@path
			end

			def size
				@size ||= File.exists?(path) ? File.size(path) : 0
			end

			def last_modified
				File.ctime(path)#.strftime("%Y-%m-%dT%H:%M:%S.000Z")
			end

			def last_accessed
				File.atime(path)#.strftime("%Y-%m-%dT%H:%M:%S.000Z")
			end

			def accept_type
				@accept_type ||= AcceptType.new(get_mime().to_s)
			end

			def header()
				{"Etag" => etag, "Content-Type" => mimetype, "Last-Modified" => last_modified.strftime("%Y-%m-%dT%H:%M:%S.000Z"), "Cache-Control" => "max-age=#{60*60*24}", "Expires" => (Time.new+(60*60*24)).strftime("%Y-%m-%dT%H:%M:%S.000Z")}
			end

			def valid
				File.exists?(path)
			end

			def payload
				@payload
			end

			def write
				if block_given?
					FileUtils.mkdir_p(File.dirname(path))
					delete
					f = File.open(path, "wb")
					yield f
					f.close
				end
				save_meta_file
				self
			end

			def delete
				File.delete(meta_path) if File.exists?(meta_path)
				File.delete(path) if valid
			end

			def to_json
        as_json.to_json
	    end

	    def as_json
	    	{'mimetype' => mimetype, 'mediatype' => mediatype, 'etag' => etag, 'size' => size,'payload' => @payload.to_json}
	    end

			private
				def meta_path
					@meta_path ||= "#{path}.meta"
				end

				def get_mime
					@mimeclass ||= (MimeMagic.by_magic(File.open(path)) if File.exists?(path) )|| MimeMagic.new("text/plain")
				end
				def save_meta_file
					return if not valid

					File.write(meta_path, to_json)
				end
				def load_meta_file
					return if not valid

					if not File.exists?(meta_path)
						save_meta_file
					else
						data = JSON.load File.read(meta_path)
						@mimetype = data["mimetype"]
						@mediatype = data["mediatype"]
						@etag = data["etag"]
						@size = data["size"]
						@payload = JSON.load(data["payload"]) || {}
						@mimeclass = MimeMagic.new(@mimetype)
					end
				end
		end
	end
end