module Bhf
  module ApplicationHelper

    def new_t(platform)
      t("bhf.helpers.entry.models.#{platform.model_name}.new", :platform_name => platform.title.singularize.downcase, :default => t('bhf.helpers.entry.new')).capitalize
    end

    def edit_t(platform)
      t("bhf.helpers.entry.models.#{platform.model_name}.edit", :platform_name => platform.title.singularize.downcase, :default => t('bhf.helpers.entry.edit')).capitalize
    end

    def delete_t(platform)
      t("bhf.helpers.entry.models.#{platform.model_name}.delete", :platform_name => platform.title.singularize.downcase, :default => t('bhf.helpers.entry.delete')).capitalize
    end

  end
end