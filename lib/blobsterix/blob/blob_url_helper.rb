module Blobsterix
	module BlobUrlHelper
		HOST_PATH = /(\w+)(\.s3)?\.\w+\.\w+/
		def bucket_matcher(str)
			if str.include?("s3")
				str.match(/(\w+)\.s3\.\w+\.\w+/)
			else
				str.match(/(\w+)\.\w+\.\w+/)
			end
		end
		def favicon
			@favicon ||= file.match /favicon/
		end
		def bucket
			host = bucket_matcher(env['HTTP_HOST'])
			if host
				env[nil][:bucket] = host[1]
			elsif  (env[nil] && env[nil][:bucket])
				env[nil][:bucket]
			elsif included_bucket
				env[nil][:bucket]
			else
				"root"
			end
		end
		def bucket?
			host = bucket_matcher(env['HTTP_HOST'])
			host || env[nil][:bucket] || included_bucket
		end
		def format
			@format ||= env[nil][:format]
		end
		def included_bucket
			if env[nil][:bucket_or_file] && env[nil][:bucket_or_file].include?("/")
				env[nil][:bucket] = env[nil][:bucket_or_file].split("/")[0]
				env[nil][:bucket_or_file] = env[nil][:bucket_or_file].gsub("#{env[nil][:bucket]}/", "")
				true
			else
				false
			end
		end
		def file
			if format
				[env[nil][:file] || env[nil][:bucket_or_file] || "", format].join(".")
			else
				env[nil][:file] || env[nil][:bucket_or_file] || ""
			end
		end
	end
end