module Blobsterix
  module Loggable
    def logger
      @logger ||= Blobsterix.logger
    end

    def logger=(_logger)
      @logger=_logger
    end
  end
end