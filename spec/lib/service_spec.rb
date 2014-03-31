require "spec_helper"

describe  Blobsterix::Service do
  include Goliath::TestHelper
  it "it should route to the status page" do
    with_api( Blobsterix::Service) do |a|
      resp = get_request(:path=>"/status.json") do
      end
      expect(JSON.parse(resp.response)).to include("cache_hits")
    end
  end
end
