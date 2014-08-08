module Blobsterix
  module S3Auth
    class V4
      include ::Blobsterix::S3UrlHelper
      include ::Blobsterix::UrlHelper
      

      V4_REGEX = /AWS4-HMAC-SHA256 Credential=(\w+\/\d+\/.+\/\w+\/aws4_request),.*SignedHeaders=(.+),.*Signature=(\w+)/

      def self.create(env)
        auth_string = env["HTTP_AUTHORIZATION"]
        matcher = V4_REGEX.match(auth_string)
        matcher ? V4.new(env, matcher[1], matcher[2], matcher[3]) : nil
      end

      attr_reader :env, :credential, :signed_headers, :signature
      def initialize(env, credential, signed_headers, signature)
        @env = env
        @credential = credential
        @signed_headers = signed_headers
        @signature = signature
      end
      def getSignatureKey(key, dateStamp, regionName, serviceName)
        kDate    = OpenSSL::HMAC.digest('sha256', "AWS4" + key, dateStamp)
        kRegion  = OpenSSL::HMAC.digest('sha256', kDate, regionName)
        kService = OpenSSL::HMAC.digest('sha256', kRegion, serviceName)
        kSigning = OpenSSL::HMAC.digest('sha256', kService, "aws4_request")

        kSigning
      end
    end
  end
end