# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ofx/version"

Gem::Specification.new do |s|
  s.name = "ofx_for_ruby"
  s.version = OFX::VERSION.to_dotted_s
  s.platform = Gem::Platform::RUBY

  s.authors = ["Chris Guidry", "Patrick Bacon"]
  s.description = "OFX for Ruby is a pure Ruby implementation of Open Financial Exchange specifications (1.0.2 through 2.1.1) for building both financial clients and servers, providing parsers/serializers for each version, and a uniform object model across all versions."
  s.email = ["bacon@atomicobject.com"]
  s.summary = "Pure Ruby implementation of Open Financial Exchange specifications"
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.homepage    = "http://github.com/baconpat/ofx_for_ruby"

  s.add_dependency "activesupport"
  s.add_dependency "bigdecimal"
  s.add_dependency "logger"
  s.add_dependency "rexml"

  s.add_development_dependency "racc", "~> 1.8"
  s.add_development_dependency "rexical", "1.0.5"
  s.add_development_dependency "getoptlong"
  s.add_development_dependency "ostruct"
  s.add_development_dependency "pry"
  s.add_development_dependency "rake"
  s.add_development_dependency "minitest", "~> 5.27"
end
