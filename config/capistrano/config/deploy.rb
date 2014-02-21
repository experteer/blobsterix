set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

set :application, "blobsterix"
set :use_sudo, false
set :ssh_options, { :forward_agent => true }

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"
set :deploy_to, "/usr/experteer/blobsterix"
set :user, ENV["CAP_USER"] || 'experteer'

# =============================================================================
# SCM OPTIONS
# =============================================================================
set :scm, :git
set :scm_command, 'git'
set :scm_verbose, true
set :scm_username, ENV["CAP_SCM_USER"] || ENV["USER"]
set :git_shallow_clone, 1 # tell git to only clone the latest revision (not the whole history)

set :branch, "master" # default is HEAD, but it's better to use the "master"
set :repository, ENV["CAP_REPOSITORY"] || "git@bitbucket.org:suddani/smartexpiry.git"


# =============================================================================
# BUNDLER
# =============================================================================
require "bundler/capistrano" # runs bundle:install automatically
# set :bundle_gemfile,      "Gemfile"
# set :bundle_dir,          fetch(:shared_path)+"/bundle"
set :bundle_flags,         '--quiet --deployment'# --binstubs --deployment --quiet"
# set :bundle_without,      [:development, :test]
set :bundle_cmd,          "bundle" # e.g. change to "/opt/ruby/bin/bundle"


# =============================================================================
# WHENEVER OPTIONS https://github.com/javan/whenever
# =============================================================================
# set :whenever_command, "bundle exec whenever"
# set :whenever_environment, defer { stage }
# require "whenever/capistrano"


# task :ls do
# 	run "ls"
# end

# task :current do
# 	run "cd /usr/experteer/smartexpiry/current; rvm current"
# end