module Blobsterix
  module S3Auth
    V2_REGEX = /AWS (\w+):(.+)/
    V4_REGEX = /AWS4-HMAC-SHA256 Credential=(\w+\/\d+\/.+\/\w+\/aws4_request),.*SignedHeaders=(.+),.*Signature=(\w+)/

    VERSIONS = [
      {:regex => V2_REGEX, :init => Proc.new{|env, matcher|
          V2.new(env, matcher[1], matcher[2])
        }},
      {:regex => V4_REGEX, :init => Proc.new{|env, matcher|
          V4.new(env, matcher[1], matcher[2], matcher[3])
        }}
    ]

    def self.authenticate(env)
      auth_string = env["HTTP_AUTHORIZATION"]
      VERSIONS.each do |version|
        matcher = version[:regex].match(auth_string)
        return version[:init].call(env, matcher) if matcher
      end
      NoAuth.new
    end

    class NoAuth
      def check(secret)
        false
      end
    end

    # Version 2
    class V2
      include ::Blobsterix::S3UrlHelper
      include ::Blobsterix::UrlHelper
      include ::Blobsterix::Logable

      SUBRESOURCES = [
        "acl",
        "lifecycle",
        "location",
        "logging",
        "notification",
        "partNumber",
        "policy",
        "requestPayment",
        "torrent",
        "uploadId",
        "uploads",
        "versionId",
        "versioning",
        "versions",
        "website"
      ]

      attr_reader :env, :access_key, :signature
      def initialize(env, access_key, signature)
        @env = env
        @access_key = access_key
        @signature = signature
      end

      def canonicalized_amz_headers
        amz_headers = env.select{|key,value|
          /HTTP_X_AMZ/i.match(key) if key.is_a?(String)
        }.sort.map{|key,value|
          "#{key.gsub("HTTP_","").downcase.gsub("_","-")}:#{value}"
        }
        return amz_headers.join("\n")+"\n" if amz_headers.length > 0
        ""
      end

      def canonicalized_resource
        return "/" if bucket == "root"
        "/#{bucket}/#{file}"
      end

      def canonicalized_resource_
        return "/" if bucket == "root"
        "/#{bucket}/#{CGI.escape(file)}"
      end

      def header_string_to_sign
        "#{env["REQUEST_METHOD"]}\n"+
        "#{env["HTTP_CONTENT_MD5"]||""}\n"+
        "#{env["CONTENT_TYPE"]||""}\n"+
        "#{env["HTTP_DATE"] unless env["HTTP_X_AMZ_DATE"]}\n"+
        "#{canonicalized_amz_headers}#{canonicalized_resource}"
      end

      def header_string_to_sign_
        "#{env["REQUEST_METHOD"]}\n"+
        "#{env["HTTP_CONTENT_MD5"]||""}\n"+
        "#{env["CONTENT_TYPE"]||""}\n"+
        "#{env["HTTP_DATE"] unless env["HTTP_X_AMZ_DATE"]}\n"+
        "#{canonicalized_amz_headers}#{canonicalized_resource_}"
      end

      def url_string_to_sign
        "#{env["REQUEST_METHOD"]}\n"+
        "#{env["HTTP_CONTENT_MD5"]||""}\n"+
        "#{env["CONTENT_TYPE"]||""}\n"+
        "#{env["params"]["Expires"] if env["params"]}\n"+
        "#{canonicalized_amz_headers}#{canonicalized_resource}"
      end

      def url_string_to_sign_
        "#{env["REQUEST_METHOD"]}\n"+
        "#{env["HTTP_CONTENT_MD5"]||""}\n"+
        "#{env["CONTENT_TYPE"]||""}\n"+
        "#{env["params"]["Expires"] if env["params"]}\n"+
        "#{canonicalized_amz_headers}#{canonicalized_resource_}"
      end

      def check(secret_key)
        logger.info header_string_to_sign
        own_key_0 = gen_signature(secret_key, header_string_to_sign)
        own_key_1 = gen_signature(secret_key, header_string_to_sign_)
        logger.info "[#{@signature}] == [#{own_key_0}] OR [#{@signature}] == [#{own_key_1}]"
        @signature == own_key_0 || @signature == own_key_1
      end

      def gen_signature(secret_key, str)
        Base64.encode64( OpenSSL::HMAC.digest("sha1", secret_key, str)).chop
      end

      def url_signature(secret_key, str)
        URI::encode(gen_signature(secret_key, str))
      end
    end

    # Version 4
    class V4
      include ::Blobsterix::S3UrlHelper
      include ::Blobsterix::UrlHelper

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