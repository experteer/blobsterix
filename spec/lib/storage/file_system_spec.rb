require "spec_helper"

describe Blobsterix::Storage::FileSystem do
  include Blobsterix::SpecHelper

  let(:data) {"Hi my name is Test"}
  let(:key) {"test.txt"}
  let(:bucket) {"test"}



  describe "bucket" do
    after :each do
      clear_storage
    end

    it "should return error if bucket doesn't exist" do
      response = Hash.from_xml Blobsterix.storage.list(bucket).to_xml
      expect(response).to have_key(:Error)
      expect(response[:Error]).to eql("no such bucket")
    end

    it "should return the bucket info if it exists" do
      Blobsterix.storage.create(bucket)
      response = Hash.from_xml Blobsterix.storage.list(bucket).to_xml
      expect(response).to have_key(:ListBucketResult)
      expect(response[:ListBucketResult]).to have_key(:Name)
      expect(response[:ListBucketResult][:Name]).to eql(bucket)
    end

    it "should return error after bucket is destroyed" do
      Blobsterix.storage.create(bucket)
      response = Hash.from_xml Blobsterix.storage.list(bucket).to_xml
      expect(response).to have_key(:ListBucketResult)
      expect(response[:ListBucketResult]).to have_key(:Name)
      expect(response[:ListBucketResult][:Name]).to eql(bucket)

      Blobsterix.storage.delete(bucket)
      response = Hash.from_xml Blobsterix.storage.list(bucket).to_xml
      expect(response).to have_key(:Error)
      expect(response[:Error]).to eql("no such bucket")
    end

    it "should return the key info if it exists when listing bucket" do
      Blobsterix.storage.put(bucket, key, StringIO.new(data, "r"))
      response = Hash.from_xml Blobsterix.storage.list(bucket).to_xml
      expect(response).to have_key(:ListBucketResult)
      expect(response[:ListBucketResult]).to have_key(:Name)
      expect(response[:ListBucketResult][:Name]).to eql(bucket)
      expect(response[:ListBucketResult][:Contents]).to_not be_empty
      expect(response[:ListBucketResult][:Contents][:Key]).to eql(key)
      expect(response[:ListBucketResult][:Contents][:MimeType]).to eql("text/plain")
      expect(response[:ListBucketResult][:Contents][:Size]).to eql(data.length)
      expect(response[:ListBucketResult][:Contents][:ETag]).to eql(Digest::MD5.hexdigest(data))
    end
  end
  
  describe "keys" do
    after :each do
      clear_storage
    end

    it "should return invalid meta blob when key doesn't exist" do
      expect(Blobsterix.storage.get(bucket, key).valid).to be(false)
    end

    it "should return valid meta blob when key exist" do
      Blobsterix.storage.put(bucket, key, StringIO.new(data, "r"))
      metaData = Blobsterix.storage.get(bucket, key)
      expect(metaData.valid).to be(true)
      expect(metaData.read).to eql(data)
    end

    it "should return invalid meta blob when key is deleted" do
      Blobsterix.storage.put(bucket, key, StringIO.new(data, "r"))
      metaData = Blobsterix.storage.get(bucket, key)
      expect(metaData.valid).to be(true)
      expect(metaData.read).to eql(data)

      Blobsterix.storage.delete_key(bucket, key)
      expect(Blobsterix.storage.get(bucket, key).valid).to be(false)
    end
  end
end
