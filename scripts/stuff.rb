	class Blah
		def call(env)
			#puts env[nil]
			#binding.pry
			#etag, body = BlobServer.storage.get(env[nil][:bucket], [env[nil][:key], env[nil][:format].to_s].join("."))
			#header "ETAG", etag
			[200, {}, env[nil]]
		end
	end
	class Route
		#include Goliath::Rack::AsyncMiddleware
		def initialize(app)
			@app = app

			routes = Journey::Routes.new
      		path  = Journey::Path::Pattern.new "/blob/:bucket/:key(.:format)"
			routes.add_route(lambda{|env| Blah.new.call(env)}, path, {}, {:bucket => "none"})
			@journey = Journey::Router.new routes, {}
		end
		def call(env)
        	Goliath::Rack::Validator.safely(env) do
        		status, headers, body =  @journey.call(env)
        		env['params'] ||= {}
        		env['params'].merge!(body) if body.respond_to? :has_key?
        		@app.call(env)
        	end
      	end
	end