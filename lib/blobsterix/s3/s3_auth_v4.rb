module Blobsterix
  module S3Auth
    class V4
      include ::Blobsterix::S3UrlHelper
      include ::Blobsterix::UrlHelper

      V4_REGEX = /AWS4-HMAC-SHA256 Credential=(\w+\/\d+\/.+\/\w+\/aws4_request),.*SignedHeaders=(.+),.*Signature=(\w+)/

      def self.create(env)
        matcher = V4_REGEX.match(env["HTTP_AUTHORIZATION"])
        matcher ? V4.new(env, matcher[1], matcher[2], matcher[3]) : nil
      end

      attr_reader :env, :credential, :signed_headers, :signature, :access_key, :scope_date, :scope_region, :scope_service

      def initialize(env, credential, signed_headers, signature)
        @env = env
        @credential = credential
        @signed_headers = signed_headers
        @signature = signature

        @access_key, @scope_date, @scope_region, @scope_service = @credential.split("/")
      end

      def check(secret_key_store)
        return false if is_expired?

        secret_key = secret_key_store.get_key(@access_key)
        gen_signature(secret_key) == @signature
      end

      def gen_signature(secret_key)
        signing_key = hmac256("AWS4"+secret_key, @scope_date)
        signing_key = hmac256(signing_key, @scope_region)
        signing_key = hmac256(signing_key, @scope_service)
        signing_key = hmac256(signing_key, "aws4_request")

        hmac256(signing_key, string_to_sign).unpack('H*').first
      end

      def string_to_sign
        [
          "AWS4-HMAC-SHA256",
          header_datetime_iso8601,
          [@scope_date, @scope_region, @scope_service, "aws4_request"].join("/"),
          Digest::SHA256.hexdigest(canonical_request)
        ].join("\n")
      end

      def canonical_request
        [
          @env["REQUEST_METHOD"].to_s.upcase,
          @env["REQUEST_PATH"],
          canonical_query,
          canonical_headers,
          @signed_headers,
          @env["HTTP_X_AMZ_CONTENT_SHA256"] || Digest::SHA256.hexdigest("")
        ].join("\n")
      end

      def canonical_query
        @env["QUERY_STRING"].to_s.split("&").sort.map do |param|
          param.split("=").map { |k_or_v| escape(k_or_v) }.join("=")
        end.join("&")
      end

      def canonical_headers
        canonicalized = @env.select { |key,value| key.is_a?(String) }.inject({}) do |memo, (key,value)|
          memo[key.gsub("HTTP_","").downcase.gsub("_","-")] = value.to_s.strip
          memo
        end

        headers = ""

        @signed_headers.split(";").each do |key|
          raise StandardError.new("Missing signed header") unless canonicalized.key?(key)
          headers << key + ":" + canonicalized[key] + "\n"
        end

        headers
      end

      def hmac256(key, data)
        OpenSSL::HMAC.digest(OpenSSL::Digest.new("sha256"), key, data)
      end

      def header_datetime
        Time.parse(@env["HTTP_X_AMZ_DATE"] || @env["HTTP_DATE"] || Time.now.to_s)
      end

      def header_datetime_iso8601
        header_datetime.utc.strftime('%Y%m%dT%H%M%SZ')
      end

      def is_expired?
        ::Blobsterix::S3Auth.current_time > header_datetime+15*60
      end

      def escape(string)
        string.gsub(/([^a-zA-Z0-9_.\-~]+)/) { "%" + $1.unpack("H2" * $1.bytesize).join("%").upcase }
      end
    end
  end
end