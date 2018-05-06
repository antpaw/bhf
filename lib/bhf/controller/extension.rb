module Bhf
  module Extension
    module ApplicationController
      extend ActiveSupport::Concern

      included do
        include Instance

        before_action :init_time
        before_action :check_admin_account, :setup_current_account,
          :load_settings, :set_title, :set_areas

        helper_method :current_account
        layout 'bhf/application'
      end

      module Instance
        def index

        end

        protected

        def check_admin_account
          if session[Bhf.configuration.session_auth_name.to_s] == true
            return true
          end
          redirect_to(main_app.send(Bhf.configuration.on_login_fail.to_sym),
            error: t('bhf.helpers.user.login.error')) and return false
        end

        def setup_current_account
          if session[Bhf.configuration.session_account_id]
            @current_account =
            Bhf.configuration.account_model.classify.constantize.send(
              Bhf.configuration.account_model_find_method.to_sym,
              session[Bhf.configuration.session_account_id.to_s]
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
            if current_account.respond_to?(:bhf_area_roles)
              return current_account.bhf_area_roles(area).collect(&:identifier)
            end
          end

          if current_account.respond_to?(:bhf_roles)
            current_account.bhf_roles.collect(&:identifier)
          end
        end

        def load_settings
          yaml_parser = Bhf::Settings::YAMLParser.new(get_account_roles(
            params[:bhf_area]), params[:bhf_area])
          @settings =
          Bhf::Settings::Base.new(yaml_parser.settings_hash, current_account)
        end

        def set_title
          @app_title = Rails.application.class.to_s.split('::').first

          @title = if params[:bhf_area]
            t("bhf.areas.page_title.#{params[:bhf_area]}",
              area: params[:bhf_area],
              title: @app_title,
              default: t('bhf.areas.page_title',
                title: @app_title,
                area: t("bhf.areas.links.#{params[:bhf_area]}",
                default: params[:bhf_area])
              )
            )
          else
            t('bhf.page_title', title: @app_title)
          end.html_safe
        end

        def set_areas
          @areas = []
          if current_account and current_account.respond_to?(:bhf_areas)
            current_account.bhf_areas.each do |area|
              selected = params[:bhf_area] == area.identifier
              @areas << OpenStruct.new(
                name: area.to_bhf_s,
                selected: selected,
                path: main_app.bhf_path(area.identifier)
              )
              @root_link = area.link if selected
            end
          end
        end

        def set_message(type, model = nil)
          key = model && ActiveModel::Naming.singular(model)
          I18n.t("bhf.activerecord.notices.models.#{key}.#{type}",
            model: model.model_name.human,
            default: I18n.t("activerecord.notices.messages.#{type}"))
        end

        def init_time
          @start_time = Time.zone.now
        end

        def find_platform(platform_name)
          Bhf::Platform::Base.new(@settings.find_platform_settings(platform_name))
        end

        def redirect_back_or_default(default, msg)
          redirect_to(params[:return_to] || default, flash: msg)
        end
      end
    end
  end
end
