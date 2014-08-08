module Blobsterix
  module UrlHelper
    
    def favicon
      @favicon ||= file.match /favicon/
    end

    #TransformationCommand
    def trafo(trafo_s='')
      trafo_a = []
      trafo_s.split(",").each{|command|
        parts = command.split("_")
        key = parts.delete_at(0)
        trafo_a << [key, parts.join("_")]
      }
      trafo_a
    end

    def file
      if format
        [env[nil][:file] || env[nil][:bucket_or_file] || "", format].join(".")
      else
        env[nil][:file] || env[nil][:bucket_or_file] || ""
      end
    end

    def included_bucket
      if env[nil][:bucket_or_file] && env[nil][:bucket_or_file].include?("/")
        env[nil][:bucket] = env[nil][:bucket_or_file].split("/")[0]
        env[nil][:bucket_or_file] = env[nil][:bucket_or_file].gsub("#{env[nil][:bucket]}/", "")
        true
      else
        false
      end
    end

    def format
      @format ||= env[nil][:format]
    end
  end
end