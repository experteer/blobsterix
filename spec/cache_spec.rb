require "spec_helper"

describe Blobsterix::Storage::Cache do
  include Blobsterix::SpecHelper

  let(:data) {"Hi my name is Test"}
  let(:key) {"test.txt"}
  let(:bucket) {"test"}

  let(:blob_access) {Blobsterix::BlobAccess.new(:bucket => bucket, :id => key)}
  let(:blob_access_1) {Blobsterix::BlobAccess.new(:bucket => bucket, :id => key, :trafo => [["test", ""]])}

  describe "cache" do
    after :each do
      clear_cache
    end

    it "should return invalid blob when key doesn't exist" do
      expect(Blobsterix.cache.get(blob_access).valid).to be(false)
    end

    it "should return valid blob when key exists" do
      Blobsterix.cache.put(blob_access, data)
      metaData = Blobsterix.cache.get(blob_access)
      expect(metaData.valid).to be(true)
      expect(metaData.read).to eql(data)
    end

    it "should return invalid blob when key is invalidated" do
      Blobsterix.cache.put(blob_access, data)
      metaData = Blobsterix.cache.get(blob_access)
      expect(metaData.valid).to be(true)
      expect(metaData.read).to eql(data)

      Blobsterix.cache.invalidate(blob_access)

      expect(Blobsterix.cache.get(blob_access).valid).to be(false)
    end

    it "should return invalid blob when key is invalidated for all trafos" do
      Blobsterix.cache.put(blob_access, data)
      Blobsterix.cache.put(blob_access_1, data)

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
      Blobsterix.cache.put(blob_access, data)
      Blobsterix.cache.put(blob_access_1, data)

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
      Blobsterix.cache.put(blob_access, data)
      metaData = Blobsterix.cache.get(blob_access)
      expect(metaData.valid).to be(true)
      expect(metaData.read).to eql(data)

      Blobsterix.cache.delete(blob_access)

      expect(Blobsterix.cache.get(blob_access).valid).to be(false)
    end
  end
end