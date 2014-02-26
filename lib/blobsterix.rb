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

#router base
require 'blobsterix/router/app_router'

#helper
require 'blobsterix/s3/s3_url_helper'
require 'blobsterix/blob/blob_url_helper'

#apis
require 'blobsterix/s3/s3_api'
require 'blobsterix/blob/blob_api'

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

  def self.logger=(obj)
    @logger=obj
  end

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.storage_dir
    root.join("contents")
  end

  def self.storage
    #logger.debug "Doing in #{Dir.pwd}"
    @@storage ||= Storage::FileSystem.new(storage_dir)
  end

  def self.cache_dir
    root.join("cache")
  end

  def self.cache
    @@cache ||= Storage::Cache.new(cache_dir)
  end

  def self.decrypt_trafo(trafo_string,logger)
    trafo_string
  end

  def self.transformation
    @@transformation ||= Blobsterix::Transformations::TransformationManager.new
  end

  def self.cache_checker
     @@cache_checker=lambda{ |blob_access, last_accessed_at, created_at|
        false
     }
  end
end
