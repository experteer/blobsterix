module Blobsterix
  module Jsonizer
    def json_var(*var_names)
      @json_vars = (@json_vars || []) + var_names.flatten
    end

    def json_vars
      @json_vars ||= []
    end

    module Methods
      def render_json(obj = nil)
        Http.OK (obj || self).to_json, "json"
      end

      def render_xml(obj = nil)
        obj = Nokogiri::XML::Builder.new do |xml|
          yield xml
        end if block_given?
        Http.OK (obj || self).to_xml, "xml"
      end

      def to_json
        stuff = {}
        self.class.json_vars.each do|var_name|
          stuff[var_name.to_sym] = send(var_name) if respond_to?(var_name)
        end
        stuff.to_json
      end

      def to_xml
        xml = Nokogiri::XML::Builder.new do |xml|
          xml.BlobsterixStatus() do
            self.class.json_vars.each do|var_name|
              var = send(var_name)
              var = var.to_xml if var.respond_to?(:to_xml)
              xml.send(var_name, var) if respond_to?(var_name)
            end
          end
        end
        xml.to_xml
      end
    end
  end
end
