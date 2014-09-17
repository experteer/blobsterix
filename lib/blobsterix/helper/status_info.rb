module Blobsterix
  module StatusInfo
    class << self
      attr_writer :connections
      attr_writer :cache_hit
      attr_writer :cache_miss
      attr_writer :cache_error
      attr_writer :cache_access

      def boot_up
        @start_time = Time.now
      end

      def uptime
        Time.now - @start_time
      end

      def cache_hit
        @cache_hit ||= 0
      end

      def cache_miss
        @cache_miss ||= 0
      end

      def cache_error
        @cache_error ||= 0
      end

      def cache_access
        @cache_access ||= 0
      end

      def connections
        @connections ||= 0
      end
    end
    boot_up
  end
end
