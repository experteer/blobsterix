module BlobServer
	module Http
		def self.NextApi(data="Not Found", content_type="txt")
			[600, {"Content-Type" => MimeMagic.by_extension(content_type).type}, data]
		end
		def self.NotFound(data="Not Found", content_type="txt")
			[404, {"Content-Type" => MimeMagic.by_extension(content_type).type}, data]
		end
		def self.NotAllowed(data="Not Found", content_type="txt")
			[403, {"Content-Type" => MimeMagic.by_extension(content_type).type}, data]
		end
		def self.OK(data="", content_type="txt")
			[200, {"Content-Type" => MimeMagic.by_extension(content_type).type}, data]
		end
		def self.OK_no_data(data="", content_type="txt")
			[204, {}, ""]
		end
	end
end