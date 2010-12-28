Gem::Specification.new do |s|
  s.name = "ofx_for_ruby"
  s.version = "0.1.1"

  s.authors = ["Chris Guidry"]
  s.date = "2010-11-2"
  s.description = "OFX for Ruby is a pure Ruby implementation of Open Financial Exchange specifications (1.0.2 through 2.1.1) for building both financial clients and servers, providing parsers/serializers for each version, and a uniform object model across all versions."
  s.email = "chrisguidry@gmail.com"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.3.7"
  s.summary = "Pure Ruby implementation of Open Financial Exchange specifications"
  s.files = Dir["lib/**/*.rb"] + Dir["lib/**/*.racc"] + Dir["lib/**/*.rex"] + Dir["lib/**/*.pem"] + %w(README COPYING RELEASE_NOTES)
    
  s.add_dependency "activesupport"
  
  s.add_development_dependency "racc"
  s.add_development_dependency "rex"
  s.add_development_dependency "rcov"
end

