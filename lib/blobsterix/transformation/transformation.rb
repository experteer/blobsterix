module Blobsterix::Transformations
	class Transformation
		include Blobsterix::Logable

		def name()
			""
		end

		def is_format?()
			false
		end

		def input_type()
			Blobsterix::AcceptType.new
		end

		def output_type()
			Blobsterix::AcceptType.new
		end

		def transform(input_path, target_path, value)
			p "run transformation!!!!!"
			system("cp #{input_path} #{target_path}")
		end
	end
end