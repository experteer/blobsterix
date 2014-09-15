require "blobsterix/version"

# libs
require 'tempfile'
require 'scanf'
require 'nokogiri'
require 'journey'
# require 'vips'
# require 'pry'
require 'eventmachine'
require 'em-synchrony'
require 'mini_magick'
# require 'mimemagic'
# require 'ruby-webp'
# require 'grape'
# require 'evma_httpserver'
require 'json'
require 'logger'
require 'erb'
require 'openssl'
require 'base64'
require 'goliath/api'

# utility
require 'blobsterix/mimemagic/tables'
require 'blobsterix/mimemagic/version'
require 'blobsterix/mimemagic/magic'

# helper
require 'blobsterix/helper/http'
require 'blobsterix/helper/accept_type'
require 'blobsterix/helper/data_response'
require 'blobsterix/helper/murmur'
require 'blobsterix/helper/logable'
require 'blobsterix/helper/directory_list'
require 'blobsterix/helper/blob_access'
require 'blobsterix/helper/simple_proxy'
require 'blobsterix/helper/status_info'
require 'blobsterix/helper/template_renderer'
require 'blobsterix/helper/config_loader'
require 'blobsterix/helper/url_helper'
require 'blobsterix/helper/jsonizer'

# router base
require 'blobsterix/router/app_router'

# helper
require 'blobsterix/s3/s3_url_helper'
require 'blobsterix/blob/blob_url_helper'
require 'blobsterix/status/status_url_helper'
require 'blobsterix/s3/s3_auth_key_store'
require 'blobsterix/s3/s3_auth_v2_helper'
require 'blobsterix/s3/s3_auth_v2'
require 'blobsterix/s3/s3_auth_v2_query'
require 'blobsterix/s3/s3_auth_v4'
require 'blobsterix/s3/s3_auth'

# apis
require 'blobsterix/s3/s3_api'
require 'blobsterix/blob/blob_api'
require 'blobsterix/status/status_api'

# interfaces
require 'blobsterix/storage/blob_meta_data'
require 'blobsterix/storage/storage'
require 'blobsterix/storage/cache'
require 'blobsterix/storage/bucket_entry'
require 'blobsterix/storage/bucket'
require 'blobsterix/storage/bucket_list'
require 'blobsterix/storage/storage'
require 'blobsterix/transformation/transformation_manager'
require 'blobsterix/transformation/transformation_chain'
require 'blobsterix/transformation/transformation'

# implementation
require 'blobsterix/storage/file_system_meta_data'
require 'blobsterix/storage/file_system'

require 'blobsterix/transformation/image_transformation'

# service base
require 'blobsterix/service'

BLOBSTERIX_ROOT = Dir.pwd
BLOBSTERIX_GEM_DIR = File.join(File.dirname(__FILE__), "../")

module Blobsterix
  class << self
    attr_writer :logger
    attr_writer :storage_dir
    attr_writer :storage
    attr_writer :cache_dir
    attr_writer :cache_original
    attr_writer :cache
    attr_writer :use_x_send_file
    attr_writer :allow_chunked_stream
    attr_writer :decrypt_trafo
    attr_reader :secret_key_store
    attr_writer :secret_key_store
    attr_writer :transformation
    attr_writer :storage_event_listener

    def root
      @root ||= Pathname.new(BLOBSTERIX_ROOT)
    end

    def root_gem
      @root_gem ||= Pathname.new(BLOBSTERIX_GEM_DIR)
    end

    def logger
      Thread.current[:in_fiber_logger] ||= BlobsterixLogger.new((@logger || Logger.new(STDOUT)), Logable.next_id)
    end

    def storage_dir
      @storage_dir ||= root.join("contents")
    end

    def storage
      @storage ||= Storage::FileSystem.new(storage_dir)
    end

    def cache_dir
      @cache_dir ||= root.join("cache")
    end

    def cache_original?
      @cache_original ||= false
    end

    def cache
      @cache ||= Storage::Cache.new(cache_dir)
    end

    def use_x_send_file
      !!@use_x_send_file
    end

    def allow_chunked_stream
      !!@allow_chunked_stream
    end

    def decrypt_trafo(blob_access, trafo_string, logger)
      @decrypt_trafo ||= lambda { |_b, t, _l|t }
      unless trafo_string
        return @decrypt_trafo
      end
      @decrypt_trafo.call(blob_access, trafo_string, logger)
    end

    def transformation
      @transformation ||= Blobsterix::Transformations::TransformationManager.new
    end

    def cache_checker=(obj)
      @@cache_checker = obj
    end

    def cache_checker
      @@cache_checker ||= lambda do|_blob_access, _last_accessed_at, _created_at|
        false
      end
    end

    def storage_event_listener
      @storage_event_listener ||= lambda do|target, hash|
        logger.info("#{target}: #{hash.inspect}")
      end
    end

    def event(name, hash)
      storage_event_listener.call(name, hash)
    end

    def encryption_error(blob_access)
      event("encryption.error", :blob_access => blob_access)
    end

    def cache_miss(blob_access)
      StatusInfo.cache_miss += 1
      StatusInfo.cache_access += 1
      event("cache.miss", :blob_access => blob_access)
    end

    def cache_fatal_error(blob_access)
      StatusInfo.cache_error += 1
      StatusInfo.cache_access += 1
      event("cache.fatal_error", :blob_access => blob_access)
    end

    def cache_hit(blob_access)
      StatusInfo.cache_hit += 1
      StatusInfo.cache_access += 1
      event("cache.hit", :blob_access => blob_access)
    end

    def storage_read(blob_access)
      event("storage.read", :blob_access => blob_access)
    end

    def storage_read_fail(blob_access)
      event("storage.read_fail", :blob_access => blob_access)
    end

    def storage_write(blob_access)
      event("storage.write", :blob_access => blob_access)
    end

    def storage_delete(blob_access)
      event("storage.delete", :blob_access => blob_access)
    end

    def wait_for(op = nil)
      fiber = Fiber.current
      EM.defer(proc do
                 begin
                   op.call
                 rescue => e
                   e
                 end
               end,
               proc do|result|
                 fiber.resume result
               end)
      result = Fiber.yield
      fail result if result.is_a? Exception
      result
    end

    def wait_for_next(op = nil)
      EM.next_tick do
        wait_for(op)
      end
    end

    def at_exit(&proc)
      (@at_exit_callback ||= []).push(proc)
    end

    def run_at_exit
      (@at_exit_callback ||= []).each(&:call)
    end
  end
  self.allow_chunked_stream = true # for backwards compatibility
end
