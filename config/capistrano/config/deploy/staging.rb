role :app, "localhost", :primary => true
#role :db, "localhost", :primary => true

set :user, ENV["CAP_USER"] || ENV["USER"]

# =============================================================================
# RVM OPTIONS
# =============================================================================
set :rvm_ruby_string, 'ree-1.8.7-2012.02@blobsterix'
set :rvm_type, :user  # Literal ":user"
require 'rvm/capistrano'

#server 'localhost', :app, :web, :primary => true