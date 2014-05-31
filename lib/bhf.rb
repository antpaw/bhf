def d(var)
  raise var.inspect.split(', ').join(",\n")
end
require 'haml'
require 'kaminari'

module Bhf
  class Engine < Rails::Engine
    
    isolate_namespace Bhf
    
    # config.bhf defaults
    config.bhf = OpenStruct.new
    config.bhf.page_title = nil
    config.bhf.on_login_fail = :root_url
    config.bhf.logout_path = :logout_path
    config.bhf.session_auth_name = :is_admin
    config.bhf.session_account_id = :admin_account_id
    config.bhf.account_model = 'User'
    config.bhf.account_model_find_method = 'find'
    config.bhf.css = []
    config.bhf.js = []
    config.bhf.abstract_config = []
    
    # config.bhf.config = YAML::load(IO.read('config/bhf.yml'))
    
    initializer 'bhf.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        helper Bhf::FrontendHelper
      end
    end
    
    initializer 'bhf.hooks' do
      if defined?(::ActiveRecord)
        ::ActiveRecord::Base.send :include, Bhf::ActiveRecord::Object
      end
      if defined?(::Mongoid)
        ::Mongoid::Document.send :include, Bhf::Mongoid::Document
      end
    end
  end
end

require 'bhf/active_record/active_record'
require 'bhf/mongoid/document'
require 'bhf/data'
require 'bhf/platform'
require 'bhf/config_parser'
require 'bhf/settings'
require 'bhf/pagination'
require 'bhf/form'


