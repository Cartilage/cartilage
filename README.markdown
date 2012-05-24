
# Cartilage for Backbone.js

Cartilage is a standardized set of layouts and user interface elements that
are bundled as a Rails Engine. It is build on top of Backbone.js (for
interactivity) and Bootstrap (for visual styling).

## Requirements

* Ruby on Rails 3.2+
* Asset Pipeline
* jQuery

## Usage

Include the Cartilage library in your project by adding the following to your
Gemfile:

    gem 'cartilage', :git => 'git@github.com:activeprospect/cartilage.git'

Cartilage depends on Twitter Bootstrap and we prefer the bootstrap-sass gem
for this, so also add this line while you're at it:

    gem 'bootstrap-sass'

Be sure to perform a `bundle install` to bring these new dependencies into
your project.

### Including Cartilage in the Asset Pipeline

You will also need to edit your manifest files (i.e. application.css and
application.js) to include Cartilage:

    //= require cartilage

## License

Cartilage is licensed under the terms of the MIT license (see MIT-LICENSE for
more details).
