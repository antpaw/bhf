Rails.application.routes.draw do
  
  namespace :bhf, :path => Bhf::Engine.config.mount_at do
    root :to => 'bhf#index'
    
    get 'page/:slug', :to => 'pages#show', :as => :page
    
    scope ':source' do
      resources :entries, :except => [:index]
    end
    
    # resources :entries do
    #   collection do
    #     get  ':source', :action => 'index'
    #   end
    # end
    
    # resource :entry, :only => [] do
    #   get  ':source/new', :action => 'new',    :as => :new
    #   post ':source',     :action => 'create'
    #   member do
    #     get    ':source/:id/edit', :action => 'edit',  :as => :edit
    #     get    ':source/:id',      :action => 'show',  :as => ''
    #     put    ':source/:id',      :action => 'update'
    #     delete ':source/:id',      :action => 'destroy'
    #   end
    # end
    
    # get     'crud/:source',           :to => 'crud#index',   :as => :list_entries
    # post    'crud/:source',           :to => 'crud#create',  :as => :create_entry
    # get     'crud/:source/:id',       :to => 'crud#show',    :as => :show_entry
    # get     'crud/:source/:id/edit',  :to => 'crud#edit',    :as => :edit
    # put     'crud/:source/:id',       :to => 'crud#update',  :as => :edit_entry
    # delete  'crud/:source/:id',       :to => 'crud#delete',  :as => :delete_entry
  end

end