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

    def load_config
      roles_config = roles_yml(get_account_roles(params[:bhf_area]))
      
      if Bhf::Engine.config.abstract_config.any?
        
        abstract_platform_config = get_config_array(Bhf::Engine.config.abstract_config, '/abstract')['pages'].each_with_object({}) do |abstract_pages, hash|
          abstract_pages.each do |abstract_page|
            abstract_page[1].each do |abstract_platform|
              hash.merge!(abstract_platform)
            end
          end
        end
        
        roles_config['pages'].each_with_index do |pages, i_1|
          pages.each_pair do |key_1, page|
            page.each_with_index do |platform, i_2|
              platform.each_pair do |key_2, value|
                abstract_platform_key = if value.to_h['extend_abstract']
                  value.to_h['extend_abstract']
                elsif abstract_platform_config[key_2]
                  key_2
                end
                next unless abstract_platform_key
                roles_config['pages'][i_1][key_1][i_2][key_2] = abstract_platform_config[abstract_platform_key].deep_merge(value.to_h)
              end
            end
          end
        end
      end
      
      @config = Bhf::Settings.new(roles_config)
    end


    def get_config_array(array, dir)
      array.each_with_object({'pages' => []}) do |r, account_roles|
        pages = load_yml("#{dir}/#{r}")['pages']
        account_roles['pages'] += pages if pages
      end
    end
    
    def roles_yml(roles = nil)
      area_dir = "/#{params[:bhf_area]}" if params[:bhf_area].present?
      if roles.is_a?(String)
        load_yml("#{area_dir}/#{roles}")
      elsif roles.is_a?(Array)
        files = get_config_array(roles, area_dir)

        # find the same pages and merge them
        merged_files = {'pages' => []}
        files['pages'].each do |pages|
          merged = false
          pages.each_pair do |key, page|
            merged_files['pages'].each do |m_page|
              if m_page.include?(key)
                merged = true
                m_page[key] = m_page[key] + page
              end
            end
          end
          if !merged
            merged_files['pages'] << pages
          end
        end
        merged_files
      else
        load_yml
      end
    end

    def load_yml(suffix = nil)
      YAML::load(IO.read("config/bhf#{suffix}.yml"))
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


    def set_title
      @app_title = Rails.application.class.to_s.split('::').first
      @title = Bhf::Engine.config.page_title || ("#{@app_title} &ndash; Admin").html_safe
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
