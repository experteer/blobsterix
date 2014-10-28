module Blobsterix
  class ZipFilePresenter
    attr_accessor :size

    def addFile(file)
      files.push file
    end

    def files
      @files||=[]
    end

    def as_json
      {
        :size => size,
        :files => files
      }
    end
  end
end