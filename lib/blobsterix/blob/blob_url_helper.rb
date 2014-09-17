module Blobsterix
  module BlobUrlHelper
    def bucket
      if  env[nil] && env[nil][:bucket]
        env[nil][:bucket]
      elsif included_bucket
        env[nil][:bucket]
      else
        "root"
      end
    end

    def transformation_string
      (env["params"] && env["params"]["trafo"]) || env[nil][:trafo] || ""
    end
  end
end
