require 'haml'
require 'sass'
require 'turbolinks'
require 'kaminari'

module Bhf
  class Engine < Rails::Engine
    
    isolate_namespace Bhf
    
    initializer 'bhf.helper' do
      ActiveSupport.on_load :action_controller do
        helper Bhf::FrontendHelper
      end
    end
    
    initializer 'bhf.model_hooks' do
      ActiveSupport.on_load :active_record do
        include Bhf::ActiveRecord::Base
      end
      ActiveSupport.on_load :mongoid do
        include Bhf::Mongoid::Document
      end
    end
  end
  
  
  def self.configuration
    @configuration ||= Bhf::Configuration.new
  end
  def self.configure
    yield configuration
  end
  class Configuration
    include ActiveSupport::Configurable

    config_accessor(:on_login_fail)             { :root_url           }
    config_accessor(:logout_path)               { :logout_path        }
    config_accessor(:session_auth_name)         { :is_admin           }
    config_accessor(:session_account_id)        { :admin_account_id   }
    config_accessor(:account_model)             { 'User'              }
    config_accessor(:account_model_find_method) { 'find'              }
    config_accessor(:css)                       { ['bhf/application'] }
    config_accessor(:js)                        { ['bhf/application'] }
    config_accessor(:abstract_settings)         { []                  }
    config_accessor(:paperclip_image_types)     {
      ['image/jpeg', 'image/pjpeg', 'image/jpg', 'image/png', 'image/tif', 'image/gif']
    }
  end
end

require 'bhf/settings/base'
require 'bhf/settings/platform'
require 'bhf/settings/yaml_parser'
require 'bhf/platform/base'
require 'bhf/platform/pagination'
require 'bhf/platform/attribute/abstract'
require 'bhf/platform/attribute/column'
require 'bhf/platform/attribute/reflection'
require 'bhf/active_record/base'
require 'bhf/mongoid/document'
require 'bhf/action_view/form_options'
require 'bhf/action_view/form_builder'
