$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "cartilage/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "cartilage"
  s.version     = Cartilage::VERSION
  s.authors     = [ "Justin Mecham" ]
  s.email       = [ "justin@activeprospect.com" ]
  s.homepage    = "http://cartilagejs.org"
  s.summary     = "Cartilage for Backbone.js"
  s.description = ""

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.markdown"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.1.0"
  s.add_dependency "sass-rails-bootstrap"
end
