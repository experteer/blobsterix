module Blobsterix
	class AppRouterBase

		attr_reader :logger
		attr_accessor :env

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

		def next_api
			Http.NextApi
		end

		def self.options(opt)
			{:controller => self.name, :function => :call}.merge(opt)
		end

		def self.get(path, opt = {})
			path  = Journey::Path::Pattern.new path
			router.routes.add_route(lambda{|env| call_controller(options(opt), env)}, path, {:request_method => "GET"}, {})
		end

		def self.post(path, opt = {})
			path  = Journey::Path::Pattern.new path
			router.routes.add_route(lambda{|env| call_controller(options(opt), env)}, path, {:request_method => "POST"}, {})
		end

		def self.put(path, opt = {})
			path  = Journey::Path::Pattern.new path
			router.routes.add_route(lambda{|env| call_controller(options(opt), env)}, path, {:request_method => "PUT"}, {})
		end

		def self.delete(path, opt = {})
			path  = Journey::Path::Pattern.new path
			router.routes.add_route(lambda{|env| call_controller(options(opt), env)}, path, {:request_method => "DELETE"}, {})
		end

		def self.head(path, opt = {})
			path  = Journey::Path::Pattern.new path
			router.routes.add_route(lambda{|env| call_controller(options(opt), env)}, path, {:request_method => "HEAD"}, {})
		end

		def self.call(env)
			router.call(env)
		end

		def self.call_controller(options, env)
			options[:controller].respond_to?(options[:function]) ? options[:controller].send(options[:function], env) : Blobsterix.const_get(options[:controller]).new(env).send(options[:function])
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