#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

desc "Simple cov"
task :simplecov do
  require 'simplecov'
  SimpleCov.start do
    command_name "Tests"
  end
  require "blobsterix"
  `rspec`
end

desc "init"
task :init do
  `codeqa --install #{__dir__}`
end

task :default => :spec
