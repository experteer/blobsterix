module Blobsterix
  class BlobsterixLogger
    def initialize(logger, req_id)
      @logger = logger
      @req_id = req_id
    end

    def info(msg)
      @logger.info "[#{@req_id}] -> #{msg}"
    end

    def warn(msg)
      @logger.warn "[#{@req_id}] -> #{msg}"
    end

    def error(msg)
      @logger.error "[#{@req_id}] -> #{msg}"
    end

    def debug(msg)
      @logger.debug "[#{@req_id}] -> #{msg}"
    end
  end

  module Logable
    def logger
      @logger ||= Blobsterix.logger
    end

    attr_writer :logger

    def self.next_id
      @req_id ||= 0
      @req_id += 1
    end
  end
end
