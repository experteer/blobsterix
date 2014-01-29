module BlobServer
	class AppRouterBase

		def self.get(path, controller)
			path  = Journey::Path::Pattern.new path
			router.routes.add_route(lambda{|env| call_controller(controller,env)}, path, {:request_method => "GET"}, {})
		end

		def self.post(path, controller)
			path  = Journey::Path::Pattern.new path
			router.routes.add_route(lambda{|env| call_controller(controller,env)}, path, {:request_method => "POST"}, {})
		end

		def self.put(path, controller)
			path  = Journey::Path::Pattern.new path
			router.routes.add_route(lambda{|env| call_controller(controller,env)}, path, {:request_method => "PUT"}, {})
		end

		def self.delete(path, controller)
			path  = Journey::Path::Pattern.new path
			router.routes.add_route(lambda{|env| call_controller(controller,env)}, path, {:request_method => "DELETE"}, {})
		end

		def self.head(path, controller)
			path  = Journey::Path::Pattern.new path
			router.routes.add_route(lambda{|env| call_controller(controller,env)}, path, {:request_method => "HEAD"}, {})
		end

		def self.call(env)
			router.call(env)
		end

		def self.call_controller(controller, env)
			controller.respond_to?(:call) ? controller.call(env) : controller.new.call(env)
		end

		private
			def self.routes()
				(@@routes ||= {})[self.name] ||= Journey::Routes.new
			end

			def self.router()
				(@@router ||= {})[self.name] ||= Journey::Router.new routes, {}
			end
	end
end