module BlobServer::Transformations
	class Transformation
		def initialize()
		end

		def name()
			""
		end

		def is_format?()
			false
		end

		def input_type()
			BlobServer::AcceptType.new
		end

		def output_type()
			BlobServer::AcceptType.new
		end

		def transform(input_path, target_path, value)
			p "run transformation!!!!!"
			system("cp #{input_path} #{target_path}")
		end
	end
end