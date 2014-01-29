require "blob_server/version"

#libs
require 'tempfile'
require 'scanf'
require 'nokogiri'
require 'journey'
#require 'vips'
require 'pry'
require 'eventmachine'
require 'em-synchrony'
require 'mini_magick'
#require 'mimemagic'
#require 'ruby-webp'
#require 'grape'
#require 'evma_httpserver'
require 'json'

#utility
require 'blob_server/mimemagic/tables'
require 'blob_server/mimemagic/version'
require 'blob_server/mimemagic/magic'

#helper
require 'blob_server/helper/http.rb'
require 'blob_server/helper/accept_type.rb'
require 'blob_server/helper/data_response.rb'
require 'blob_server/helper/murmur.rb'

#router base
require 'blob_server/router/app_router'

#helper
require 'blob_server/s3/s3_url_helper'
require 'blob_server/blob/blob_url_helper'

#apis
require 'blob_server/s3/s3_api'
require 'blob_server/blob/blob_api'

#interfaces
require 'blob_server/storage/blob_meta_data'
require 'blob_server/storage/storage'
require 'blob_server/storage/cache'
require 'blob_server/storage/bucket_entry'
require 'blob_server/storage/bucket'
require 'blob_server/storage/bucket_list'
require 'blob_server/storage/storage'
require 'blob_server/transformation/transformation_manager'
require 'blob_server/transformation/transformation_chain'
require 'blob_server/transformation/transformation'

#implementation
require 'blob_server/storage/file_system_meta_data'
require 'blob_server/storage/file_system'

require 'blob_server/transformation/image_transformation'

#service base
require 'blob_server/service'

module BlobServer
  def self.storage
  	@@storage ||= Storage::FileSystem.new("../contents")
  end
  def self.cache
  	#@@cache ||= Storage::Cache.new("../cache")
  	@@cache ||= Storage::Cache.new("../cache")
  	#@@cache ||= Storage::Cache.new("/tmp/blobsterix/cache")
  end

  def self.transformation
  	@@transformation ||= BlobServer::Transformations::TransformationManager.new
  end
end
