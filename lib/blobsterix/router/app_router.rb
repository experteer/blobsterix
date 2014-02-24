module Blobsterix
	class AppRouterBase

		attr_reader :logger
		attr_reader :env

		def initialize(env)
			@env = env
			@logger = env["rack.logger"]
		end

		def storage
			@storage ||= Blobsterix.storage(logger)
		end

		def cache
			@cache ||= Blobsterix.cache(logger)
		end

		def transformation
			@transformation ||= Blobsterix.transformation(logger)
		end

		def self.get(path, controller, function = :call)
			path  = Journey::Path::Pattern.new path
			router.routes.add_route(lambda{|env| call_controller(controller, function, env)}, path, {:request_method => "GET"}, {})
		end

		def self.post(path, controller, function = :call)
			path  = Journey::Path::Pattern.new path
			router.routes.add_route(lambda{|env| call_controller(controller, function, env)}, path, {:request_method => "POST"}, {})
		end

		def self.put(path, controller, function = :call)
			path  = Journey::Path::Pattern.new path
			router.routes.add_route(lambda{|env| call_controller(controller, function, env)}, path, {:request_method => "PUT"}, {})
		end

		def self.delete(path, controller, function = :call)
			path  = Journey::Path::Pattern.new path
			router.routes.add_route(lambda{|env| call_controller(controller, function, env)}, path, {:request_method => "DELETE"}, {})
		end

		def self.head(path, controller, function = :call)
			path  = Journey::Path::Pattern.new path
			router.routes.add_route(lambda{|env| call_controller(controller, function, env)}, path, {:request_method => "HEAD"}, {})
		end

		def self.call(env)
			router.call(env)
		end

		def self.call_controller(controller, function, env)
			controller.respond_to?(function) ? controller.call(env) : controller.new(env).send(function)
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