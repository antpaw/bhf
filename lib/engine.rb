require 'haml'
require 'will_paginate'

module Bhf
  class Engine < Rails::Engine

    # Config defaults
    config.page_title = nil
    config.mount_at = 'bhf'
    config.session_auth_name = :is_admin
    config.current_admin_account = nil
    config.css = []
    
    
    # config.bhf_logic = YAML::load(IO.read('config/bhf.yml'))

    initializer 'static assets' do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end

  end
end
