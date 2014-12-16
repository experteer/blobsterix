require "blobsterix/version"

#libs
require 'tempfile'
require 'scanf'
require 'nokogiri'
require 'journey'
#require 'vips'
#require 'pry'
require 'eventmachine'
require 'em-synchrony'
require 'mini_magick'
#require 'mimemagic'
#require 'ruby-webp'
#require 'grape'
#require 'evma_httpserver'
require 'json'
require 'logger'
require 'erb'
require 'openssl'
require 'base64'
require 'zip'
require 'goliath/api'


#utility
require 'blobsterix/mimemagic/tables'
require 'blobsterix/mimemagic/version'
require 'blobsterix/mimemagic/magic'

#helper
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
require 'blobsterix/helper/zip_file_presenter'

#router base
require 'blobsterix/router/app_router'

#helper
require 'blobsterix/s3/s3_url_helper'
require 'blobsterix/blob/blob_url_helper'
require 'blobsterix/status/status_url_helper'
require 'blobsterix/s3/s3_auth_key_store'
require 'blobsterix/s3/s3_auth_v2_helper'
require 'blobsterix/s3/s3_auth_v2'
require 'blobsterix/s3/s3_auth_v2_query'
require 'blobsterix/s3/s3_auth_v4'
require 'blobsterix/s3/s3_auth'

#apis
require 'blobsterix/s3/s3_api'
require 'blobsterix/blob/blob_api'
require 'blobsterix/status/status_api'

#interfaces
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

#implementation
require 'blobsterix/storage/file_system_meta_data'
require 'blobsterix/storage/file_system'

require 'blobsterix/transformation/image_transformation'

#service base
require 'blobsterix/service'

BLOBSTERIX_ROOT=Dir.pwd
BLOBSTERIX_GEM_DIR = File.join(File.dirname(__FILE__), "../")

Zip.on_exists_proc = true

module Blobsterix
  def self.root
    @root ||= Pathname.new(BLOBSTERIX_ROOT)
  end

  def self.root_gem
    @root_gem ||= Pathname.new(BLOBSTERIX_GEM_DIR)
  end

  def self.logger=(obj)
    @logger=obj
  end

  def self.logger
    Thread.current[:in_fiber_logger] ||= BlobsterixLogger.new((@logger||Logger.new(STDOUT)),Logable.next_id)
  end

  def self.storage_dir
    @storage_dir||=root.join("contents")
  end

  def self.storage_dir=(obj)
    @storage_dir=obj
  end

  def self.storage
    @storage ||= Storage::FileSystem.new(storage_dir)
  end

  def self.storage=(obj)
    @storage = obj
  end

  def self.cache_dir
    @cache_dir||=root.join("cache")
  end

  def self.cache_dir=(obj)
    @cache_dir=obj
  end

  def self.cache_original?
    @cache_original||=false
  end

  def self.cache_original=(obj)
    @cache_original=obj
  end

  def self.cache
    @cache ||= Storage::Cache.new(cache_dir)
  end

  def self.cache=(obj)
    @cache = obj
  end

  def self.use_x_send_file
    !!@use_x_send_file
  end

  def self.use_x_send_file=(obj)
    @use_x_send_file=obj
  end
  
  def self.allow_chunked_stream
    !!@allow_chunked_stream
  end

  def self.allow_chunked_stream=(obj)
    @allow_chunked_stream=obj
  end
  self.allow_chunked_stream=true #for backwards compatibility

  def self.decrypt_trafo=(obj)
    @decrypt_trafo=obj
  end

  def self.secret_key_store
    @secret_key_store
  end

  def self.secret_key_store=(obj)
    @secret_key_store=obj
  end

  def self.decrypt_trafo(blob_access,trafo_string,logger)
    @decrypt_trafo||=lambda{|b,t,l|t}
    if !trafo_string
      return @decrypt_trafo
    end
    @decrypt_trafo.call(blob_access, trafo_string, logger)
  end

  def self.transformation
    @transformation ||= Blobsterix::Transformations::TransformationManager.new
  end

  def self.transformation=(obj)
    @transformation=obj
  end

  def self.cache_checker=(obj)
     @@cache_checker=obj
  end

  def self.cache_checker
     @@cache_checker||=lambda{|blob_access, meta_data, last_accessed_at, created_at|
        false
     }
  end

  def self.storage_event_listener=(obj)
    @storage_event_listener=obj
  end

  def self.storage_event_listener
    @storage_event_listener||=lambda{|target, hash|
      logger.info("#{target}: #{hash.inspect}")
    }
  end

  def self.event(name,hash)
    storage_event_listener.call(name,hash)
  end
  
  def self.encryption_error(blob_access)
    event("encryption.error",:blob_access => blob_access)
  end

  def self.cache_miss(blob_access)
    StatusInfo.cache_miss+=1
    StatusInfo.cache_access+=1
    event("cache.miss", :blob_access => blob_access)
  end

  def self.cache_fatal_error(blob_access)
    StatusInfo.cache_error+=1
    StatusInfo.cache_access+=1
    event("cache.fatal_error", :blob_access => blob_access)
  end

  def self.cache_hit(blob_access)
    StatusInfo.cache_hit+=1
    StatusInfo.cache_access+=1
    event("cache.hit",:blob_access => blob_access)
  end

  def self.storage_read(blob_access)
    event("storage.read",:blob_access => blob_access)
  end

  def self.storage_read_fail(blob_access)
    event("storage.read_fail",:blob_access => blob_access)
  end

  def self.storage_write(blob_access)
    event("storage.write",:blob_access => blob_access)
  end

  def self.storage_delete(blob_access)
    event("storage.delete",:blob_access => blob_access)
  end

  def self.wait_for(op = nil)
    fiber = Fiber.current
    EM.defer(Proc.new {
        begin
          op.call
        rescue Exception => e
          e
        end
      },
      Proc.new {|result|
            fiber.resume result
          })
     result = Fiber.yield
     raise result if result.is_a? Exception
     result
  end

  def self.wait_for_next(op = nil)
    EM.next_tick do 
      wait_for(op)
    end
  end

  def self.at_exit(&proc)
    (@at_exit_callback||=[]).push(proc)
  end

  def self.run_at_exit
    (@at_exit_callback||=[]).each do |proc|
      proc.call
    end
  end
end
