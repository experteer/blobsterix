module Blobsterix::Transformations::Impl
	class ColorSpaceImage < Blobsterix::Transformations::Transformation
		def name()
			"grayscale"
		end
		def input_type()
			@input_type ||= Blobsterix::AcceptType.new "image/*"
		end

		def output_type()
			@output_type ||= Blobsterix::AcceptType.new "image/*"
		end

		def transform(input_path, target_path, value)
			image = MiniMagick::Image.open(input_path)
			image.colorspace "gray"
			image.write target_path
		end
	end
	class RotateImage < Blobsterix::Transformations::Transformation
		def name()
			"rotate"
		end
		def input_type()
			@input_type ||= Blobsterix::AcceptType.new "image/*"
		end

		def output_type()
			@output_type ||= Blobsterix::AcceptType.new "image/*"
		end

		def transform(input_path, target_path, value)
			image = MiniMagick::Image.open(input_path)
			image.combine_options do |c|
				c.background "none"
				c.rotate value
			end
			image.write target_path
		end
	end

	class AdaptiveResizeImage < Blobsterix::Transformations::Transformation
		def name()
			"aresize"
		end
		def input_type()
			@input_type ||= Blobsterix::AcceptType.new "image/*"
		end

		def output_type()
			@output_type ||= Blobsterix::AcceptType.new "image/*"
		end

		def transform(input_path, target_path, value)
			image = MiniMagick::Image.open(input_path)
			image.adaptive_resize value
			image.write target_path
		end
	end

	class ResizeImage < Blobsterix::Transformations::Transformation
		def name()
			"resize"
		end
		def input_type()
			@input_type ||= Blobsterix::AcceptType.new "image/*"
		end

		def output_type()
			@output_type ||= Blobsterix::AcceptType.new "image/*"
		end

		def transform(input_path, target_path, value)
			image = MiniMagick::Image.open(input_path)
			image.resize value
			image.write target_path
		end
	end

	class ShrinkImage < Blobsterix::Transformations::Transformation
		def name()
			"shrink"
		end
		def input_type()
			@input_type ||= Blobsterix::AcceptType.new "image/*"
		end

		def output_type()
			@output_type ||= Blobsterix::AcceptType.new "image/*"
		end

		def transform(input_path, target_path, value)
			image = MiniMagick::Image.open(input_path)
			image.resize "#{image[:width]/value.to_i}x#{image[:height]/value.to_i}"
			image.write target_path
		end
	end

	class StripImage < Blobsterix::Transformations::Transformation
		def name()
			"strip"
		end
		def input_type()
			@input_type ||= Blobsterix::AcceptType.new "image/*"
		end

		def output_type()
			@output_type ||= Blobsterix::AcceptType.new "image/*"
		end

		def is_format?()
			true
		end

		def transform(input_path, target_path, value)
			image = MiniMagick::Image.open(input_path)
			image.strip
			image.write target_path
		end
	end

	class CropImage < Blobsterix::Transformations::Transformation
		def name()
			"crop"
		end
		def input_type()
			@input_type ||= Blobsterix::AcceptType.new "image/*"
		end

		def output_type()
			@output_type ||= Blobsterix::AcceptType.new "image/*"
		end

		def transform(input_path, target_path, value)
			image = MiniMagick::Image.open(input_path)
			image.crop value
			image.write target_path
		end
	end

	class Image2HTML < Blobsterix::Transformations::Transformation
		def input_type()
			@input_type ||= Blobsterix::AcceptType.new "image/*"
		end

		def output_type()
			@output_type ||= Blobsterix::AcceptType.new "text/html"
		end

		def is_format?()
			true
		end

		def transform(input_path, target_path, value)
			type = "image/*"
			File.open(input_path) {|file|
				type = MimeMagic.by_magic(file).type
			}
			
			image = type === "image/webp" ? {:width => "unknown", :height => "unknown"} : MiniMagick::Image.open(input_path)
			File.open(target_path, "w") {|file|
				file.write("<html><body>Mimetype: #{type}<br>Width: #{image[:width]}<br>Height: #{image[:height]}</body></html>")
			}
		end
	end

	class Image2Json < Blobsterix::Transformations::Transformation
		def name()
			"json"
		end
		
		def input_type()
			@input_type ||= Blobsterix::AcceptType.new "image/*"
		end

		def output_type()
			@output_type ||= Blobsterix::AcceptType.new "text/json"
		end

		def is_format?()
			true
		end

		def transform(input_path, target_path, value)
			type = "image/*"
			File.open(input_path) {|file|
				type = MimeMagic.by_magic(file).type
			}
			
			image = type === "image/webp" ? {:width => "unknown", :height => "unknown"} : MiniMagick::Image.open(input_path)
			File.open(target_path, "w") {|file|
				file.write({:width => image[:width], :height => image[:height]}.merge(Blobsterix::Storage::FileSystemMetaData.new(input_path).as_json).to_json)
			}
		end
	end

	class Image2Json < Blobsterix::Transformations::Transformation
		def name()
			"json_all"
		end
		
		def input_type()
			@input_type ||= Blobsterix::AcceptType.new "*/*"
		end

		def output_type()
			@output_type ||= Blobsterix::AcceptType.new "text/json"
		end

		def is_format?()
			true
		end

		def transform(input_path, target_path, value)
			File.open(target_path, "w") {|file|
				file.write(Blobsterix::Storage::FileSystemMetaData.new(input_path).to_json)
			}
		end
	end

	class RawTransformation < Blobsterix::Transformations::Transformation
		def name()
			"raw"
		end

		def is_format?()
			true
		end

		def input_type()
			@input_type ||= Blobsterix::AcceptType.new "image/*"
		end

		def output_type()
			@output_type ||= Blobsterix::AcceptType.new "image/*"
		end

		def transform(input_path, target_path, value)
			system("cp #{input_path} #{target_path}")
		end
	end

	class AsciiTransformation < Blobsterix::Transformations::Transformation
		def name()
			"ascii"
		end

		def is_format?()
			true
		end

		def input_type()
			@input_type ||= Blobsterix::AcceptType.new "image/*"
		end

		def output_type()
			@output_type ||= Blobsterix::AcceptType.new "text/plain"
		end

		def transform(input_path, target_path, value)
			system("convert #{input_path} jpg:- | jp2a --width=#{value and value.size > 0 ? value : 100} - > #{target_path}")
		end
	end

	class AsciiHTMLTransformation < Blobsterix::Transformations::Transformation
		def name()
			"asciihtml"
		end

		def is_format?()
			true
		end

		def input_type()
			@input_type ||= Blobsterix::AcceptType.new "image/*"
		end

		def output_type()
			@output_type ||= Blobsterix::AcceptType.new "text/plain"
		end

		def transform(input_path, target_path, value)
			parts = value.split("x")[0]
			lines = parts[0]
			em = parts.length > 1 ? parts[1].to_i : 1
			system("convert #{input_path} jpg:- | jp2a --width=#{lines and lines.to_i > 0 ? value : 100} - > #{target_path}")
			text = File.read(target_path)
			File.write(target_path, "<html><body style='font-size: #{em}em'><pre>#{text.gsub("\n", "<br>")}</pre></body></html>")
		end
	end

	class PngTransformation < Blobsterix::Transformations::Transformation
		def name()
			"png"
		end

		def is_format?()
			true
		end

		def input_type()
			@input_type ||= Blobsterix::AcceptType.new "image/*"
		end

		def output_type()
			@output_type ||= Blobsterix::AcceptType.new "image/png"
		end

		def transform(input_path, target_path, value)
			system("convert #{input_path} png:#{target_path}")
		end
	end

	class JPegTransformation < Blobsterix::Transformations::Transformation
		def name()
			"jpg"
		end

		def is_format?()
			true
		end

		def input_type()
			@input_type ||= Blobsterix::AcceptType.new "image/*"
		end

		def output_type()
			@output_type ||= Blobsterix::AcceptType.new "image/jpeg"
		end

		def transform(input_path, target_path, value)
			system("convert #{input_path} jpg:#{target_path}")
		end
	end

	class GifTransformation < Blobsterix::Transformations::Transformation
		def name()
			"gif"
		end

		def is_format?()
			true
		end

		def input_type()
			@input_type ||= Blobsterix::AcceptType.new "image/*"
		end

		def output_type()
			@output_type ||= Blobsterix::AcceptType.new "image/gif"
		end

		def transform(input_path, target_path, value)
			system("convert #{input_path} gif:#{target_path}")
		end
	end

	class WebPTransformation < Blobsterix::Transformations::Transformation
		def name()
			"webp"
		end

		def is_format?()
			true
		end

		def input_type()
			@input_type ||= Blobsterix::AcceptType.new "image/*"
		end

		def output_type()
			@output_type ||= Blobsterix::AcceptType.new "image/webp"
		end

		def transform(input_path, target_path, value)
			system("cwebp #{input_path} -o #{target_path}")
			#system("cp #{input_path} #{target_path}")
		end
	end

	class SleepTransformation < Blobsterix::Transformations::Transformation
		def name()
			"sleep"
		end

		def input_type()
			@input_type ||= Blobsterix::AcceptType.new "image/*"
		end

		def output_type()
			@output_type ||= Blobsterix::AcceptType.new "image/*"
		end

		def transform(input_path, target_path, value)
			p "SLEEEP"
			sleep(value.to_i)
			system("cp #{input_path} #{target_path}")
		end
	end
end