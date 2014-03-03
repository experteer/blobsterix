module Blobsterix
  module Jsonizer
    def json_var(*var_names)
      @json_vars = (@json_vars||[])+var_names.flatten
    end

    def json_vars
      @json_vars||= []
    end
  end
  class AppRouterBase

    extend Jsonizer

    attr_reader :logger
    attr_accessor :env

    def initialize(env)
      @env = env
      @logger = env["rack.logger"]
    end

    def storage
      @storage ||= Blobsterix.storage
    end

    def cache
      @cache ||= Blobsterix.cache
    end

    def transformation
      @transformation ||= Blobsterix.transformation
    end

    def next_api
      Http.NextApi
    end

    def renderer
      @renderer||=TemplateRenderer.new(binding)
    end

    def render(template_name)
      begin
        Http.OK renderer.render(template_name), "html"
      rescue Errno::ENOENT => e
        Http.NotFound
      end
    end

    def render_json(obj=nil)
      Http.OK (obj||self).to_json, "json"
    end

    def render_xml(obj=nil)
      Http.OK (obj||self).to_xml, "xml"
    end

    def to_json
      stuff = Hash.new
      self.class.json_vars.each{|var_name|
        stuff[var_name.to_sym]=send(var_name) if respond_to?(var_name)
      }
      stuff.to_json
    end
    def to_xml()
      xml = Nokogiri::XML::Builder.new do |xml|
      xml.BlobsterixStatus() {
        self.class.json_vars.each{|var_name|
          var = send(var_name)
          var = var.to_xml if var.respond_to?(:to_xml)
          xml.send(var_name, var) if respond_to?(var_name)
        }
      }
      end
      xml.to_xml
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
      Blobsterix::StatusInfo.connections+=1
      result=router.call(env)
      Blobsterix::StatusInfo.connections-=1
      result
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