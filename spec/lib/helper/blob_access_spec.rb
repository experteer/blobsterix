require "spec_helper"

describe Blobsterix::BlobAccess do
  include Blobsterix::SpecHelper

  let(:data) {"Hi my name is Test"}
  let(:key) {"test.txt"}
  let(:bucket) {"test"}

  def blob_access
    Blobsterix::BlobAccess.new(:bucket => bucket, :id => key)
  end
  def blob_access_1
    Blobsterix::BlobAccess.new(:bucket => bucket, :id => key, :trafo => [["test", ""]])
  end
  def blob_access_raw
    Blobsterix::BlobAccess.new(:bucket => bucket, :id => key, :trafo => [["raw", ""]])
  end
  def blob_access_same_accept_type
    Blobsterix::BlobAccess.new(:bucket => bucket, :id => key, :accept_type => Blobsterix::AcceptType.new("text/plain"))
  end
  def blob_access_raw_same_accept_type
    Blobsterix::BlobAccess.new(:bucket => bucket, :id => key, :trafo => [["raw", ""]], :accept_type => Blobsterix::AcceptType.new("text/plain"))
  end

  around(:each) do |example|
    run_em(&example)
  end

  describe "blob_access" do
    after :each do
      clear_data
    end

    it "should return valid blob data when it exists" do
      Blobsterix.storage.put(bucket, key, StringIO.new(data, "r"))
      expect(blob_access.get().valid).to be(true)
    end

    it "should return invalid blob data when it does not exist" do
      expect(blob_access.get().valid).to be(false)
    end

    it "should automaticly guess raw trafo" do
      Blobsterix.storage.put(bucket, key, StringIO.new(data, "r"))
      expect(blob_access.get().valid).to be(true)
      expect(blob_access_raw.get().valid).to be(true)
      expect(blob_access_same_accept_type.get().valid).to be(true)
      expect(blob_access_raw_same_accept_type.get().valid).to be(true)
    end

    context "dont cache raw" do 
      before :each do
        Blobsterix.cache_original= false
      end

      it "should not create a cache entry for raw transforms" do
        Blobsterix.storage.put(bucket, key, StringIO.new(data, "r"))
        expect(blob_access.get().valid).to be(true)
        expect(Blobsterix.cache.get(blob_access).valid).to be(false)
      end
    end

    context "cache raw" do 
      before :each do
        Blobsterix.cache_original= true
      end

      it "should create a cache entry for raw transforms" do
        Blobsterix.storage.put(bucket, key, StringIO.new(data, "r"))
        expect(blob_access.get().valid).to be(true)
        expect(Blobsterix.cache.get(blob_access).valid).to be(true)
      end
    end
  end
end
