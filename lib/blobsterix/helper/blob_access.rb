module Blobsterix
  class BlobAccess
    attr_reader :bucket, :id,:trafo,:accept_type
    attr_reader :source,:target

    def initialize(atts={})
      @trafo = []
      atts.each do |key,value| send("#{key}=",value) end
      identifier
    end

    def identifier
       @identifier||= "#{bucket}_#{id.gsub("/","_")}_#{trafo.map {|trafo_pair|"#{trafo_pair[0]}_#{trafo_pair[1]}"}.join(",")}.#{subtype}"
    end

    def to_s()
      "BlobAccess: bucket(#{bucket}), id(#{id}), trafo(#{trafo}), accept_type(#{accept_type})"
    end

    private

    def subtype
      accept_type ? accept_type.subtype : ""
    end
    attr_writer :bucket, :id,:trafo,:accept_type
    attr_writer :source, :target
  end
end
