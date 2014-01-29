# -*- encoding: utf-8 -*-
require File.expand_path('../lib/blobsterix/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["dsudmann"]
  gem.email         = ["suddani@googlemail.com"]
  gem.description   = "BlobServer"
  gem.summary       = "BlobServer"
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = ["blobsterix", "console", "test"]#gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "blobsterix"
  gem.require_paths = ["lib"]
  gem.version       = BlobServer::VERSION


  gem.add_dependency "json"
  gem.add_dependency "goliath"
  #gem.add_dependency "mimemagic"
  #gem.add_dependency "grape"
  #gem.add_dependency "eventmachine_httpserver"
  gem.add_dependency "journey"
  gem.add_dependency "nokogiri"
  #gem.add_dependency "ruby-vips"
  gem.add_dependency "ruby-webp"
  gem.add_dependency "rubigen"
  gem.add_dependency "mini_magick", "~> 3.5.0"

  gem.add_development_dependency "rspec", "~> 2.6"
  gem.add_development_dependency "pry"
  #gem.add_development_dependency "ruby18_source_location"
end
