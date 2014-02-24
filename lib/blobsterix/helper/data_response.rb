module Blobsterix
	module Http
		class DataResponse
			attr_reader :meta, :with_data, :etag, :env

			def initialize(_meta, _with_data=true, _etag=nil, _env = nil)
				@meta = _meta
				@with_data = _with_data
				@etag = _etag
				@env = _env
			end

			def call(xfile=false)
				if not meta.valid
					Http.NotFound()
				elsif xfile and etag != meta.etag
					[200, meta.header.merge({"X-Sendfile" => meta.path}), ""]
				elsif etag != meta.etag
					if env != nil and meta.size > 30000
						chunkresponse
					else
						[200, meta.header, (with_data ? meta.data : "")]
					end
				else
					[304, meta.header, ""]
				end
			end

			private
				def chunkresponse
					f = File.open(meta.path)
					EM.next_tick do
						send_chunk(f)
					end
					[200, meta.header, (with_data ? Goliath::Response::STREAMING : "")]
				end

				def send_chunk(file)
					dat = file.read(10000)
					again = if dat != nil
						env.stream_send(dat)
						true
					else
						file.close
						env.stream_close
						false
					end
					EM.next_tick do
						send_chunk(file)
					end if again
				end
		end
	end
end