module Blobsterix
  module S3Auth
    class KeyStore
      def initialize(keys={})
        @keys = keys
        @keys.default=""
      end
      def get_key(id)
        @keys[id]
      end
    end
  end
end