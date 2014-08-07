require "spec_helper"

describe Blobsterix::S3Api do
  include Rack::Test::Methods
  include Blobsterix::SpecHelper
  def app
    Blobsterix::S3Api
  end

  let(:data) {"Hi my name is Test"}
  let(:key) {"test.txt"}
  let(:bucket) {"test"}

  around(:each) do |example|
    run_em(&example)
  end

  after :each do
      clear_data
  end

  describe "create a bucket" do
    it "should have bucket after creation" do

      put "/", "", "HTTP_HOST" => "#{bucket}.s3.blah.de"

      get "/#{bucket}"
      expect(last_response.status).to eql(200)
      response = Hash.from_xml last_response.body
      expect(response).to_not have_key(:Error)
    end
  end

  describe "upload" do

    before :all do
      Blobsterix.transformation.add Blobsterix::SpecHelper::DummyTrafo.new
    end

    after :all do
      Blobsterix.transformation=Blobsterix::Transformations::TransformationManager.new
    end

    after :each do
      clear_data
    end

    it "should have file in bucket after upload" do
      #expect(Blobsterix.transformation).to receive(:cue_transformation).never.and_call_original

      put "/#{key}", data, {"HTTP_HOST" => "#{bucket}.s3.blah.de"}

      expect(last_response.status).to eql(200)
      expect(Blobsterix.storage.get(bucket, key).read).to eql(data)
    end

    it "should have file in bucket after upload with trafo" do
      #expect(Blobsterix.transformation).to receive(:cue_transformation).once.and_call_original

      put "/#{key}", data, {"HTTP_HOST" => "#{bucket}.s3.blah.de", "HTTP_X_AMZ_META_TRAFO" => "dummy_Yeah"}

      expect(last_response.status).to eql(200)
      expect(Blobsterix.storage.get(bucket, key).read).to eql("Yeah")
    end
  end

  context "with no data" do

    describe "bucket" do
      it 'should return an empty set' do
        get "/"
        expect(last_response.status).to eql(200)
        response = Hash.from_xml last_response.body
        expect(response).to have_key(:ListAllMyBucketsResult)
        expect(response[:ListAllMyBucketsResult]).to have_key(:Buckets)
        expect(response[:ListAllMyBucketsResult][:Buckets]).to be_empty
      end

      it 'should say no such bucket' do
        get "/#{bucket}"
        expect(last_response.status).to eql(200)
        response = Hash.from_xml last_response.body
        expect(response).to have_key(:Error)
        expect(response[:Error]).to eql("no such bucket")
      end

      it "should return 404 on delete bucket" do
        expect(Blobsterix.storage.bucket_exist(bucket)).to eql(false)

        delete "/", "", "HTTP_HOST" => "s3.blah.de"

        expect(last_response.status).to eql(404)
        expect(Blobsterix.storage.bucket_exist(bucket)).to eql(false)
      end
    end

    describe 'file' do
      it "should return a 404 when bucket doesn't exist" do
        get "/#{key}", "", "HTTP_HOST" => "#{bucket}.s3.blah.de"
        expect(last_response.status).to eql(404)
      end

      it 'should return a 404 when bucket exists' do
        Blobsterix.storage.create(bucket)
        get "/#{key}", "", "HTTP_HOST" => "#{bucket}.s3.blah.de"
        expect(last_response.status).to eql(404)
        Blobsterix.storage.delete(bucket)
      end
    end
  end

  context "with two data objects" do
    before :each do
      Blobsterix.storage.put(bucket, key, StringIO.new(data, "r"))
      Blobsterix.storage.put(bucket, "u#{key}", StringIO.new(data, "r"))
    end

    after :each do
      clear_storage
    end

    describe 'list bucket truncated' do
      it 'should return all files for the bucket starting at u#{key}' do
        get "/#{bucket}", "", "HTTP_START_PATH" => "u#{key}"
        expect(last_response.status).to eql(200)
        response = Hash.from_xml last_response.body
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
  end

  context "with data" do

    before :each do
      Blobsterix.storage.put(bucket, key, StringIO.new(data, "r"))
    end

    after :each do
      clear_storage
    end

    describe "bucket" do

      it 'should return one bucket in the list' do
        get "/"
        expect(last_response.status).to eql(200)
        response = Hash.from_xml last_response.body
        expect(response).to have_key(:ListAllMyBucketsResult)
        expect(response[:ListAllMyBucketsResult]).to have_key(:Buckets)
        expect(response[:ListAllMyBucketsResult][:Buckets]).to_not be_empty
      end

      it 'should return all files for the bucket' do
        get "/#{bucket}"
        expect(last_response.status).to eql(200)
        response = Hash.from_xml last_response.body
        expect(response).to have_key(:ListBucketResult)
        expect(response[:ListBucketResult]).to have_key(:Name)
        expect(response[:ListBucketResult][:Name]).to eql(bucket)
        expect(response[:ListBucketResult][:Contents]).to_not be_empty
        expect(response[:ListBucketResult][:Contents][:Key]).to eql(key)
        expect(response[:ListBucketResult][:Contents][:MimeType]).to eql("text/plain")
        expect(response[:ListBucketResult][:Contents][:Size]).to eql(data.length)
        expect(response[:ListBucketResult][:Contents][:ETag]).to eql(Digest::MD5.hexdigest(data))
      end

      it "should delete bucket" do
        Blobsterix.storage.delete_key(bucket, key)
        expect(Blobsterix.storage.bucket_exist(bucket)).to eql(true)

        delete "/", "", "HTTP_HOST" => "#{bucket}.s3.blah.de"

        expect(last_response.status).to eql(204)
        expect(Blobsterix.storage.bucket_exist(bucket)).to eql(false)
      end

    end

    describe "file" do

      it "should return file" do
        get "/#{key}", "", "HTTP_HOST" => "#{bucket}.s3.blah.de"
        expect(last_response.status).to eql(200)
        expect(last_response.body).to eql(data)
      end

      it "should return file head" do
        head "/#{key}", "", "HTTP_HOST" => "#{bucket}.s3.blah.de"
        expect(last_response.status).to eql(200)
        expect(last_response.body).to eql("")
      end

      it "should delete key" do
        delete "/#{key}", "", "HTTP_HOST" => "#{bucket}.s3.blah.de"

        expect(last_response.status).to eql(204)
        expect(Blobsterix.storage.get(bucket, key).valid).to eql(false)
      end
    end
  end
end
