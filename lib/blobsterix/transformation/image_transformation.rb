module Blobsterix::Transformations::Impl
  def self.create_simple_trafo(name_, input, output, is_format_=false, &block)
    trafo = ::Class.new Blobsterix::Transformations::Transformation do

      def self.name=(obj)
        @name=obj
      end

      def self.name_
        @name
      end
      
      def self.is_format=(obj)
        @is_format=obj
      end

      def self.is_format_
        @is_format
      end
      
      def self.setTypes(input,output)
        @input= ::Blobsterix::AcceptType.new input
        @output= ::Blobsterix::AcceptType.new output
      end
      
      def self.input_type_
        @input
      end
      
      def self.output_type_
        @output
      end

      def self.body=(obj)
        @body=obj
      end

      def self.body_
        @body
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
    trafo.is_format=is_format_
    trafo.body=block
    trafo.name=name_
    ::Blobsterix::Transformations::Impl.const_set("#{name_.capitalize}Transformation", trafo)
  end

  create_simple_trafo("grayscale", "image/*", "image/*", false) do |input_path, target_path, value|
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
    image.resize "#{image[:width]/value.to_i}x#{image[:height]/value.to_i}"
    image.write target_path
  end

  create_simple_trafo("strip", "image/*", "image/*", true) do |input_path, target_path, value|
    image = MiniMagick::Image.open(input_path)
    image.strip
    image.write target_path
  end

  create_simple_trafo("crop", "image/*", "image/*", false) do |input_path, target_path, value|
    image = MiniMagick::Image.open(input_path)
    image.crop value
    image.write target_path
  end

  create_simple_trafo("image2HTML", "image/*", "text/html", true) do |input_path, target_path, value|
    type = "image/*"
    File.open(input_path) {|file|
      type = MimeMagic.by_magic(file).type
    }

    image = type === "image/webp" ? {:width => "unknown", :height => "unknown"} : MiniMagick::Image.open(input_path)
    File.open(target_path, "w") {|file|
      file.write("<html><body>Mimetype: #{type}<br>Width: #{image[:width]}<br>Height: #{image[:height]}</body></html>")
    }
  end

  create_simple_trafo("json", "image/*", "text/json", true) do |input_path, target_path, value|
    type = "image/*"
    File.open(input_path) {|file|
      type = MimeMagic.by_magic(file).type
    }

    image = type === "image/webp" ? {:width => "unknown", :height => "unknown"} : MiniMagick::Image.open(input_path)
    File.open(target_path, "w") {|file|
      file.write({:width => image[:width], :height => image[:height]}.merge(Blobsterix::Storage::FileSystemMetaData.new(input_path).as_json).to_json)
    }
  end

  create_simple_trafo("jsonall", "image/*", "text/json", true) do |input_path, target_path, value|
    File.open(target_path, "w") {|file|
      file.write(Blobsterix::Storage::FileSystemMetaData.new(input_path).to_json)
    }
  end

  create_simple_trafo("raw", "image/*", "image/*", true) do |input_path, target_path, value|
    raise StandardError.new($?) unless system("cp \"#{input_path}\" \"#{target_path}\"")
  end

  create_simple_trafo("ascii", "image/*", "text/plain", true) do |input_path, target_path, value|
    raise StandardError.new($?) unless system("convert \"#{input_path}\" jpg:- | jp2a --width=#{value and value.size > 0 ? value : 100} - > \"#{target_path}\"")
  end

  create_simple_trafo("png", "image/*", "image/png", true) do |input_path, target_path, value|
    raise StandardError.new($?) unless system("convert \"#{input_path}\" png:\"#{target_path}\"")
  end

  create_simple_trafo("jpg", "image/*", "image/jpeg", true) do |input_path, target_path, value|
    raise StandardError.new($?) unless system("convert \"#{input_path}\" jpg:\"#{target_path}\"")
  end

  create_simple_trafo("gif", "image/*", "image/gif", true) do |input_path, target_path, value|
    raise StandardError.new($?) unless system("convert \"#{input_path}\" gif:\"#{target_path}\"")
  end

  create_simple_trafo("webp", "image/*", "image/webp", true) do |input_path, target_path, value|
    raise StandardError.new($?) unless system("cwebp \"#{input_path}\" -o \"#{target_path}\"")
  end

  create_simple_trafo("text", "image/*", "image/*", true) do |input_path, target_path, value|
    raise StandardError.new($?) unless system("convert \"#{input_path}\" -pointsize 20 -draw \"gravity center fill white text 0,12 '#{value.gsub("_", " ").gsub("\"", "'")}'\" \"#{target_path}\"")
  end

  create_simple_trafo("sleep", "image/*", "image/*", true) do |input_path, target_path, value|
    p "SLEEEP"
    sleep(value.to_i)
    raise StandardError.new($?) unless system("cp \"#{input_path}\" \"#{target_path}\"")
  end

  create_simple_trafo("unzip", "*/*", "*/*", true) do |input_path, target_path, value|
    file_name = value.gsub("_dot_", ".")
    file_name = file_name.gsub("_slash_", "/")
    file_name = file_name[1..-1] if file_name[0] == "/"
    ::Zip::File.open(input_path) do |zip_file|
      # Handle entries one by one
      zip_file.each do |entry|
        # Extract to file/directory/symlink
        if  entry.name == file_name
          entry.extract(target_path)
          break
        end
      end
    end
  end
end