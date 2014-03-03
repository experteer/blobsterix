module Blobsterix
  class TemplateRenderer
    def initialize(controller_binding_)
      @controller_binding=controller_binding_
    end

    def controller_binding
      @controller_binding
    end

    def template(template_name)
      templates[template_name]||=::ERB.new(File.read(Blobsterix.root_gem.join("templates/views", "#{template_name}.erb")))
    end

    def render(template_name)
      template(template_name).result(controller_binding)
    end

    def templates
      @templates||={}
    end
  end
end