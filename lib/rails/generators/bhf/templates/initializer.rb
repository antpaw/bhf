module Bhf
  class Engine < Rails::Engine

    config.mount_at = '/bhf'
    config.widget_factory_name = 'Factory Name'
        
  end
end
