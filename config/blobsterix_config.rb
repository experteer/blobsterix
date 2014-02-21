module BlobServer
  # Override those methods if you want to change the storage and cache dirs from their default location
  # def self.storage

  #   @@storage ||= Storage::FileSystem.new(File.join(BLOBSTERIX_DATA_DIR, "contents"))
  # end
  # def self.cache
  #   @@cache ||= Storage::Cache.new(File.join(BLOBSTERIX_DATA_DIR, "cache"))
  # end


  # Override this method if you want to use a different transformation manager.
  # normally not needed

  # def self.transformation
  #   @@transformation ||= BlobServer::Transformations::TransformationManager.new
  # end
end