$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "cartilage/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "cartilage"
  s.version     = Cartilage::VERSION
  s.authors     = [ "Justin Mecham", "Rick Benavidez", "Nick Means", "Chris Grayson" ]
  s.email       = [ "justin@activeprospect.com", "rick@activeprospect.com", "nick@activeprospect.com", "chris@activeprospect.com" ]
  s.homepage    = "http://cartilagejs.org"
  s.summary     = "Cartilage for Backbone.js"
  s.description = ""

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.markdown"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.1"
  s.add_dependency "sass-rails", "~> 3.2.5"
  s.add_dependency "bootstrap-sass", "~> 2.1.0.1"
  s.add_dependency "ejs", "~> 1.1.1"
  s.add_dependency "coffee-script", "~> 2.2.0" 
  s.add_dependency "eco", "~> 1.0.0"
  s.add_dependency "backbone-rails", "~> 0.9.2"
  s.add_dependency "jquery-rails", "~> 2.1.3"
  s.add_dependency "coffee-rails", "~> 3.2.2"
end
