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
task :test => [ "test:engine", "test:framework" ] do
  # ...
end

namespace :test do

  Rake::TestTask.new(:engine) do |t|
    t.libs << 'lib'
    t.libs << 'test'
    t.pattern = 'test/**/*_test.rb'
    t.verbose = false
  end

  desc "Run tests for framework"
  task :framework => [ :compile ] do
    system "open #{File.dirname(__FILE__)}/test/framework/index.html"
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
  File.open('cartilage.js', 'w') { |f| f.write(compressed_js) }

  # cartilage_css  = environment.find_asset('cartilage.css.scss').to_s
  # compressed_css = Uglifier.compile(cartilage_css)
  # File.open('cartilage.css', 'w') { |f| f.write(compressed_js) }

end
