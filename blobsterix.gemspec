# -*- encoding: utf-8 -*-
require File.expand_path('../lib/blobsterix/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["dsudmann"]
  gem.email         = ["suddani@googlemail.com"]
  gem.description   = "BlobServer"
  gem.summary       = "BlobServer"
  gem.homepage      = "http://experteer.com"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = ["blobsterix"]#gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "blobsterix"
  gem.require_paths = ["lib"]
  gem.version       = BlobServer::VERSION


  gem.add_dependency "json",        "~> 1.8.1"
  gem.add_dependency "goliath",     "~> 1.0.3"
  gem.add_dependency "journey",     "~> 1.0.4"
  gem.add_dependency "nokogiri",    "~> 1.6.1"
  gem.add_dependency "ruby-webp",   "~> 0.1.0"
  gem.add_dependency "mini_magick", "~> 3.5.0"

  gem.add_development_dependency "rspec", "~> 2.6"
  gem.add_development_dependency "pry"
end
