module BlobServer
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