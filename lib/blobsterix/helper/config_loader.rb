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

    ["transformators", "storages"].each do |name|
      define_method "require_#{name}".to_sym do
        load_dir = Blobsterix.root.join(name)
        return if not File.exist?(load_dir)
        Dir.entries(load_dir).each{|dir|
          if !File.directory? File.join(load_dir,dir) and !(dir =='.' || dir == '..')
            require "#{File.join(load_dir,dir)}"
          end
        }
      end
    end
  end
end
