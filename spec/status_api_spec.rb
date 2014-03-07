require "spec_helper"

describe Blobsterix::StatusApi do
  include Rack::Test::Methods
  def app
    Blobsterix::StatusApi
  end
  describe 'GET /status' do
    it 'should get status as json' do
      get "/status.json"
      expect(last_response.status).to eql(200)
      body = JSON.parse(last_response.body)
      expect(body).to have_key("cache_accesses")
      expect(body).to have_key("cache_errors")
      expect(body).to have_key("cache_hit_rate")
      expect(body).to have_key("cache_hits")
      expect(body).to have_key("cache_misses")
      expect(body).to have_key("connections")
      expect(body).to have_key("ram_usage")
      expect(body).to have_key("uptime")
    end
    it 'should get status as xml' do
      get "/status.xml"
      expect(last_response.status).to eql(200)
      body = Hash.from_xml(last_response.body)
      expect(body).to have_key(:BlobsterixStatus)
      expect(body[:BlobsterixStatus]).to have_key(:cache_accesses)
      expect(body[:BlobsterixStatus]).to have_key(:cache_errors)
      expect(body[:BlobsterixStatus]).to have_key(:cache_hit_rate)
      expect(body[:BlobsterixStatus]).to have_key(:cache_hits)
      expect(body[:BlobsterixStatus]).to have_key(:cache_misses)
      expect(body[:BlobsterixStatus]).to have_key(:connections)
      expect(body[:BlobsterixStatus]).to have_key(:ram_usage)
      expect(body[:BlobsterixStatus]).to have_key(:uptime)
    end

    it 'should get status as html' do
      get "/status"
      expect(last_response.status).to eql(200)
    end
  end
end