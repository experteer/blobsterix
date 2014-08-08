module Blobsterix
  module Http
    def self.renderer
      @@renderer||=TemplateRenderer.create(binding)
    end
    def self.error_object_binding(obj)
      obj||={}
      def obj.get_binding
        binding
      end
      def obj.title
        self[:title]
      end
      def obj.content
        self[:content]
      end
      def obj.error_code
        self[:error_code]
      end
      obj.get_binding
    end

    def self.error_massages
      @error_massages||={"Not Found" => 404, "Server Error" => 500, "Not Allowed" => 403, "Not Authorized" => 401}
    end

    error_massages.each do |error_name, error_code|
      define_singleton_method error_name.gsub(" ", "").to_sym do |data=error_name, content_type="html"|
        Response(error_code, renderer.render("error_page", error_object_binding(:title=>error_name, :content=>data, :error_code => 404)), content_type)
      end
    end

    def self.NextApi(data="Not Found", content_type="txt")
      Response(600, data, content_type)
    end
    def self.OK(data="", content_type="txt")
      Response(200, data, content_type)
    end
    def self.Response(status_code=200, data="", content_type="txt")
      [status_code, {"Content-Type" => MimeMagic.by_extension(content_type).type}, data]
    end
    def self.OK_no_data(data="", content_type="txt")
      [204, {}, ""]
    end
  end
end
