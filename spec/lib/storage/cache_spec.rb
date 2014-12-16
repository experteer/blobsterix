require "spec_helper"

describe Blobsterix::Storage::Cache do
  include Blobsterix::SpecHelper

  let(:data) {"Hi my name is Test"}
  let(:key) {"test.txt"}
  let(:bucket) {"test"}

  let(:blob_access) {Blobsterix::BlobAccess.new(:bucket => bucket, :id => key)}
  let(:blob_access_1) {Blobsterix::BlobAccess.new(:bucket => bucket, :id => key, :trafo => [["test", ""]])}
  let(:blob_access_2) {Blobsterix::BlobAccess.new(:bucket => bucket, :id => key, :trafo => [["dummy", ""]])}
  let(:blob_access_3) {Blobsterix::BlobAccess.new(:bucket => bucket, :id => key, :trafo => [["test", ""],["dummy", ""]])}

  around(:each) do |example|
    run_em(&example)
  end

  describe "invalidation" do
    before :each do
      Blobsterix.cache.put_raw(blob_access, data)
      Blobsterix.cache.put_raw(blob_access_1, data)
      Blobsterix.cache.put_raw(blob_access_2, data)
      Blobsterix.cache.put_raw(blob_access_3, data)
    end

    after :each do
      clear_cache
      Blobsterix.cache_checker=lambda{|blob_access, meta_data, last_accessed_at, created_at|
        false
      }
    end

    it "should follow invalidation structure" do
      Blobsterix.cache_checker=lambda{|blob_access_, meta_data, last_accessed_at, created_at|
        blob_access_1.equals?(blob_access_) || blob_access_3.equals?(blob_access_)
      }
      Blobsterix.cache.invalidation
      expect(blob_access.get().valid).to eql(true)
      expect(blob_access_1.get().valid).to eql(false)
      expect(blob_access_2.get().valid).to eql(true)
      expect(blob_access_3.get().valid).to eql(false)
    end

    it "should invalidate all" do
      Blobsterix.cache_checker=lambda{|blob_access_, meta_data, last_accessed_at, created_at|
        true
      }
      Blobsterix.cache.invalidation
      expect(blob_access.get().valid).to eql(false)
      expect(blob_access_1.get().valid).to eql(false)
      expect(blob_access_2.get().valid).to eql(false)
      expect(blob_access_3.get().valid).to eql(false)
    end

    it "should invalidate none" do
      Blobsterix.cache.invalidation
      expect(blob_access.get().valid).to eql(true)
      expect(blob_access_1.get().valid).to eql(true)
      expect(blob_access_2.get().valid).to eql(true)
      expect(blob_access_3.get().valid).to eql(true)
    end
  end

  describe "cache" do
    after :each do
      clear_cache
    end

    it "should return invalid blob when key doesn't exist" do
      expect(Blobsterix.cache.get(blob_access).valid).to be(false)
    end

    it "should return valid blob when key exists" do
      Blobsterix.cache.put_raw(blob_access, data)
      metaData = Blobsterix.cache.get(blob_access)
      expect(metaData.valid).to be(true)
      expect(metaData.read).to eql(data)
    end

    it "should return valid blob when key exists and was copied via Stream" do
      Blobsterix.cache.put_stream(blob_access, StringIO.new(data, "r"))
      metaData = Blobsterix.cache.get(blob_access)
      expect(metaData.valid).to be(true)
      expect(metaData.read).to eql(data)
    end

    it "should return valid blob when key exists and was copied via path" do
      tmp = Tempfile.new("sldhgs")
      tmp.write(data)
      tmp.close
      Blobsterix.cache.put(blob_access, tmp.path)
      metaData = Blobsterix.cache.get(blob_access)
      expect(metaData.valid).to be(true)
      expect(metaData.read).to eql(data)
      tmp.unlink
    end

    it "should return invalid blob when key is invalidated" do
      Blobsterix.cache.put_raw(blob_access, data)
      metaData = Blobsterix.cache.get(blob_access)
      expect(metaData.valid).to be(true)
      expect(metaData.read).to eql(data)

      Blobsterix.cache.invalidate(blob_access)

      expect(Blobsterix.cache.get(blob_access).valid).to be(false)
    end

    it "should return invalid blob when key is invalidated for all trafos" do
      Blobsterix.cache.put_raw(blob_access, data)
      Blobsterix.cache.put_raw(blob_access_1, data)

      metaData = Blobsterix.cache.get(blob_access)
      expect(metaData.valid).to be(true)
      expect(metaData.read).to eql(data)

      metaData = Blobsterix.cache.get(blob_access_1)
      expect(metaData.valid).to be(true)
      expect(metaData.read).to eql(data)

      Blobsterix.cache.invalidate(blob_access)

      expect(Blobsterix.cache.get(blob_access).valid).to be(false)
      expect(Blobsterix.cache.get(blob_access_1).valid).to be(false)
    end

    it "should return invalid blob when key is invalidated for one trafos" do
      Blobsterix.cache.put_raw(blob_access, data)
      Blobsterix.cache.put_raw(blob_access_1, data)

      metaData = Blobsterix.cache.get(blob_access)
      expect(metaData.valid).to be(true)
      expect(metaData.read).to eql(data)

      metaData = Blobsterix.cache.get(blob_access_1)
      expect(metaData.valid).to be(true)
      expect(metaData.read).to eql(data)

      Blobsterix.cache.invalidate(blob_access, true)

      expect(Blobsterix.cache.get(blob_access).valid).to be(false)
      expect(Blobsterix.cache.get(blob_access_1).valid).to be(true)
    end

    it "should return invalid blob when key is deleted" do
      Blobsterix.cache.put_raw(blob_access, data)
      metaData = Blobsterix.cache.get(blob_access)
      expect(metaData.valid).to be(true)
      expect(metaData.read).to eql(data)

      Blobsterix.cache.delete(blob_access)

      expect(Blobsterix.cache.get(blob_access).valid).to be(false)
    end
  end
end
