#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rspec/core/rake_task'


desc "Simple cov"
task :simplecov do
  require 'simplecov'
  SimpleCov.start do 
    command_name "Tests"
  end
  require "blobsterix"
  `rspec`
end



RSpec::Core::RakeTask.new do |t|

end
