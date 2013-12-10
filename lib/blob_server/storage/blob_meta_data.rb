module BlobServer
	module Storage
		class BlobMetaData
			def check(key)
				false
			end
			def etag()
				""
			end
			def data()
				""
			end
			def path()
				""
			end
			def last_modified()
			end
			def header()
				{}
			end
			def mimetype()
				"*/*"
			end
			def mediatype()
				"*"
			end
			def size()
				0
			end
			def valid()
				false
			end
			def response(with_data=true, _etag=nil, env = nil, xfile = false)
				BlobServer::Http::DataResponse.new(self, with_data, _etag, env).call(xfile)
			end
		end
	end
end