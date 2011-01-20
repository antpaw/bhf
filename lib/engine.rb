require 'bhf'
require 'rails'
require 'haml'

module Bhf
  class Engine < Rails::Engine

    # Config defaults
    config.widget_factory_name = "default factory name"
    config.mount_at = 'bhf'

    initializer "static assets" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end

  end
end
