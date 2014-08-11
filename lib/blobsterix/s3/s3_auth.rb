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

    def self.current_time
      (@current_time||=lambda{Time.now}).call
    end

    def self.current_time=(obj)
      @current_time=obj
    end

    class NoAuth
      def check(secret)
        false
      end
    end
  end
end