# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ofx/version"

Gem::Specification.new do |s|
  s.name = "ofx_for_ruby"
  s.version = OFX::VERSION.to_dotted_s
  s.platform = Gem::Platform::RUBY
  
  s.authors = ["Chris Guidry"]
  s.description = "OFX for Ruby is a pure Ruby implementation of Open Financial Exchange specifications (1.0.2 through 2.1.1) for building both financial clients and servers, providing parsers/serializers for each version, and a uniform object model across all versions."
  s.email = ["chrisguidry@gmail.com"]
  s.summary = "Pure Ruby implementation of Open Financial Exchange specifications"
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.homepage    = "http://github.com/baconpat/ofx_for_ruby"
  
  s.add_dependency "activesupport"
  
  s.add_development_dependency "racc"
  s.add_development_dependency "rex"
  s.add_development_dependency "rcov"
end
