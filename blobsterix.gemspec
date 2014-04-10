# -*- encoding: utf-8 -*-
require File.expand_path('../lib/blobsterix/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Daniel Sudmann"]
  gem.email         = ["suddani@googlemail.com"]
  gem.description   = "Blobsterix is a transcoding, caching, storage server that can transform your blobs (images, pdf, ...) at request time."
  gem.summary       = "Blobsterix is a transcoding, caching, storage server."
  gem.homepage      = "https://github.com/experteer/blobsterix"
  gem.license       = "MIT License"

  gem.files         = `git ls-files`.split($\).select{|filename|
    if filename.match(/^(\"contents).*/)
      false
    else
      true
    end
  }
  gem.executables   = ["blobsterix"]#gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "blobsterix"
  gem.require_paths = ["lib"]
  gem.version       = Blobsterix::VERSION
  gem.required_ruby_version = ">= 2.0.0.451"
  

  gem.add_dependency "json",        "~> 1.8.1"
  gem.add_dependency "goliath",     "~> 1.0.3"
  gem.add_dependency "journey",     "~> 1.0.4"
  gem.add_dependency "nokogiri",    "~> 1.6.1"
  gem.add_dependency "ruby-webp",   "~> 0.1.0"
  gem.add_dependency "mini_magick", "~> 3.5.0"

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rspec-core"
  gem.add_development_dependency "rspec-expectations"
  gem.add_development_dependency "rspec-mocks"
  gem.add_development_dependency "pry"
end
