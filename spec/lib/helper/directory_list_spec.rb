require "spec_helper"

describe Blobsterix::DirectoryList do
  include Blobsterix::SpecHelper

  describe "list all" do
    before :each do
      10.times do|id|
        Blobsterix.cache.put_raw(Blobsterix::BlobAccess.new(:bucket => "test", :id => "#{id}"), "data")
      end
    end
    after :each do
      clear_cache
    end
    it "should give the same entries as glob" do
      count = Dir.glob("#{Blobsterix.cache_dir}/**/*").select { |f| File.file?(f) && !f.to_s.match(/\.meta$/) }.length
      Blobsterix::DirectoryList.each(Blobsterix.cache_dir) do |path, filename|
        count-=1 if !filename.to_s.match(/\.meta$/)
      end
      count.should eql 0
    end
    it "should list all files in the directories" do
      count = 0
      Blobsterix.cache.delete(Blobsterix::BlobAccess.new(:bucket => "test", :id => "5"))
      Blobsterix::DirectoryList.each(Blobsterix.cache_dir) do |path, filename|
        count+=1 if !filename.to_s.match(/\.meta$/)
      end
      count.should eql(9)
    end
    it "should get the next entry" do
      a = Blobsterix::DirectoryWalker.new(Blobsterix.cache_dir, :start_path => Blobsterix::DirectoryWalker.new(Blobsterix.cache_dir).next)
      b = Blobsterix::DirectoryWalker.new(Blobsterix.cache_dir)
      first = a.next
      real_first = b.next
      second = b.next
      first.should eql(second)
      first.should_not eql(real_first)
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