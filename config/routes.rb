Rails.application.routes.draw do
  
  namespace :bhf, :path => Bhf::Engine.config.mount_at do
    root :to => 'bhf#index'
    
    get 'page/:page', :to => 'pages#show', :as => :page
    
    scope ':platform' do
      resources :entries, :except => [:index]
    end
    
    # resources :entries do
    #   collection do
    #     get  ':platform', :action => 'index'
    #   end
    # end
    
    # resource :entry, :only => [] do
    #   get  ':platform/new', :action => 'new',    :as => :new
    #   post ':platform',     :action => 'create'
    #   member do
    #     get    ':platform/:id/edit', :action => 'edit',  :as => :edit
    #     get    ':platform/:id',      :action => 'show',  :as => ''
    #     put    ':platform/:id',      :action => 'update'
    #     delete ':platform/:id',      :action => 'destroy'
    #   end
    # end
    
    # get     'crud/:platform',           :to => 'crud#index',   :as => :list_entries
    # post    'crud/:platform',           :to => 'crud#create',  :as => :create_entry
    # get     'crud/:platform/:id',       :to => 'crud#show',    :as => :show_entry
    # get     'crud/:platform/:id/edit',  :to => 'crud#edit',    :as => :edit
    # put     'crud/:platform/:id',       :to => 'crud#update',  :as => :edit_entry
    # delete  'crud/:platform/:id',       :to => 'crud#delete',  :as => :delete_entry
  end

end