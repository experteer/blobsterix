source 'https://rubygems.org'

# Specify your gem's dependencies in blob_server.gemspec
gemspec

gem 'simplecov', :require => false, :group => :test
gem 'rack-test', :group => :test
gem 'em-http-request', :group => :test

group :development do
  gem 'guard-rubocop'
  gem 'guard-rspec'
  gem 'codeqa', '>= 0.4.1'
  gem 'rubocop', '~> 0.26'
  gem "capistrano", "2.15.4"
  gem "capistrano-ext", "1.2.1"
  gem "rvm-capistrano", "~> 1.5.1"
  gem 'whenever', '=0.8.2', :require => false
  gem "railsless-deploy", :require => false
end
