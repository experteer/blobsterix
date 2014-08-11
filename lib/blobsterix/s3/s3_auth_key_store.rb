module Blobsterix
  module S3Auth
    class KeyStore
      def initialize(keys={})
        @keys = keys
        @keys.default=""
      end
      # if no key is found it should return an empty string
      def get_key(id)
        @keys[id]
      end
    end
  end
end