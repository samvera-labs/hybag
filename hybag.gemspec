# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hybag/version'

Gem::Specification.new do |spec|
  spec.name          = "hybag"
  spec.version       = Hybag::VERSION
  spec.authors       = ["Trey Terrell"]
  spec.email         = ["trey.terrell@oregonstate.edu"]
  spec.description   = 'A Hydra gem for adding BagIt functionality to ActiveFedora models.'
  spec.summary       = 'A Hydra gem for adding BagIt functionality to ActiveFedora models.'
  spec.homepage      = 'https://github.com/osulp/hybag'
  spec.license       = "APACHE2"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency 'fakefs'

  spec.add_dependency 'active-fedora'
  spec.add_dependency 'activesupport', '>= 3.2.0', '< 5.0'
  spec.add_dependency 'bagit'
  spec.add_dependency 'mime-types'
end
