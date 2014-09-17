module Blobsterix::Transformations::Impl
  def self.create_simple_trafo(name_, input, output, is_format_ = false, &block)
    trafo = ::Class.new Blobsterix::Transformations::Transformation do

      class << self
        attr_writer :name
        attr_writer :body
        attr_writer :is_format

        def name_
          @name
        end

        def is_format_
          @is_format
        end

        def setTypes(input, output)
          @input = ::Blobsterix::AcceptType.new input
          @output = ::Blobsterix::AcceptType.new output
        end

        def input_type_
          @input
        end

        def output_type_
          @output
        end

        def body_
          @body
        end
      end

      def initialize
      end

      def name
        self.class.name_
      end

      def is_format?
        self.class.is_format_
      end

      def input_type
        self.class.input_type_
      end

      def output_type
        self.class.output_type_
      end

      def transform(input_path, target_path, value)
        self.class.body_.call input_path, target_path, value
      end
    end
    trafo.setTypes(input, output)
    trafo.is_format = is_format_
    trafo.body = block
    trafo.name = name_
    ::Blobsterix::Transformations::Impl.const_set("#{name_.capitalize}Transformation", trafo)
  end

  create_simple_trafo("grayscale", "image/*", "image/*", false) do |input_path, target_path, _value|
    puts "grayscale"
    image = MiniMagick::Image.open(input_path)
    image.colorspace "gray"
    image.write target_path
  end

  create_simple_trafo("resize", "image/*", "image/*", false) do |input_path, target_path, value|
    image = MiniMagick::Image.open(input_path)
    image.resize value
    image.write target_path
  end

  create_simple_trafo("aresize", "image/*", "image/*", false) do |input_path, target_path, value|
    image = MiniMagick::Image.open(input_path)
    image.adaptive_resize value
    image.write target_path
  end

  create_simple_trafo("resizemax", "image/*", "image/*", false) do |input_path, target_path, value|
    image = MiniMagick::Image.open(input_path)
    image.resize "#{value}>"
    image.write target_path
  end

  create_simple_trafo("rotate", "image/*", "image/*", false) do |input_path, target_path, value|
    image = MiniMagick::Image.open(input_path)
    image.combine_options do |c|
      c.background "none"
      c.rotate value
    end
    image.write target_path
  end

  create_simple_trafo("shrink", "image/*", "image/*", false) do |input_path, target_path, value|
    image = MiniMagick::Image.open(input_path)
    image.resize "#{image[:width] / value.to_i}x#{image[:height] / value.to_i}"
    image.write target_path
  end

  create_simple_trafo("strip", "image/*", "image/*", true) do |input_path, target_path, _value|
    image = MiniMagick::Image.open(input_path)
    image.strip
    image.write target_path
  end

  create_simple_trafo("crop", "image/*", "image/*", false) do |input_path, target_path, value|
    image = MiniMagick::Image.open(input_path)
    image.crop value
    image.write target_path
  end

  create_simple_trafo("image2HTML", "image/*", "text/html", true) do |input_path, target_path, _value|
    type = "image/*"
    File.open(input_path) do|file|
      type = MimeMagic.by_magic(file).type
    end

    image = type === "image/webp" ? { :width => "unknown", :height => "unknown" } : MiniMagick::Image.open(input_path)
    File.open(target_path, "w") do|file|
      file.write("<html><body>Mimetype: #{type}<br>Width: #{image[:width]}<br>Height: #{image[:height]}</body></html>")
    end
  end

  create_simple_trafo("json", "image/*", "text/json", true) do |input_path, target_path, _value|
    type = "image/*"
    File.open(input_path) do|file|
      type = MimeMagic.by_magic(file).type
    end

    image = type === "image/webp" ? { :width => "unknown", :height => "unknown" } : MiniMagick::Image.open(input_path)
    File.open(target_path, "w") do|file|
      file.write({ :width => image[:width], :height => image[:height] }.merge(Blobsterix::Storage::FileSystemMetaData.new(input_path).as_json).to_json)
    end
  end

  create_simple_trafo("jsonall", "image/*", "text/json", true) do |input_path, target_path, _value|
    File.open(target_path, "w") do|file|
      file.write(Blobsterix::Storage::FileSystemMetaData.new(input_path).to_json)
    end
  end

  create_simple_trafo("raw", "image/*", "image/*", true) do |input_path, target_path, _value|
    fail StandardError.new($CHILD_STATUS) unless system("cp \"#{input_path}\" \"#{target_path}\"")
  end

  create_simple_trafo("ascii", "image/*", "text/plain", true) do |input_path, target_path, value|
    fail StandardError.new($CHILD_STATUS) unless system("convert \"#{input_path}\" jpg:- | jp2a --width=#{value and value.size > 0 ? value : 100} - > \"#{target_path}\"")
  end

  create_simple_trafo("png", "image/*", "image/png", true) do |input_path, target_path, _value|
    fail StandardError.new($CHILD_STATUS) unless system("convert \"#{input_path}\" png:\"#{target_path}\"")
  end

  create_simple_trafo("jpg", "image/*", "image/jpeg", true) do |input_path, target_path, _value|
    fail StandardError.new($CHILD_STATUS) unless system("convert \"#{input_path}\" jpg:\"#{target_path}\"")
  end

  create_simple_trafo("gif", "image/*", "image/gif", true) do |input_path, target_path, _value|
    fail StandardError.new($CHILD_STATUS) unless system("convert \"#{input_path}\" gif:\"#{target_path}\"")
  end

  create_simple_trafo("webp", "image/*", "image/webp", true) do |input_path, target_path, _value|
    fail StandardError.new($CHILD_STATUS) unless system("cwebp \"#{input_path}\" -o \"#{target_path}\"")
  end

  create_simple_trafo("text", "image/*", "image/*", true) do |input_path, target_path, value|
    fail StandardError.new($CHILD_STATUS) unless system("convert \"#{input_path}\" -pointsize 20 -draw \"gravity center fill white text 0,12 '#{value.gsub("_", " ").gsub("\"", "'")}'\" \"#{target_path}\"")
  end

  create_simple_trafo("sleep", "image/*", "image/*", true) do |input_path, target_path, value|
    p "SLEEEP"
    sleep(value.to_i)
    fail StandardError.new($CHILD_STATUS) unless system("cp \"#{input_path}\" \"#{target_path}\"")
  end
end
