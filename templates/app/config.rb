module Blobsterix

  # If this function is uncommented it should return an environment
  # this env will override the one supplied from the command line
  # def self.env()
  #   :development or :production or :test
  # end

  # Use this method to set the port. (standard is 9000)
  # def self.port()
  #   9000
  # end

  # Use this to set the address. (standard is all)
  # def self.address()
  #   "127.0.0.1"
  # end

  # Override those methods if you want to change the storage and cache dirs from their default location
  # For a different way check the environments files
  # def self.storage_dir
  #   Blobsterix.root.join("contents")
  # end
  # def self.cache_dir
  #   Blobsterix.root.join("cache")
  # end

  # Override those if you want to change the default storage and cache system.
  # For a different way check the environments files
  # def self.storage
  #   @@storage ||= Storage::FileSystem.new(Blobsterix.storage_dir)
  # end
  # def self.cache
  #   @@cache ||= Storage::Cache.new(Blobsterix.cache_dir)
  # end


  # Override this method if you want to use a different transformation manager.
  # For a different way check the environments files
  # normally not needed
  # def self.transformation
  #   @@transformation ||= Blobsterix::Transformations::TransformationManager.new
  # end

  # Override this method incase you expect the trafo string in a special format.
  # For a different way check the environments files
  # The return should be in format of: trafoName_value,trafoName_value,....
  # Example: scale_2,rotate_20
  # def self.decrypt_trafo(trafo_string,logger)
  #   trafo_string
  # end

  # Use a specific storage and cache event listener. Check the environment files for a better description
  # def self.storage_event_listener
  #   @storage_event_listener||=lambda{|target, blob_access|
  #     logger.info("#{target}: #{blob_access}")
  #   }
  # end
end

require Blobsterix.root.join('config','environments',"#{Blobsterix.env}.rb")
