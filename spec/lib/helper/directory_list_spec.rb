require "spec_helper"

describe Blobsterix::DirectoryList do
  include Blobsterix::SpecHelper

  describe "list all" do
    before :all do
      10.times do|id|
        Blobsterix.cache.put_raw(Blobsterix::BlobAccess.new(:bucket => "test", :id => "#{id}"), "data")
      end
    end
    after :all do
      clear_cache
    end
    it "should list all files in the directories" do
      count = 0
      Blobsterix::DirectoryList.each(Blobsterix.cache_dir) do |path, filename|
        count+=1 if !filename.to_s.match(/\.meta$/)
      end
      count.should eql(10)
    end
    it "should just run shit" do
      counter = 0
      a = Blobsterix::DirectoryWalker.new(Blobsterix.cache_dir)
      while a.next
        counter += 1
      end
      Blobsterix::DirectoryList.each(Blobsterix.cache_dir) do |dir, file|
        counter -= 1
      end
      counter.should eql(0)
    end
  end
end