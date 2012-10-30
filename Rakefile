#!/usr/bin/env rake

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end
begin
  require 'rdoc/task'
rescue LoadError
  require 'rdoc/rdoc'
  require 'rake/rdoctask'
  RDoc::Task = Rake::RDocTask
end

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Cartilage'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Bundler::GemHelper.install_tasks

require 'rake/testtask'

desc "Run tests for both engine and framework"
task :test => [ "test:framework" ] do
  # ...
end

namespace :pow do
  task :prepare do
    File.symlink("test/framework", "public")
  end
end

namespace :test do
  desc "Run tests for framework"
  task :framework => [ :compile ] do
    `which phantomjs`
    if $?.success? 
      system "phantomjs --debug=no --local-to-remote-url-access=yes #{File.dirname(__FILE__)}/test/framework/vendor/run-qunit.js #{File.dirname(__FILE__)}/test/framework/index.html"
    else
      raise "PhantomJS is not installed.  On Mac OS X please make sure you have the latest homebrew and try 'brew install phantomjs'"
    end
  end

  task :browser => [ :compile ] do
    system "open #{File.dirname(__FILE__)}/test/framework/index.html"
  end

  namespace :browser do
    # Having trouble running this in Chrome due to cross-origin issues due to file://? 
    # Quit Chrome and let open start it up with the -allow-file-access-from-files flag 
    # which should make things work again. FF and Safari work fine with the default 'open'.    
    task :chrome => [ :compile ] do
      system "open -a \"Google Chrome.app\" --args -allow-file-access-from-files #{File.dirname(__FILE__)}/test/framework/index.html"
    end
  end
end

# task :default => :test

desc "Compiles the framework into standalone JavaScript and CSS files"
task :compile do
  require 'sprockets'
  require 'uglifier'

  environment = Sprockets::Environment.new(File.dirname(__FILE__))
  environment.append_path 'app/assets/javascripts'
  environment.append_path 'app/assets/stylesheets'
  environment.append_path 'vendor/assets/javascripts'
  environment.append_path 'vendor/assets/stylesheets'

  cartilage_js  = environment.find_asset('cartilage.js.coffee').to_s
  compressed_js = Uglifier.compile(cartilage_js, :mangle => false)
  File.open("#{File.dirname(__FILE__)}/test/framework/cartilage.js", 'w') { |f| f.write(compressed_js) }

  # cartilage_css  = environment.find_asset('cartilage.css.scss').to_s
  # compressed_css = Uglifier.compile(cartilage_css)
  # File.open('cartilage.css', 'w') { |f| f.write(compressed_js) }
end
