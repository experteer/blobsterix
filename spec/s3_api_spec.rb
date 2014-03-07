require "spec_helper"

describe Blobsterix::S3Api do
  include Rack::Test::Methods
  include Blobsterix::SpecHelper
  def app
    Blobsterix::S3Api
  end
  describe 'listing all buckets' do
    context "with no data" do
      it 'should return an empty set' do
        get "/"
        expect(last_response.status).to eql(200)
        response = Hash.from_xml last_response.body
        expect(response).to have_key(:ListAllMyBucketsResult)
        expect(response[:ListAllMyBucketsResult]).to have_key(:Buckets)
        expect(response[:ListAllMyBucketsResult][:Buckets]).to be_empty
      end
    end

    context "with data" do
      let(:data) {"Hi my name is Test"}
      let(:key) {"test.txt"}
      let(:bucket) {"test"}
      before :each do
        Blobsterix.storage.put(bucket, key, StringIO.new(data, "r"))
      end
      after :each do
        clear_storage
      end
      it 'should return one bucket in the list' do
        get "/"
        expect(last_response.status).to eql(200)
        response = Hash.from_xml last_response.body
        expect(response).to have_key(:ListAllMyBucketsResult)
        expect(response[:ListAllMyBucketsResult]).to have_key(:Buckets)
        expect(response[:ListAllMyBucketsResult][:Buckets]).to_not be_empty
      end
      it 'should return a file for the bucket' do
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
    end
  end
end