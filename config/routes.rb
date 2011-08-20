Rails.application.routes.draw do
  
  namespace :bhf, :path => Bhf::Engine.config.mount_at do
    root :to => 'application#index'
    
    get 'page/:page', :to => 'pages#show', :as => :page
    
    scope ':platform' do
      resources :entries, :except => [:index, :show] do
        resources :embed_entries, :except => [:index, :show], :as => :embed
        collection do 
          # TODO: put it
          get :sort
        end
      end
    end

  end

end