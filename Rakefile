# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = 'bhf'
  gem.homepage = 'https://antpaw.github.io/bhf'
  gem.licenses = 'MIT'
  gem.summary = 'A simple to use Rails-Engine-Gem that offers an admin interface for trusted user.'
  gem.description = 'A simple to use Rails-Engine-Gem that offers an admin interface for trusted user. Easy integratable and highly configurable and agnostic. Works with ActiveRecord and Mongoid.'
  gem.email = 'anton.pawlik@gmail.com'
  gem.authors = ['Anton Pawlik']
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

desc "Code coverage detail"
task :simplecov do
  ENV['COVERAGE'] = "true"
  Rake::Task['test'].execute
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "bhf #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
