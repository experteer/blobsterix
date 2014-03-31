module Blobsterix
  module S3UrlHelper
    HOST_PATH = /(\w+)(\.s3)?\.\w+\.\w+/
    def bucket_matcher(str)
      if str.include?("s3")
        str.match(/(\w+)\.s3\.\w+\.\w+/)
      else
        str.match(/(\w+)\.\w+\.\w+/)
      end
    end

    def favicon
      @favicon ||= file.match /favicon/
    end

    def cache_upload
      cache.put(cache_upload_key, env['rack.input'].read)
    end

    def cached_upload
      cache_upload if not cache.exists?(cache_upload_key)
      cache.get(cache_upload_key)
    end

    def cached_upload_clear
      cache.delete(cache_upload_key)
    end

    def cache_upload_key
      #@cache_upload_key ||= "upload/"+bucket.gsub("/", "_")+"_"+file.gsub("/", "_")
      @cache_upload_key ||= Blobsterix::BlobAccess.new(:bucket => bucket, :id => "upload_#{file.gsub("/", "_")}")
    end

    def trafo_string
      @trafo ||= env["HTTP_X_AMZ_META_TRAFO"] || ""
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
    
    def bucket
      host = bucket_matcher(env['HTTP_HOST'])
      if host
        host[1]
      elsif  (env[nil] && env[nil][:bucket])
        env[nil][:bucket]
      elsif  (env[nil] && env[nil][:bucket_or_file])
        if env[nil][:bucket_or_file].include?("/")
          env[nil][:bucket_or_file].split("/")[0]
        else
          env[nil][:bucket_or_file]
        end
      else
        "root"
      end
    end

    def bucket?
      host = bucket_matcher(env['HTTP_HOST'])
      host || env[nil][:bucket] || included_bucket
    end

    def format
      @format ||= env[nil][:format]
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

    def file
      if format
        [env[nil][:file] || env[nil][:bucket_or_file] || "", format].join(".")
      else
        env[nil][:file] || env[nil][:bucket_or_file] || ""
      end
    end
  end
end
