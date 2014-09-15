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

    def cache_upload
      cache.put_stream(cache_upload_key, env['rack.input'])
    end

    def cached_upload
      cache_upload unless cache.exists?(cache_upload_key)
      cache.get(cache_upload_key)
    end

    def cached_upload_clear
      cache.delete(cache_upload_key)
    end

    def cache_upload_key
      @cache_upload_key ||= Blobsterix::BlobAccess.new(:bucket => bucket, :id => "upload_#{file.gsub("/", "_")}")
    end

    def transformation_string
      @trafo ||= env["HTTP_X_AMZ_META_TRAFO"] || ""
    end

    def bucket
      host = bucket_matcher(env['HTTP_HOST'])
      if host
        host[1]
      elsif  env[nil] && env[nil][:bucket]
        env[nil][:bucket]
      elsif  env[nil] && env[nil][:bucket_or_file]
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
  end
end
