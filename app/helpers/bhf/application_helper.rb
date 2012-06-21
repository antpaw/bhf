module Bhf
  module ApplicationHelper

    def show_t(platform)
      t("bhf.helpers.entry.models.#{platform.model_name}.show", platform_name: platform.title_singular, default: t('bhf.helpers.entry.show'))
    end

    def new_t(platform)
      t("bhf.helpers.entry.models.#{platform.model_name}.new", platform_name: platform.title_singular, default: t('bhf.helpers.entry.new'))
    end

    def edit_t(platform)
      t("bhf.helpers.entry.models.#{platform.model_name}.edit", platform_name: platform.title_singular, default: t('bhf.helpers.entry.edit'))
    end

    def delete_t(platform)
      t("bhf.helpers.entry.models.#{platform.model_name}.delete", platform_name: platform.title_singular, default: t('bhf.helpers.entry.delete'))
    end

  end
end