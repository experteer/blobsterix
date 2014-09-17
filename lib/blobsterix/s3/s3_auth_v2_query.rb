module Blobsterix
  module S3Auth
    class V2Query
      include ::Blobsterix::S3UrlHelper
      include ::Blobsterix::UrlHelper
      include ::Blobsterix::Logable
      include V2Helper

      def self.create(env)
        return nil unless env["params"] && env["params"]["AWSAccessKeyId"] && env["params"]["Signature"]
        V2Query.new(env, env["params"]["AWSAccessKeyId"], env["params"]["Signature"], env["params"]["Expires"])
      end

      attr_reader :env, :access_key, :signature, :expires
      def initialize(env, access_key, signature, expires)
        @env = env
        @access_key = access_key
        @signature = signature
        @expires = expires
      end

      def time_of_request
        expires
      end

      def is_expired?
        return false unless expires
        ::Blobsterix::S3Auth.current_time > Time.at(expires.to_i)
      end

      def server_signature(secret_key, str)
        # URI::encode(gen_signature(secret_key, str))
        gen_signature(secret_key, str)
      end
    end
  end
end
