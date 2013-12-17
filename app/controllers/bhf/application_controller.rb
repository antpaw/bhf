class Bhf::ApplicationController < ActionController::Base

  before_filter :init_time, :check_admin_account, :setup_current_account, :load_config, :set_title

  helper_method :current_account
  layout 'bhf/application'

  def index
    
  end

  private

    def check_admin_account
      if session[Bhf::Engine.config.session_auth_name.to_s] == true
        return true
      end

      redirect_to(main_app.send(Bhf::Engine.config.on_login_fail.to_sym), error: t('bhf.helpers.user.login.error')) and return false
    end

    def setup_current_account
      if session[Bhf::Engine.config.session_account_id]
        @current_account = Bhf::Engine.config.account_model.constantize.send(
          Bhf::Engine.config.account_model_find_method.to_sym,
          session[Bhf::Engine.config.session_account_id.to_s]
        )
        # => User.find(current_account.id)
      end
    end

    def current_account
      @current_account
    end

    def load_config
      @config = Bhf::Settings.new(roles_yml(get_account_roles))
    end

    def roles_yml(roles = nil)
      if roles.is_a?(String)
        load_yml("/#{roles}")
      elsif roles.is_a?(Array)
        files = roles.each_with_object({'pages' => []}) do |r, account_roles|
          pages = load_yml("/#{r}")['pages']
          account_roles['pages'] += pages if pages
        end
        # TODO: merge platforms of the same pages rather the replace them 
        files['pages'].uniq! do |a|
          a.keys
        end
        files
      else
        load_yml
      end
    end

    def load_yml(suffix = nil)
      YAML::load(IO.read("config/bhf#{suffix}.yml"))
    end

    def get_account_roles
      return unless current_account

      if current_account.respond_to?(:role)
        current_account.role.is_a?(String) ? current_account.role : current_account.role.to_bhf_s
      elsif current_account.respond_to?(:roles)
        current_account.roles.collect(&:to_bhf_s)
      end
    end


    def set_title
      @title = Bhf::Engine.config.page_title ||
               (Rails.application.class.to_s.split('::').first+' &ndash; Admin').html_safe
    end

    def set_message(type, model = nil)
      key = model && ActiveModel::Naming.singular(model)
      
      I18n.t("bhf.activerecord.notices.models.#{key}.#{type}", model: model.model_name.human, default: I18n.t("activerecord.notices.messages.#{type}"))
    end

    def init_time
      @start_time = Time.now
    end


    def store_location
      session[:return_to] = request.fullpath
    end

    def redirect_back_or_default(default, msg)
      redirect_to(session[:return_to] || default, msg)
      session[:return_to] = nil
    end

end
