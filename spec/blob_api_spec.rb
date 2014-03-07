require "spec_helper"

describe Blobsterix::BlobApi do
  include Rack::Test::Methods
  def app
    Blobsterix::BlobApi
  end
  describe 'GET /blob/v1/' do
    it 'get several categories of repositories by name' do
      get "/blob/v1/"
      expect(last_response.status).to eql(403)
    end
  end

  describe 'Transformed get' do
    include Blobsterix::SpecHelper

    context "with data" do
      let(:data) {"Hi my name is Test"}
      let(:key) {"test.txt"}
      let(:bucket) {"test"}

      before :each do
        clear_data
        Blobsterix.storage.put(bucket, key, StringIO.new(data, "r"))
      end

      after :each do
        clear_data
      end

      it "should return the file" do
        expect(Blobsterix.transformation).to receive(:cue_transformation).once.and_call_original
        run_em do 
          get "/blob/v1/test/test.txt"
        end
        expect(last_response.status).to eql(200)
        expect(last_response.body).to eql(data)
      end

      it "should return the file and wait for previous trafos to finish" do
        expect(Blobsterix.transformation).to receive(:cue_transformation).once.and_call_original
        expect(Blobsterix.transformation).to receive(:wait_for_transformation).once.and_call_original
        run_em do 
          get "/blob/v1/test/test.txt"
          get "/blob/v1/test/test.txt"
        end
        expect(last_response.status).to eql(200)
        expect(last_response.body).to eql(data)
      end

      it "should return the file and not wait for different trafos to finish" do
        expect(Blobsterix.transformation).to receive(:cue_transformation).twice.and_call_original
        expect(Blobsterix.transformation).to receive(:wait_for_transformation).never.and_call_original
        run_em do 
          get "/blob/v1/raw.test/test.txt"
          get "/blob/v1/test/test.txt"
        end
        expect(last_response.status).to eql(200)
        expect(last_response.body).to eql(data)
      end
    end
  end
end