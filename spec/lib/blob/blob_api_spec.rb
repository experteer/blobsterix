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
      let(:data_transformed) {"Hi_my_name_is_Test_Transformed"}
      let(:key) {"test.txt"}
      let(:bucket) {"test"}

      before :all do
        Blobsterix.transformation.add Blobsterix::SpecHelper::DummyTrafo.new
      end

      after :all do
        Blobsterix.transformation=Blobsterix::Transformations::TransformationManager.new
      end

      before :each do
        Blobsterix.storage.put(bucket, key, StringIO.new(data, "r"))
      end

      after :each do
        clear_data
      end

      it "should return the file" do
        expect(Blobsterix.transformation).to receive(:cue_transformation).once.and_call_original
        run_em do 
          get "/blob/v1/dummy_#{data_transformed}.test/test.txt"
        end
        expect(last_response.status).to eql(200)
        expect(last_response.body).to eql(data_transformed)
      end

      it "should return the file head" do
        expect(Blobsterix.transformation).to receive(:cue_transformation).once.and_call_original
        run_em do 
          head "/blob/v1/dummy.test/test.txt"
        end
        expect(last_response.status).to eql(200)
        expect(last_response.body).to eql("")
      end

      it "should return the file and wait for previous trafos to finish" do
        expect(Blobsterix.transformation).to receive(:cue_transformation).once.and_call_original
        expect(Blobsterix.transformation).to receive(:wait_for_transformation).once.and_call_original
        run_em do 
          get "/blob/v1/dummy_#{data_transformed}.test/test.txt"
          get "/blob/v1/dummy_#{data_transformed}.test/test.txt"
        end
        expect(last_response.status).to eql(200)
        expect(last_response.body).to eql(data_transformed)
      end

      it "should return the file and not wait for different trafos to finish" do
        expect(Blobsterix.transformation).to receive(:cue_transformation).twice.and_call_original
        expect(Blobsterix.transformation).to receive(:wait_for_transformation).never.and_call_original
        run_em do 
          get "/blob/v1/dummy_#{data_transformed},dummy_#{data_transformed}.test/test.txt"
          get "/blob/v1/dummy_#{data_transformed}.test/test.txt"
        end
        expect(last_response.status).to eql(200)
        expect(last_response.body).to eql(data_transformed)
      end
    end
  end
end
