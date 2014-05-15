class Bhf::ApplicationController < ActionController::Base

  before_filter :init_time, :check_admin_account, :setup_current_account, :load_config, :set_title, :set_areas

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

    def get_account_roles(area = nil)
      return unless current_account
      
      if area
        if current_account.respond_to?(:area_role)
          return current_account.area_role(area)
        elsif current_account.respond_to?(:area_roles)
          return current_account.area_roles(area).collect(&:to_bhf_s)
        end
      end

      if current_account.respond_to?(:role)
        current_account.role.is_a?(String) ? current_account.role : current_account.role.to_bhf_s
      elsif current_account.respond_to?(:roles)
        current_account.roles.collect(&:to_bhf_s)
      end
    end

    def load_config
      @config = Bhf::ConfigParser::parse(get_account_roles(params[:bhf_area]), params[:bhf_area])
    end

    def set_title
      @app_title = Rails.application.class.to_s.split('::').first
      
      @title = if Bhf::Engine.config.page_title
        Bhf::Engine.config.page_title
      else
        if params[:bhf_area]
          t("bhf.areas.page_title.#{params[:bhf_area]}", 
            area: params[:bhf_area],
            title: @app_title,
            default: t('bhf.areas.page_title', 
              title: @app_title,
              area: t("bhf.areas.links.#{params[:bhf_area]}", default: params[:bhf_area])
            )
          )
        else
          t('bhf.page_title', title: @app_title)
        end
      end.html_safe
    end
    
    def set_areas
      @areas = []
      if current_account and current_account.respond_to?(:bhf_areas)
        current_account.bhf_areas.each do |area|
          @areas << OpenStruct.new(
            name: t("bhf.areas.links.#{area.to_bhf_s}", default: area.to_bhf_s),
            selected: params[:bhf_area] == area.to_bhf_s,
            path: main_app.bhf_path(area.to_bhf_s)
          )
        end
      end
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
      redirect_to(params[:return_to] || default, flash: msg)
    end

end
