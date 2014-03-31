module Blobsterix
  module ConfigLoader
    def load_blobsterix_config
      require_storages
      require_transformators
      require_config
    end

    def require_config()
      require Blobsterix.root.join("config.rb") if (File.exist?(Blobsterix.root.join("config.rb")))
    end

    def require_transformators()
      trafo_dir = Blobsterix.root.join("transformators")
      return if not File.exist?(trafo_dir)
      Dir.entries(trafo_dir).each{|dir|
        if !File.directory? File.join(trafo_dir,dir) and !(dir =='.' || dir == '..')
          require "#{File.join(trafo_dir,dir)}"
        end
      }
    end

    def require_storages()
      storages_dir = Blobsterix.root.join("storages")
      return if not File.exist?(storages_dir)
      Dir.entries(storages_dir).each{|dir|
        if !File.directory? File.join(storages_dir,dir) and !(dir =='.' || dir == '..')
          require "#{File.join(storages_dir,dir)}"
        end
      }
    end
  end
end
