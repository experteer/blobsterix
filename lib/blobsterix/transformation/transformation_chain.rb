module Blobsterix::Transformations
  class TransformationChain
    attr_reader :logger
    def initialize(blob_access, input_data, logger)
      @blob_access=blob_access
      @target_blob_access=nil
      @input_data = input_data
      @transformations = []
      @logger = logger
    end

    def last_type()
      return Blobsterix::AcceptType.new(@input_data.mimetype) if @transformations.empty?
      @transformations.last[0].output_type
    end

    def add(transfo, value)
      return if transfo == nil
      @transformations << [transfo, value]
    end

    def do(cache)

      with_tempfiles do |keys|
        last_key = "#{@input_data.path}"

        @transformations.each{|trafo|
          new_key = keys.delete_at(0)
          trafo[0].transform(last_key, new_key, trafo[1])
          last_key = new_key
        }

        cache.put(@target_blob_access,Blobsterix::Storage::FileSystemMetaData.new(last_key).read)
      end if !@target_blob_access.get.valid

      @target_blob_access.copy
    end

    def finish(accept_type, trafo)
      if @transformations.empty? or (not @transformations.last[0].output_type.equal?(accept_type) and not @transformations.last[0].is_format?)
        @transformations << [trafo, nil] if trafo != nil && trafo.is_format?
      end
      accept_type =  @transformations.empty? || !@transformations.last[0].is_format? ? nil : @transformations.last[0].output_type
      @target_blob_access = Blobsterix::BlobAccess.new(:bucket => @blob_access.bucket, :id => @blob_access.id, :trafo => @transformations.map{|trafo,value| [trafo.name, value]}, :accept_type => accept_type)
    end

    private

    def with_tempfiles
      tmpFiles = @transformations.size.times.map{|index|
        Tempfile.new("#{@blob_access.identifier}_#{index}")
      }
      keys = tmpFiles.map{|f| f.path }

      yield keys

      tmpFiles.each { |f|
        f.close
        f.unlink
      }
    end
  end
end