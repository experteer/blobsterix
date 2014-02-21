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

#utility
require 'blobsterix/mimemagic/tables'
require 'blobsterix/mimemagic/version'
require 'blobsterix/mimemagic/magic'

#helper
require 'blobsterix/helper/http.rb'
require 'blobsterix/helper/accept_type.rb'
require 'blobsterix/helper/data_response.rb'
require 'blobsterix/helper/murmur.rb'

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

module BlobServer
  def self.storage_dir
    File.join(BLOBSTERIX_DATA_DIR, "contents")
  end

  def self.storage
    puts "Doing in #{Dir.pwd}"
    @@storage ||= Storage::FileSystem.new(BlobServer.storage_dir)
  end

  def self.cache_dir
    File.join(BLOBSTERIX_DATA_DIR, "cache")
  end

  def self.cache
    @@cache ||= Storage::Cache.new(BlobServer.cache_dir)
  end

  def self.transformation
  	@@transformation ||= BlobServer::Transformations::TransformationManager.new
  end
end
