Rails.application.routes.draw do
  
  namespace :bhf, :path => Bhf::Engine.config.mount_at do
    root :to => 'application#index'
    
    get 'page/:page', :to => 'pages#show', :as => :page
    
    scope ':platform' do
      resources :entries, :except => [:index, :show] do
        collection do 
          get :sort
        end
      end
    end

  end

end