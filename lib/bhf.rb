def d(var)
  raise var.inspect.split(', ').join(",\n")
end
require 'haml'
require 'kaminari'

module Bhf
  class Engine < Rails::Engine

    # Config defaults
    config.page_title = nil
    config.mount_at = 'bhf'
    config.on_login_fail = :root_url
    config.logout_path = :logout_path
    config.session_auth_name = :is_admin
    config.session_account_id = :admin_account_id
    config.account_model = 'User'
    config.account_model_find_method = 'find'
    config.css = []
    config.js = []
    
    config.bhf_routes = lambda {
      namespace :bhf, path: Bhf::Engine.config.mount_at do
        root to: 'application#index'

        get 'page/:page', to: 'pages#show', as: :page

        scope ':platform' do
          resources :entries, except: [:index] do
            put :sort, on: :collection

            resources :embed_entries, except: [:index, :show], as: :embed
            post :duplicate, on: :member
          end
        end

      end
    }

    
    config.remove_default_routes = false
    
    # config.bhf_logic = YAML::load(IO.read('config/bhf.yml'))

  end
end

require 'bhf/i18n'
require 'bhf/active_record/active_record'
require 'bhf/active_record/upload'
require 'bhf/mongoid/document'
require 'bhf/view_helpers'
require 'bhf/data'
require 'bhf/platform'
require 'bhf/settings'
require 'bhf/pagination'
require 'bhf/form'

::I18n.send :include, Bhf::I18nTranslationFallbackHelper

if defined?(ActiveRecord)
  ::ActiveRecord::Base.send :include, Bhf::ActiveRecord::Object
end
if defined?(Mongoid)
  ::Mongoid::Document.send :include, Bhf::Mongoid::Document
end

::ActionView::Base.send :include, Bhf::ViewHelpers::ActionView
