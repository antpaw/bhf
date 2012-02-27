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
    gem.description = 'Gets you there on time'
    gem.email = 'anton.pawlik@gmail.com'
    gem.authors = ['Anton Pawlik']
    gem.files = Dir["{lib}/**/*", "{app}/**/*", "{config}/**/*", "vendor/assets/**/*"]
    gem.homepage = 'http://github.com/antpaw/bahnhof'
    gem.rubyforge_project = 'nowarning'
    gem.add_dependency 'rails', '>= 3.2.0'
    gem.add_dependency 'kaminari', '>= 0.12.4'
    gem.add_dependency 'haml-rails', '>= 0.3.4'
    gem.add_dependency 'sass-rails', '>= 3.1.4'
    gem.add_dependency 'mootools-rails', '>= 1.0.1'
  end

  Jeweler::GemcutterTasks.new
end
