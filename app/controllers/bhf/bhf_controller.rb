class Bhf::BhfController < ActionController::Base
  
  protect_from_forgery
  
  before_filter :check_admin_account, :load_config, :set_title

  helper_method :entry_path, :new_entry_path, :entries_path, :edit_entry_path
  layout 'bhf/default'

  def index
    
  end


  private

    def check_admin_account
      auth_logic = Bhf::Engine.config.auth_logic_from.constantize.new
      
      if auth_logic.respond_to?(:current_admin_account) && auth_logic.current_admin_account
        return true
      else
        redirect_to(root_url, :error => I18t.t('bhf.helpers.login.error')) and return false
      end
    end

    def load_config
      @config = Bhf::Settings.new(
        YAML::load(IO.read('config/bhf.yml'))
        # Bhf::Engine.config.bhf_logic
      )
    end


    def new_entry_path(platform, extra_params = {})
      new_bhf_entry_path platform, extra_params
    end

    def entries_path(platform, extra_params = {})
      bhf_entries_path platform, extra_params
    end

    def entry_path(platform, object, extra_params = {})
      bhf_entry_path platform, object, extra_params
    end

    def edit_entry_path(platform, object, extra_params = {})
      edit_bhf_entry_path platform, object, extra_params
    end


    def set_title
      @title = Bhf::Engine.config.page_title ||
               Rails.application.class.to_s.split('::').first+' — Admin'
    end

    def set_message(type, model = nil)
      key = model && ActiveModel::Naming.singular(model)
      
      I18n.t("bhf.activerecord.notices.models.#{key}.#{type}", :model => model.model_name.human, :default => I18n.t("activerecord.notices.messages.#{type}"))
    end


    def store_location
      session[:return_to] = request.fullpath
    end

    def redirect_back_or_default(default, msg)
      redirect_to(session[:return_to] || default, msg)
      session[:return_to] = nil
    end

end
