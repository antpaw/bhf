module Bhf
  module ApplicationHelper

    def show_t(platform)
      t("bhf.helpers.entry.models.#{platform.model_name}.show", platform_name: platform.title_singular, default: t('bhf.helpers.entry.show')).html_safe
    end

    def new_t(platform)
      t("bhf.helpers.entry.models.#{platform.model_name}.new", platform_name: platform.title_singular, default: t('bhf.helpers.entry.new')).html_safe
    end

    def duplicate_t(platform)
      t("bhf.helpers.entry.models.#{platform.model_name}.duplicate", platform_name: platform.title_singular, default: t('bhf.helpers.entry.duplicate')).html_safe
    end

    def edit_t(platform)
      t("bhf.helpers.entry.models.#{platform.model_name}.edit", platform_name: platform.title_singular, default: t('bhf.helpers.entry.edit')).html_safe
    end

    def delete_t(platform)
      t("bhf.helpers.entry.models.#{platform.model_name}.delete", platform_name: platform.title_singular, default: t('bhf.helpers.entry.delete')).html_safe
    end

  end
end