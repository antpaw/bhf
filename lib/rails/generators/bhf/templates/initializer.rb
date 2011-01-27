module Bhf
  class Engine < Rails::Engine

    config.mount_at = '/bhf'
    config.page_title = 'Bahhof Admin'
        
  end
end