Bhf::Engine.routes.draw do
  scope as: :bhf do
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
  
  #(bhf_)((.+)_?(path|url))
end
