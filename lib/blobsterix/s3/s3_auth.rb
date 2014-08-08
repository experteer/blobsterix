module Blobsterix
  module S3Auth

    VERSIONS = [
      V2,
      V2Query,
      V4
    ]

    def self.authenticate(env)
      VERSIONS.each do |version|
        v = version.create(env)
        return v if v
      end
      NoAuth.new
    end

    class NoAuth
      def check(secret)
        false
      end
    end
  end
end