module BlobServer::Transformations::Impl
  class $ClassNameTransformation < BlobServer::Transformations::Transformation

    def name()
      #this function should return the name of the trafo that will be used in the url
      "$url_name"
    end

    def is_format?()
      # this function tells the transformation chain if this transformation counts as a fixed format.
      # That way no further transformation will be added if the browser requested a different format.
      # usefull to force a specific format
      # @return 
      # => true : force format
      # => false: allow different format
      false
    end

    def input_type()
      # this function should return a BlobServer::AcceptType that tells the transformator
      # which formats are supported
      # its normal mimetype
      @input_type ||= BlobServer::AcceptType.new "*/*"
    end

    def output_type()
       # this function should return a BlobServer::AcceptType that tells the transformator
      # which format is produced by this transformation
      # its normal mimetype
      @output_type ||= BlobServer::AcceptType.new "text/plain"
    end

    def transform(input_path, target_path, value)
      # this function is doing the actual work
      # the input file is in input_path and the result of the transformation shall be written
      # to target_path. The value parameter is a string that is given to the transformation.
      # The value parsing and verification has to be done here.
      FileUtils.cp(input_path, target_path)
    end
  end
end