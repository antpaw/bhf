task :compile_css do
  system 'sass --update public/stylesheets/sass/bhf.sass:public/stylesheets/bhf.css --style compressed'
end

task :compile_js do
  require 'yui/compressor'
  compressor = YUI::JavaScriptCompressor.new

  output = ''
  [
    'public/javascripts/mootools-core-1.3-full-nocompat-yc.js',
    'public/javascripts/mootools-more.js'
  ].each do |js_path|
    output << File.read(js_path)
  end

  [
    'public/javascripts/mootools_rails_driver-0.4.1.js',
    'public/javascripts/class/BrowserUpdate.js', 
    'public/javascripts/class/Ajaxify.js',
    'public/javascripts/bhf_application.js'
  ].each do |js_path|
    output << compressor.compress(File.read(js_path))
  end

  # TODO: Zlib::GzipWriter.open('public/javascripts/bhf.js', 'w')
  File.open('public/javascripts/bhf.js', 'w') do |file|
    file.write(output)
  end
end
# Rake::Task[:compile_js].invoke
# Rake::Task[:compile_css].invoke


require 'rake/testtask'

Rake::TestTask.new do |test|
  test.pattern = 'test/**/*_test.rb'
  test.libs << 'test'
end


begin
  require 'jeweler'
  
  Jeweler::Tasks.new do |gem|
    gem.name = 'bhf'
    gem.summary = 'Agnostic rails backend'
    gem.description = 'Gets you there in time'
    gem.email = 'anton.pawlik@gmail.com'
    gem.authors = ['Anton Pawlik']
    gem.files = Dir["{lib}/**/*", "{app}/**/*", "{config}/**/*", "public/stylesheets/bhf.css", "public/javascripts/bhf.js"]
    gem.homepage = 'http://github.com/antpaw/bahnhof'
    gem.rubyforge_project = 'nowarning'
    gem.add_dependency 'rails'
    gem.add_dependency 'haml'
    gem.add_dependency 'will_paginate'
    
  end
  Jeweler::GemcutterTasks.new
rescue
  puts 'Jeweler or dependency not available.'
end
