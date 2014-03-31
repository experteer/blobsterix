module Blobsterix
  module StatusUrlHelper
    def format
      if env[nil] && env[nil][:format]
        env[nil][:format].to_sym
      else
        :html
      end
    end
  end
end
