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
require 'blobsterix/helper/blob_access'
require 'blobsterix/helper/status_info'
require 'blobsterix/helper/template_renderer'

#router base
require 'blobsterix/router/app_router'

#helper
require 'blobsterix/s3/s3_url_helper'
require 'blobsterix/blob/blob_url_helper'
require 'blobsterix/status/status_url_helper'

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
    @logger ||= Logger.new(STDOUT)
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

  def self.cache
    @cache ||= Storage::Cache.new(cache_dir)
  end

  def self.cache=(obj)
    @cache = obj
  end

  def self.decrypt_trafo=(obj)
    @decrypt_trafo=obj
  end

  def self.decrypt_trafo(trafo_string,logger)
    @decrypt_trafo||=lambda{|t,l|t}
    if !trafo_string
      return @decrypt_trafo
    end
    @decrypt_trafo.call(trafo_string, logger)
  end

  def self.transformation
    @@transformation ||= Blobsterix::Transformations::TransformationManager.new
  end

  def self.cache_checker=(obj)
     @@cache_checker=obj
  end

  def self.cache_checker
     @@cache_checker||=lambda{|blob_access, last_accessed_at, created_at|
        false
     }
  end

  def self.storage_event_listener=(obj)
    @storage_event_listener=obj
  end

  def self.storage_event_listener
    @storage_event_listener||=lambda{|target, blob_access|
      logger.info("#{target}: #{blob_access}")
    }
  end

  def self.encryption_error(blob_access)
    storage_event_listener.call("encryption.error",blob_access)
  end

  def self.cache_miss(blob_access)
    StatusInfo.cache_miss+=1
    StatusInfo.cache_access+=1
    storage_event_listener.call("cache.miss",blob_access)
  end

  def self.cache_fatal_error(blob_access)
    StatusInfo.cache_error+=1
    StatusInfo.cache_access+=1
    storage_event_listener.call("cache.fatal_error",blob_access)
  end

  def self.cache_hit(blob_access)
    StatusInfo.cache_hit+=1
    StatusInfo.cache_access+=1
    storage_event_listener.call("cache.hit",blob_access)
  end

  def self.storage_read(blob_access)
    storage_event_listener.call("storage.read",blob_access)
  end

  def self.storage_read_fail(blob_access)
    storage_event_listener.call("storage.read_fail",blob_access)
  end

  def self.storage_write(blob_access)
    storage_event_listener.call("storage.write",blob_access)
  end

  def self.storage_delete(blob_access)
    storage_event_listener.call("storage.delete",blob_access)
  end
end
