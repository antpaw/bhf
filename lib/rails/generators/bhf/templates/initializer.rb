module Bhf
  class Engine < Rails::Engine

    config.page_title = 'Bahhof Admin'
    config.mount_at = '/bhf'
    # config.auth_logic_from = 'ApplicationController'
        
  end
end