module Bhf
  module ApplicationHelper

    def show_t(platform)
      t("bhf.helpers.entry.models.#{platform.model_name}.show", platform_title: platform.title_singular.titleize, default: t('bhf.helpers.entry.show')).html_safe
    end

    def new_t(platform)
      t("bhf.helpers.entry.models.#{platform.model_name}.new", platform_title: platform.title_singular.titleize, default: t('bhf.helpers.entry.new')).html_safe
    end

    def duplicate_t(platform)
      t("bhf.helpers.entry.models.#{platform.model_name}.duplicate", platform_title: platform.title_singular.titleize, default: t('bhf.helpers.entry.duplicate')).html_safe
    end

    def edit_t(platform)
      t("bhf.helpers.entry.models.#{platform.model_name}.edit", platform_title: platform.title_singular.titleize, default: t('bhf.helpers.entry.edit')).html_safe
    end

    def delete_t(platform)
      t("bhf.helpers.entry.models.#{platform.model_name}.delete", platform_title: platform.title_singular.titleize, default: t('bhf.helpers.entry.delete')).html_safe
    end
    
    def find_smallest_size_url_for_file(file)
      if file.exists?(:thumb)
        file.url(:thumb)
      elsif file.exists?(:medium)
        file.url(:medium)
      else
        file.url
      end
    end

    def type_is_image?(type)
      Bhf.configuration.paperclip_image_types.include?(type)
    end
    
  end
end
