require "rails"
require "ejs"
require "coffee-script"
require "sass-rails"
require "bootstrap-sass"
require "jquery-rails"
require "backbone-rails"
require "coffee-rails"

module Cartilage
  class Engine < Rails::Engine
    isolate_namespace Cartilage
  end
end
