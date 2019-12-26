require 'haml'
require 'turbolinks'
require 'kaminari'

module Bhf
  ROOT_PATH = Pathname.new(File.join(__dir__, ".."))

  class << self
    def webpacker
      @webpacker ||= ::Webpacker::Instance.new(
        root_path: ROOT_PATH,
        config_path: ROOT_PATH.join("config/webpacker.yml")
      )
    end
  end

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

    initializer 'bhf.assets.precompile' do |app|
      app.config.assets.precompile += %w( bhf/application.css bhf/application.js bhf/logo_bhf.svg )
    end

    initializer "bhf.static.dir" do |app|
      app.middleware.insert_before(::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public")
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

    config_accessor(:logo)                      { lambda { |area| 'bhf/logo_bhf.svg' }}
    config_accessor(:on_login_fail)             { :root_url           }
    config_accessor(:logout_path)               { :logout_path        }
    config_accessor(:session_auth_name)         { :is_admin           }
    config_accessor(:session_account_id)        { :admin_account_id   }
    config_accessor(:account_model)             { 'User'              }
    config_accessor(:account_model_find_method) { 'find'              }
    config_accessor(:css)                       { ['bhf/application'] }
    config_accessor(:js)                        { ['bhf/application'] }
    config_accessor(:js_packs)                  { ['bhf/application'] }
    config_accessor(:abstract_settings)         { []                  }
    config_accessor(:image_types)     {
      ['image/jpeg', 'image/pjpeg', 'image/jpg', 'image/png',
       'image/tif', 'image/gif']
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
require 'bhf/controller/extension'
