module Blobsterix
  class BlobAccess
    attr_reader :bucket, :id, :trafo, :accept_type
    attr_reader :source, :target

    def initialize(atts = {})
      @trafo = []
      atts.each { |key, value| send("#{key}=", value) }
      identifier
    end

    def identifier
      @identifier ||= "#{bucket}_#{id.gsub("/", "_")}_#{trafo.map { |trafo_pair|"#{trafo_pair[0]}_#{trafo_pair[1]}" }.join(",")}.#{subtype}"
    end

    def to_s
      "BlobAccess: bucket(#{bucket}), id(#{id}), trafo(#{trafo}), accept_type(#{accept_type})"
    end

    def get
      @meta ||= find_blob
    end

    def equals?(blob_access)
      identifier == blob_access.identifier
    end

    def copy
      BlobAccess.new(:bucket => bucket, :id => id, :trafo => trafo, :accept_type => accept_type, :source => source, :target => target)
    end

    def reset!
      @meta = nil
      self
    end

    private

    def find_blob
      unless Blobsterix.cache.exists?(self)
        if trafo.empty? || raw_trafo?
          metaData = Blobsterix.storage.get(bucket, id)
          if raw_trafo? || raw_accept_type?(metaData.accept_type)
            load_from_storage(metaData)
          end
        end
      end || Blobsterix.cache.get(self)
    end

    def raw_trafo?
      @raw_trafo ||= (trafo.length == 1 && trafo[0][0] == "raw")
    end

    def raw_accept_type?(other)
      @raw_accept_type ||= (!accept_type || accept_type.equal?(other))
    end

    def load_from_storage(metaData)
      return metaData unless Blobsterix.cache_original?
      Blobsterix.cache.put_raw(BlobAccess.new(:bucket => bucket, :id => id), metaData.data) if metaData.valid?
      return Blobsterix.cache.get(BlobAccess.new(:bucket => bucket, :id => id)) if metaData.valid?
      nil
    end

    def subtype
      accept_type ? accept_type.subtype : ""
    end
    attr_writer :bucket, :id, :trafo, :accept_type
    attr_writer :source, :target
  end
end
