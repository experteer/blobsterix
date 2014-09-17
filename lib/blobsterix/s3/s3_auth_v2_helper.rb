module Blobsterix
  module S3Auth
    module V2Helper
      def canonicalized_amz_headers
        amz_headers = env.select do|key, _value|
          /HTTP_X_AMZ/i.match(key) if key.is_a?(String)
        end.sort.map do|key, value|
          "#{key.gsub("HTTP_", "").downcase.gsub("_", "-")}:#{value}"
        end
        return amz_headers.join("\n") + "\n" if amz_headers.length > 0
        ""
      end

      def canonicalized_resource(escape = false)
        return "/" if bucket == "root"
        escape ? "/#{bucket}/#{CGI.escape(file)}" : "/#{bucket}/#{file}"
      end

      def string_to_sign(escape = false)
        "#{env["REQUEST_METHOD"]}\n" +         "#{env["HTTP_CONTENT_MD5"] || ""}\n" +         "#{env["CONTENT_TYPE"] || ""}\n" +         "#{time_of_request}\n" +         "#{canonicalized_amz_headers}#{canonicalized_resource(escape)}"
      end

      def check(secret_key_store)
        return false if is_expired?
        # logger.info string_to_sign
        own_key_0 = server_signature(secret_key_store.get_key(access_key), string_to_sign)
        own_key_1 = server_signature(secret_key_store.get_key(access_key), string_to_sign(true))
        # logger.info "[#{@signature}] == [#{own_key_0}] OR [#{@signature}] == [#{own_key_1}]"
        @signature == own_key_0 || @signature == own_key_1
      end

      def gen_signature(secret_key, str)
        Base64.encode64(OpenSSL::HMAC.digest("sha1", secret_key, str)).chop
      end
    end
  end
end
