require "spec_helper"

describe Blobsterix::S3Auth do
  include Blobsterix::SpecHelper
  include Goliath::TestHelper

  let(:v2_delete_file) do
    {
      :path => "/profile_photo%2F1023066_1407492523",
      :head => {
        "host"          => "career.blob.localhost.local",
        "date"          => "Fri, 08 Aug 2014 10:09:03 +0000",
        "authorization" => "AWS somethingIdid:LxTRXgW+E0SHU2xSkMI5Q62wKhU="
      }
    }
  end

  let(:v2_list_bucket) do
    {
      :path => "/",
      :head => {
        "host"          => "johnsmith.s3.amazonaws.com",
        "date"          => "Tue, 27 Mar 2007 19:42:41 +0000",
        "authorization" => "AWS AKIAIOSFODNN7EXAMPLE:htDYFYduRNen8P9ZfE/s9SuKy0U="
      }
    }
  end

  let(:v2_upload_photo) do
    {
      :path => "/photos/puppy.jpg",
      :head => {
        "host"          => "johnsmith.s3.amazonaws.com",
        "content-type"  => "image/jpeg",
        "date"          => "Tue, 27 Mar 2007 21:15:45 +0000",
        "authorization" => "AWS AKIAIOSFODNN7EXAMPLE:MyyxeRY7whkBe+bq8fHCL/2kKUg="
      }
    }
  end

  let(:v2_list_root_date) do
    {
      :path => "/",
      :head => {
        "date"          => "Wed, 28 Mar 2007 01:29:59 +0000",
        "authorization" => "AWS AKIAIOSFODNN7EXAMPLE:qGdzdERIC03wnaRNKh6OqZehG9s="
      }
    }
  end

  let(:v2_list_root_amz_date) do
    {
      :path => "/",
      :head => {
        "x-amz-date"    => "Fri, 08 Aug 2014 10:28:22 +0000",
        "authorization" => "AWS somethingIdid:CEyyoVY9bnq4Ujjgwwo5ozYXEfI="
      }
    }
  end

  let(:v2_query_download_file) do
    {
      :path  => "/photos/puppy.jpg",
      :query => "AWSAccessKeyId=AKIAIOSFODNN7EXAMPLE&Signature=NpgCjnDzrM%2BWFzoENXmpNDUsSn8%3D&Expires=1175139620",
      :head  => {
        "host" => "johnsmith.s3.amazonaws.com"
      }
    }
  end

  let(:v2_req_env) do
    {
      "HTTP_USER_AGENT"       => "fog/1.22.1",
      "HTTP_PROXY_CONNECTION" => "Keep-Alive",
      "HTTP_DATE"             => "Fri, 08 Aug 2014 10:09:03 +0000",
      "HTTP_AUTHORIZATION"    => "AWS somethingIdid:LxTRXgW+E0SHU2xSkMI5Q62wKhU=",
      "HTTP_HOST"             => "career.blob.localhost.local:80",
      "HTTP_TE"               => "trailers, deflate, gzip",
      "HTTP_CONNECTION"       => "TE, close",
      "CONTENT_LENGTH"        => "0",
      "REQUEST_METHOD"        => "DELETE",
      "REQUEST_URI"           => "http://career.blob.localhost.local:80/profile_photo%2F1023066_1407492523",
      "QUERY_STRING"          => nil,
      "HTTP_VERSION"          => "1.1",
      "SCRIPT_NAME"           => "",
      "REQUEST_PATH"          => "/profile_photo%2F1023066_1407492523",
      "PATH_INFO"             => "/profile_photo%2F1023066_1407492523",
      nil                     => {
        :file => "profile_photo%2F1023066_1407492523"
      }
    }
  end

  let(:v4_req_env) do
    {
      "HTTP_USER_AGENT"           => "fog/1.22.1",
      "HTTP_PROXY_CONNECTION"     => "Keep-Alive",
      "HTTP_DATE"                 => "Fri, 24 May 2013 00:00:00 GMT",
      "HTTP_AUTHORIZATION"        => "AWS4-HMAC-SHA256 Credential=AKIAIOSFODNN7EXAMPLE/20130524/us-east-1/s3/aws4_request,SignedHeaders=host;range;x-amz-content-sha256;x-amz-date,Signature=f0e8bdb87c964420e857bd35b5d6ed310bd44f0170aba48dd91039c6036bdb41",
      "HTTP_HOST"                 => "examplebucket.s3.amazonaws.com:80",
      "HTTP_TE"                   => "trailers, deflate, gzip",
      "HTTP_CONNECTION"           => "TE, close",
      "CONTENT_LENGTH"            => "0",
      "REQUEST_METHOD"            => "GET",
      "REQUEST_URI"               => "http://examplebucket.s3.amazonaws.com:80/test.txt",
      "QUERY_STRING"              => nil,
      "HTTP_VERSION"              => "1.1",
      "SCRIPT_NAME"               => "",
      "REQUEST_PATH"              => "/test.txt",
      "PATH_INFO"                 => "/test.txt",
      "HTTP_RANGE"                => "bytes=0-9",
      "HTTP_X_AMZ_CONTENT_SHA256" => "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
      "HTTP_X_AMZ_DATE"           => "20130524T000000Z",
      nil                         => {
        :file => "test.txt"
      }
    }
  end

  before :all do
    Blobsterix.secret_key_store = Blobsterix::S3Auth::KeyStore.new(
      "AKIAIOSFODNN7EXAMPLE" => "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
      "somethingIdid"        => "somethingIdidInSecret"
    )
  end

  after :all do
    Blobsterix.secret_key_store = nil
  end

  def run_request(method, params, test, _key)
    with_api(Blobsterix::Service, :log_stdout => false) do |a|
      Blobsterix.logger = a.logger
      send(method, params) do |resp|
        resp.response_header.status.should eql test
      end
    end
  end

  it "should work with aws v2 query" do
    Blobsterix::S3Auth.current_time = lambda { Time.parse("Tue, 27 Mar 2007 21:15:45 +0000") }
    run_request("put_request", v2_upload_photo, 200, "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY")
    Blobsterix::S3Auth.current_time = lambda { Time.at(1_175_139_610) }
    run_request("get_request", v2_query_download_file, 200, "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY")
  end

  it "should work with aws v2" do
    Blobsterix::S3Auth.current_time = lambda { Time.parse("Fri, 08 Aug 2014 10:28:22 +0000") }
    run_request("get_request", v2_list_root_amz_date, 200, "somethingIdidInSecret")
    Blobsterix::S3Auth.current_time = lambda { Time.parse("Wed, 28 Mar 2007 01:29:59 +0000") }
    run_request("get_request", v2_list_root_date, 200, "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY")
    Blobsterix::S3Auth.current_time = lambda { Time.parse("Tue, 27 Mar 2007 21:15:45 +0000") }
    run_request("put_request", v2_upload_photo, 200, "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY")
    Blobsterix::S3Auth.current_time = lambda { Time.parse("Tue, 27 Mar 2007 19:42:41 +0000") }
    run_request("get_request", v2_list_bucket, 200, "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY")
    Blobsterix::S3Auth.current_time = lambda { Time.parse("Fri, 08 Aug 2014 10:09:03 +0000") }
    run_request("delete_request", v2_delete_file, 204, "somethingIdidInSecret")
  end

  it "should expire after 15 minutes" do
    Blobsterix::S3Auth.current_time = lambda { Time.parse("Fri, 08 Aug 2014 10:28:22 +0000") + 60 * 16 }
    run_request("get_request", v2_list_root_amz_date, 401, "somethingIdidInSecret")
  end

  it "should expire query when expire time is passed" do
    Blobsterix::S3Auth.current_time = lambda { Time.parse("Tue, 27 Mar 2007 21:15:45 +0000") }
    run_request("put_request", v2_upload_photo, 200, "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY")
    Blobsterix::S3Auth.current_time = lambda { Time.at(1_175_139_621) }
    run_request("get_request", v2_query_download_file, 401, "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY")
  end

  it "should at least recognize aws v4" do
    auth = Blobsterix::S3Auth.authenticate(v4_req_env)
    auth.class.should eql Blobsterix::S3Auth::V4
  end

  it "should at least recognize aws v2" do
    auth = Blobsterix::S3Auth.authenticate(v2_req_env)
    auth.class.should eql Blobsterix::S3Auth::V2
  end
end
