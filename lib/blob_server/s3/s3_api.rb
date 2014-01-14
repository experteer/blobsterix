module BlobServer
	class S3Api < AppRouterBase
		extend S3UrlHelper

		get "/", lambda{|env|
			Http.OK BlobServer.storage.list(bucket(env)).to_xml, "xml"
		}
		get "/*bucket_or_file.:format", lambda{|env|
			return Http.NotFound if favicon(env)

			if bucket?(env)
				if meta = BlobServer.storage.get(bucket(env), file(env))
					meta.response
				else
					Http.NotFound
				end
			else
				Http.OK BlobServer.storage.list(bucket(env)).to_xml, "xml"
			end
		}
		get "/*bucket_or_file", lambda{|env|
			return [404, {}, ""] if favicon(env)

			if bucket?(env)
				if meta = BlobServer.storage.get(bucket(env), file(env))
					meta.response
				else
					Http.NotFound
				end
			else
				Http.OK BlobServer.storage.list(bucket(env)).to_xml, "xml"
			end
		}
		head "/*bucket_or_file.:format", lambda{|env|
			return Http.NotFound if favicon(env)
			puts "S3 head"

			if bucket?(env)
				if meta = BlobServer.storage.get(bucket(env), file(env))
					meta.response(false)
				else
					Http.NotFound
				end
			else
				Http.OK BlobServer.storage.list(bucket(env)).to_xml, "xml"
			end
		}
		head "/*bucket_or_file", lambda{|env|
			return [404, {}, ""] if favicon(env)
			puts "S3 head"

			if bucket?(env)
				if meta = BlobServer.storage.get(bucket(env), file(env))
					meta.response(false)
				else
					Http.NotFound
				end
			else
				Http.OK BlobServer.storage.list(bucket(env)).to_xml, "xml"
			end
		}

		put "/", lambda{|env|
			Http.OK BlobServer.storage.create(bucket(env)), "xml"
		}
		put "/*file.:format", lambda{|env|
			upload_data(env)
		}
		put "/*file", lambda{|env|
			upload_data(env)
		}

		delete "/", lambda{|env|
			if bucket?(env)
				Http.OK_no_data BlobServer.storage.delete(bucket(env)), "xml"
			else
				Http.NotFound "no such bucket"
			end
		}

		delete "/*file.:format", lambda{|env|
			if bucket?(env)
				Http.OK_no_data BlobServer.storage.delete_key(bucket(env), file(env)), "xml"
			else
				Http.NotFound "no such bucket"
			end
		}

		delete "/*file", lambda{|env|
			if bucket?(env)
				Http.OK_no_data BlobServer.storage.delete_key(bucket(env), file(env)), "xml"
			else
				Http.NotFound "no such bucket"
			end
		}
	end
end