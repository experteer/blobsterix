module Blobsterix
  class ReloadTemplateRenderer
    def initialize(binding_)
      @binding = binding_
    end

    def render(template_name, bind=nil)
      TemplateRenderer.new(bind||@binding).render(template_name)
    end
  end

  class TemplateRenderer
    def self.create(binding_)
      (Blobsterix.respond_to?(:env) && Blobsterix.env == :production) ? TemplateRenderer.new(binding_) : ReloadTemplateRenderer.new(binding_)
    end

    def initialize(controller_binding_)
      @controller_binding=controller_binding_
    end

    def render(template_name, bind=nil)
      template(template_name).result(bind||controller_binding)
    end

    private

    def controller_binding
      @controller_binding
    end

    def template(template_name)
      begin
        templates[template_name]||=::ERB.new(File.read(Blobsterix.root.join("views", "#{template_name}.erb")))
      rescue Errno::ENOENT => e
        templates[template_name]||=::ERB.new(File.read(Blobsterix.root_gem.join("templates/views", "#{template_name}.erb")))
      end
    end

    def templates
      @templates||={}
    end
  end
end
