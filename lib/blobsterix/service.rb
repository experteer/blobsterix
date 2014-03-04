module Blobsterix
	class Service < Goliath::API
		use Goliath::Rack::Params
=begin
		def on_headers(env, headers)
			env.logger.info 'received headers: ' + headers.inspect
		    env['async-headers'] = headers
		end

		def on_body(env, data)
			env.logger.info 'received data: ' + data
			(env['async-body'] ||= '') << data
		end

		def on_close(env)
			env.logger.info 'closing connection'
		end
=end
		def response(env)
			call_stack(env, BlobApi, StatusApi, S3Api)
		end

		def call_stack(env, *apis)
			last_answer = [404,{}, ""]
			apis.each do |api|
				last_answer = api.call(env)
				if last_answer[0] != 600
					return last_answer
				end
			end
			last_answer[0] != 600 ? last_answer : [404,{}, ""]
		end
	end
end
