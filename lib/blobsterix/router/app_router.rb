module Blobsterix
  class AppRouterBase

    extend Jsonizer
    include Jsonizer::Methods
    include Logable

    attr_accessor :env

    def initialize(env)
      @env = env
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
      @@renderer||=TemplateRenderer.create(binding)
    end

    def render(template_name, status_code=200, bind=nil)
      begin
        Http.Response(status_code, renderer.render(template_name, bind||binding), "html")
      rescue Errno::ENOENT => e
        Http.NotFound
      end
    end

    def self.options(opt)
      opt = {:function => opt.to_sym} if opt.class != Hash
      {:controller => self.name, :function => :call}.merge(opt)
    end

    def self.http_verbs
      @http_verbs||=["GET", "POST", "PUT", "DELETE", "HEAD"]
    end

    http_verbs.each do |method|
      define_singleton_method method.downcase.to_sym do |path, opt = {}|
        path  = Journey::Path::Pattern.new path
        router.routes.add_route(lambda{|env| call_controller(options(opt), env)}, path, {:request_method => method}, {})
      end
    end

    def self.call(env)
      Blobsterix::StatusInfo.connections+=1
      print_ram_usage("RAM USAGE Before")
      result=router.call(env)
      print_ram_usage("RAM USAGE After")
      Blobsterix::StatusInfo.connections-=1
      result
    end

    def self.print_ram_usage(text)
      Blobsterix.logger.info "#{text}[#{Process.pid}]: " + `pmap #{Process.pid} | tail -1`[10,40].strip
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
