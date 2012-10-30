# Cartilage for Backbone.js

[![Build Status](https://secure.travis-ci.org/Cartilage/cartilage.png)](http://travis-ci.org/Cartilage/cartilage)

Cartilage is a standardized set of layouts and user interface elements that
are bundled as a Rails Engine. It is build on top of Backbone.js (for
interactivity) and Bootstrap (for visual styling).

## Example

An example project is available at http://github.com/Cartilage/cartilage-example which
is available as a demo here http://example.cartilagejs.org/
## Requirements

* Ruby on Rails 3.2+
* Asset Pipeline
* jQuery

## Usage

Include the Cartilage library in your project by adding the following to your
Gemfile:

    gem 'cartilage', :git => 'git@github.com:Cartilage/cartilage.git'

Cartilage depends on Twitter Bootstrap and we prefer the bootstrap-sass gem
for this, so also add this line while you're at it:

    gem 'bootstrap-sass'

Be sure to perform a `bundle install` to bring these new dependencies into
your project.

### Including Cartilage in the Asset Pipeline

You will also need to edit your manifest files (i.e. application.css and
application.js) to include Cartilage:

    //= require cartilage


### Working With Windows

If you need to work with IE on Windows it is recommend that you continue development
on Mac or *nix environment.  If you're using Pow, run "rake pow:prepare" which will
create a "public" symlink to the test directory.  Once the cartilage repo is linked 
it'll automatically pick up the public folder and start serving the static files there.
With Pow, you'll be able to use xip.io to access the tests from browsers through a VM
or beyond your own computer.

Alternatively, if you're not using Pow you can also simply call 'rackup' from the repo 
root which will start the default server and point directly to the test directory.  

## License

Cartilage is licensed under the terms of the MIT license (see MIT-LICENSE for
more details).
