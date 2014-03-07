#!/usr/bin/env rake
require "bundler/gem_tasks"


desc "Simple cov"
task :simplecov do
  require 'simplecov'
  SimpleCov.start do 
    command_name "Tests"
  end
  require "blobsterix"
  `rspec`
end