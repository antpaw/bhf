module Bhf
  class Engine < Rails::Engine

    config.page_title = 'Bahnhof Admin'
    config.mount_at = '/bhf'
    # config.current_admin_account = :current_user
    # config.session_auth_name = :admin
    # config.css = ['bhf_extend']
  end
end