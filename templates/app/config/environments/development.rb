# # Use a different logger
# Blobsterix.logger=Logger.new(STDOUT)

# # Set different dirs
# Blobsterix.storage_dir=Blobsterix.root.join("contents")
# Blobsterix.cache_dir=Blobsterix.root.join("cache")

# # Use X-Sendfile(standard: false)
# Blobsterix.use_x_send_file=true

# # Allow chunked streaming(standard: true)
# Blobsterix.allow_chunked_stream=true

# # Set different cache or storage handler
# Blobsterix.storage=Blobsterix::Storage::FileSystem.new(Blobsterix.storage_dir)
# Blobsterix.cache=Blobsterix::Storage::Cache.new(cache_dir)

# # Set different transformation manager
# Blobsterix.transformation=Blobsterix::Transformations::TransformationManager.new

# # Use a specific transformation decrypter
# Blobsterix.decrypt_trafo= lambda { |blob_access, trafo_string, logger|
#   trafo_string # this has to return a string in format of: trafoName_value,trafoName_value,....
# }

# # Use a specific cache checker for invalidation
# Blobsterix.cache_checker= lambda { |meta_data, last_accessed_at, created_at|
#   false # return true to invalidate the cache entry
# }

# # Use a specific storage and cache event listener
# Blobsterix.storage_event_listener= lambda { |target, blob_access|
#   # target is what happend where
# 	#	Possible events are: 
# 	#		encryption.error
# 	#		cache.miss
# 	#		cache.fatal_error
# 	#		cache.hit
# 	#		storage.read
# 	#		storage.read_fail
# 	#		storage.write
# 	#		storage.delete
#
#   # do stuff here... on standard it just logs the access
#   logger.info("#{target}: #{blob_access}")
# }
