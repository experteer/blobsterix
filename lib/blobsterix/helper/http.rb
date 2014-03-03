module Blobsterix
	module Http
		def self.renderer
			@@renderer||=(Blobsterix.respond_to?(:env) && Blobsterix.env == :production) ? TemplateRenderer.new(binding) : ReloadTemplateRenderer.new(binding)
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
		def self.NextApi(data="Not Found", content_type="txt")
			[600, {"Content-Type" => MimeMagic.by_extension(content_type).type}, data]
		end
		def self.NotFound(data="Not Found", content_type="html")
			[404, {"Content-Type" => MimeMagic.by_extension(content_type).type}, renderer.render("error_page", error_object_binding(:title=>"Not Found", :content=>data, :error_code => 404))]
		end
		def self.ServerError(data="Server Error", content_type="html")
			[500, {"Content-Type" => MimeMagic.by_extension(content_type).type}, renderer.render("error_page", error_object_binding(:title=>"Server Error", :content=>data, :error_code => 500))]
		end
		def self.NotAllowed(data="Not Allowed", content_type="html")
			[403, {"Content-Type" => MimeMagic.by_extension(content_type).type}, renderer.render("error_page", error_object_binding(:title=>"Not Allowed", :content=>data, :error_code => 403))]
		end
		def self.NotAuthorized(data="Not Authorized", content_type="html")
			[401, {"Content-Type" => MimeMagic.by_extension(content_type).type}, renderer.render("error_page", error_object_binding(:title=>"Not Authorized", :content=>data, :error_code => 401))]
		end
		def self.OK(data="", content_type="txt")
			[200, {"Content-Type" => MimeMagic.by_extension(content_type).type}, data]
		end
		def self.Response(status_code=200, data="", content_type="txt")
			[status_code, {"Content-Type" => MimeMagic.by_extension(content_type).type}, data]
		end
		def self.OK_no_data(data="", content_type="txt")
			[204, {}, ""]
		end
	end
end
