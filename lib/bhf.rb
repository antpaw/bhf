require 'haml'
require 'sass'
require 'turbolinks'
require 'kaminari'
require 'bhf/active_record/active_record'
require 'bhf/mongoid/document'
require 'bhf/data'
require 'bhf/platform'
require 'bhf/config_parser'
require 'bhf/settings'
require 'bhf/pagination'
require 'bhf/form'


module Bhf
  class Engine < Rails::Engine
    
    isolate_namespace Bhf
    
    config.bhf = OpenStruct.new(
      on_login_fail: :root_url,
      logout_path: :logout_path,
      session_auth_name: :is_admin,
      session_account_id: :admin_account_id,
      account_model: 'User',
      account_model_find_method: 'find',
      css: ['bhf/application'],
      js: ['bhf/application'],
      abstract_config: []
    )
    
    initializer 'bhf.helper' do
      ActiveSupport.on_load :action_controller do
        helper Bhf::FrontendHelper
      end
    end
    
    initializer 'bhf.model_hooks' do
      ActiveSupport.on_load :active_record do
        include Bhf::ActiveRecord::Object
      end
      ActiveSupport.on_load :mongoid do
        include Bhf::Mongoid::Document
      end
    end
  end
  PAPERCLIP_IMAGE_TYPES = ['image/jpeg', 'image/pjpeg', 'image/jpg', 'image/png', 'image/tif', 'image/gif']
end