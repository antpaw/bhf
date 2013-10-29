unless Bhf::Engine.config.remove_default_routes
  Rails.application.routes.draw(&Bhf::Engine.config.bhf_routes)
end