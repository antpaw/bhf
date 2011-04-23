def d(var)
  raise var.inspect.split(', ').join(", \n")
end

require 'engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
require 'bhf/i18n'
require 'bhf/active_record'
require 'bhf/data'
require 'bhf/platform'
require 'bhf/settings'
require 'bhf/pagination'
require 'bhf/form'

I18n.send :include, Bhf::I18nTranslationFallbackHelper

::ActiveRecord::Base.send :include, Bhf::ActiveRecord::Object
::ActiveRecord::Base.send :extend,  Bhf::ActiveRecord::Self