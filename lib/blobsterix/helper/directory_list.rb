module Blobsterix
  class DirectoryListing
    attr_reader :path
    def initialize(path)
      @path = Pathname.new path
    end
    def all
      Dir.entries(path).sort.select {|entry| entry != "." && entry != ".."}.map{|entry| path.join(entry)}
    end
  end
  class FileListing
    attr_reader :path
    def initialize(path)
      @path = Pathname.new path
    end
    def all
      Dir.entries(path).sort.select {|entry| entry != "." && entry != ".."}
    end
  end
  class DirectoryList
    def self.each(path)
      DirectoryListing.new(path).all.each do |dir0|
        DirectoryListing.new(dir0).all.each do |dir1|
          DirectoryListing.new(dir1).all.each do |dir2|
            DirectoryListing.new(dir2).all.each do |dir3|
              DirectoryListing.new(dir3).all.each do |dir4|
                DirectoryListing.new(dir4).all.each do |dir5|
                  FileListing.new(dir5).all.each do |file|
                    yield dir5, file
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end