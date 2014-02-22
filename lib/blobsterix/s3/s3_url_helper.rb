module Blobsterix
	module S3UrlHelper
		HOST_PATH = /(\w+)(\.s3)?\.\w+\.\w+/
		def bucket_matcher(str)
			if str.include?("s3")
				str.match(/(\w+)\.s3\.\w+\.\w+/)
			else
				str.match(/(\w+)\.\w+\.\w+/)
			end
		end
		def favicon(env)
			file(env).match /favicon/
		end
		def cache_upload(env)
			Blobsterix.cache.put(cache_upload_key(env), env['rack.input'].read)
		end
		def cached_upload(env)
			cache_upload(env) if not Blobsterix.cache.exists?(cache_upload_key(env))
			Blobsterix.cache.get(cache_upload_key(env))
		end
		def cached_upload_clear(env)
			Blobsterix.cache.delete(cache_upload_key(env))
		end
		def cache_upload_key(env)
			"upload/"+bucket(env).gsub("/", "_")+"_"+file(env).gsub("/", "_")
		end
		def trafo(env)
			env["HTTP_X_AMZ_META_TRAFO"] || ""
		end
		def upload_data(env)
			source = cached_upload(env)
			accept = source.accept_type()
			trafo = trafo(env)
			file = file(env)
			bucket = bucket(env)
			puts "Bucket: #{bucket} - File: #{file} - Accept: #{accept} - Trafo: #{trafo}"
			data = Blobsterix.transformation.run(:source => source, :bucket => bucket, :id => file, :type => accept, :trafo => trafo)
			cached_upload_clear(env)
			Blobsterix.storage.put(bucket, file, data).response(false)
		end
		def bucket(env)
			host = bucket_matcher(env['HTTP_HOST'])#.match(HOST_PATH)#/((\w+\.*)+)\.s3\.amazonaws\.com/)
			#puts "HOST: #{env['HTTP_HOST']}"
			if host
				host[1]
			elsif  (env[nil] && env[nil][:bucket])
				env[nil][:bucket]
			elsif  (env[nil] && env[nil][:bucket_or_file])
				if env[nil][:bucket_or_file].include?("/")
					env[nil][:bucket_or_file].split("/")[0]
				else
					env[nil][:bucket_or_file]
				end
			else
				"root"
			end
		end
		def bucket?(env)
			host = bucket_matcher(env['HTTP_HOST'])#.match(HOST_PATH)#/((\w+\.*)+)\.s3\.amazonaws\.com/)
			#puts "HOST: #{env['HTTP_HOST']}"
			host || env[nil][:bucket] || included_bucket(env)
		end
		def format(env)
			env[nil][:format]
		end
		def included_bucket(env)
			if env[nil][:bucket_or_file] && env[nil][:bucket_or_file].include?("/")
				env[nil][:bucket] = env[nil][:bucket_or_file].split("/")[0]
				env[nil][:bucket_or_file] = env[nil][:bucket_or_file].gsub("#{env[nil][:bucket]}/", "")
				true
			else
				false
			end
		end
		def file(env)
			if format(env)
				[env[nil][:file] || env[nil][:bucket_or_file] || "", format(env)].join(".")
			else
				env[nil][:file] || env[nil][:bucket_or_file] || ""
			end
		end
	end
end