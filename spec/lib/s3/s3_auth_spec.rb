require "spec_helper"

describe Blobsterix::S3Auth do
  include Blobsterix::SpecHelper
  include Goliath::TestHelper

  let(:v2_delete_file) {
    {
      # :proxy => {:host => "localhost", :port => 9900},
      :path=>"/profile_photo%2F1023066_1407492523",
      :head => {
        "host"=>"career.blob.localhost.local",
        "date" => "Fri, 08 Aug 2014 10:09:03 +0000",
        "authorization" => "AWS somethingIdid:LxTRXgW+E0SHU2xSkMI5Q62wKhU=",               
      }
    }
  }

  let(:v2_list_bucket) {
    {
      # :proxy => {:host => "localhost", :port => 9900},
      :path=>"/",
      :head => {
        "host"=>"johnsmith.s3.amazonaws.com",
        "date" => "Tue, 27 Mar 2007 19:42:41 +0000",
        "authorization" => "AWS AKIAIOSFODNN7EXAMPLE:htDYFYduRNen8P9ZfE/s9SuKy0U=",               
      }
    }
  }

  let(:v2_upload_photo) {
    {
      # :proxy => {:host => "localhost", :port => 9900},
      :path=>"/photos/puppy.jpg",
      :head => {
        "host"=>"johnsmith.s3.amazonaws.com",
        "content-type" => "image/jpeg",
        "date" => "Tue, 27 Mar 2007 21:15:45 +0000",
        "authorization" => "AWS AKIAIOSFODNN7EXAMPLE:MyyxeRY7whkBe+bq8fHCL/2kKUg=",               
      }
    }
  }

  let(:v2_list_root_date) {
    {
      :path=>"/",
      :head => {
        "date" => "Wed, 28 Mar 2007 01:29:59 +0000",
        "authorization" => "AWS AKIAIOSFODNN7EXAMPLE:qGdzdERIC03wnaRNKh6OqZehG9s=",               
      }
    }
  }

  let(:v2_list_root_amz_date) {
    {
      :path=>"/",
      :head => {
        "x-amz-date" => "Fri, 08 Aug 2014 10:28:22 +0000",
        "authorization" => "AWS somethingIdid:CEyyoVY9bnq4Ujjgwwo5ozYXEfI=",               
      }
    }
  }

  let(:v2_req_env) {
    {
      "HTTP_USER_AGENT"=>"fog/1.22.1",
      "HTTP_PROXY_CONNECTION"=>"Keep-Alive",
      "HTTP_DATE"=>"Fri, 08 Aug 2014 10:09:03 +0000",
      "HTTP_AUTHORIZATION"=>"AWS somethingIdid:LxTRXgW+E0SHU2xSkMI5Q62wKhU=",
      "HTTP_HOST"=>"career.blob.localhost.local:80",
      "HTTP_TE"=>"trailers, deflate, gzip",
      "HTTP_CONNECTION"=>"TE, close",
      "CONTENT_LENGTH"=>"0",
      "REQUEST_METHOD"=>"DELETE",
      "REQUEST_URI"=>"http://career.blob.localhost.local:80/profile_photo%2F1023066_1407492523",
      "QUERY_STRING"=>nil,
      "HTTP_VERSION"=>"1.1",
      "SCRIPT_NAME"=>"",
      "REQUEST_PATH"=>"/profile_photo%2F1023066_1407492523",
      "PATH_INFO"=>"/profile_photo%2F1023066_1407492523",
      nil => {
        :file => "profile_photo%2F1023066_1407492523"
      }
    }
  }

  let(:v4_req_env) {
    {
      "HTTP_USER_AGENT"=>"fog/1.22.1",
      "HTTP_PROXY_CONNECTION"=>"Keep-Alive",
      "HTTP_DATE"=>"Fri, 24 May 2013 00:00:00 GMT",
      "HTTP_AUTHORIZATION"=>"AWS4-HMAC-SHA256 Credential=AKIAIOSFODNN7EXAMPLE/20130524/us-east-1/s3/aws4_request,SignedHeaders=host;range;x-amz-content-sha256;x-amz-date,Signature=f0e8bdb87c964420e857bd35b5d6ed310bd44f0170aba48dd91039c6036bdb41",
      "HTTP_HOST"=>"examplebucket.s3.amazonaws.com:80",
      "HTTP_TE"=>"trailers, deflate, gzip",
      "HTTP_CONNECTION"=>"TE, close",
      "CONTENT_LENGTH"=>"0",
      "REQUEST_METHOD"=>"GET",
      "REQUEST_URI"=>"http://examplebucket.s3.amazonaws.com:80/test.txt",
      "QUERY_STRING"=>nil,
      "HTTP_VERSION"=>"1.1",
      "SCRIPT_NAME"=>"",
      "REQUEST_PATH"=>"/test.txt",
      "PATH_INFO"=>"/test.txt",
      "HTTP_RANGE" => "bytes=0-9",
      "HTTP_X_AMZ_CONTENT_SHA256" => "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
      "HTTP_X_AMZ_DATE" => "20130524T000000Z",
      nil => {
        :file => "test.txt"
      }
    }
  }

  it "should work with aws v2" do
    Blobsterix.secret_key = "somethingIdidInSecret"
    with_api( Blobsterix::Service, :log_stdout => false) do |a|
      # Blobsterix.logger = a.logger
      get_request(v2_list_root_amz_date) do |resp|
        resp.response_header.status.should eql 200
      end
    end

    Blobsterix.secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    with_api( Blobsterix::Service, :log_stdout => false) do |a|
      Blobsterix.logger = a.logger
      get_request(v2_list_root_date) do |resp|
        resp.response_header.status.should eql 200
      end
    end

    Blobsterix.secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    with_api( Blobsterix::Service, :log_stdout => false) do |a|
      Blobsterix.logger = a.logger
      put_request(v2_upload_photo) do |resp|
        resp.response_header.status.should eql 200
      end
    end

    Blobsterix.secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    with_api( Blobsterix::Service, :log_stdout => false) do |a|
      Blobsterix.logger = a.logger
      get_request(v2_list_bucket) do |resp|
        resp.response_header.status.should eql 200
      end
    end

    Blobsterix.secret_key = "somethingIdidInSecret"
    with_api( Blobsterix::Service, :log_stdout => false) do |a|
      Blobsterix.logger = a.logger
      delete_request(v2_delete_file) do |resp|
        resp.response_header.status.should eql 204
      end
    end
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