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
      (@current_time ||= lambda { Time.now }).call
    end

    class << self
      attr_writer :current_time
    end

    class NoAuth
      def check(_secret)
        false
      end
    end
  end
end
