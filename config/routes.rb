Rails.application.routes.draw do
  
  namespace :bhf, :path => Bhf::Engine.config.mount_at do
    root :to => 'bhf#index'
    
    get 'page/:page', :to => 'pages#show', :as => :page
    
    scope ':platform' do
      resources :entries, :except => [:index]
    end

  end

end