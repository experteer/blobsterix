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
  # def self.storage_dir(logger)
  #   Blobsterix.root.join("contents")
  # end
  # def self.cache_dir(logger)
  #   Blobsterix.root.join("cache")
  # end

  # Override those if you want to change the default storage and cache system.
  # def self.storage(logger)
  #   @@storage ||= Storage::FileSystem.new(Blobsterix.storage_dir)
  # end
  # def self.cache(logger)
  #   @@cache ||= Storage::Cache.new(Blobsterix.cache_dir)
  # end


  # Override this method if you want to use a different transformation manager.
  # normally not needed
  # def self.transformation(logger)
  #   @@transformation ||= Blobsterix::Transformations::TransformationManager.new
  # end

  # Override this method incase you expect the trafo string in a special format.
  # The return should be in format of: trafoName_value,trafoName_value,....
  # Example: scale_2,rotate_20
  # def self.decrypt_trafo(trafo_string,logger)
  #   trafo_string
  # end
end