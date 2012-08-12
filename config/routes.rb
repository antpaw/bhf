Rails.application.routes.draw do
  
  Bhf::Engine.config.routes = lambda do
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
  end
  
  Bhf::Engine.config.routes.call unless Bhf::Engine.config.remove_default_routes
  
end