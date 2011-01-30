module Bhf
  module BhfHelper

    def node(f, column, &block)
      render :partial => 'bhf/helper/node', :locals => {:f => f, :column => column, :input => with_output_buffer(&block)}
    end



    def new_t(platform)
      t("bhf.helpers.entry.models.#{platform.model_name}.new", :model => platform.model.to_bhf_s, :default => t('bhf.helpers.entry.new'))
    end
    
    def edit_t(platform)
      t("bhf.helpers.entry.models.#{platform.model_name}.edit", :model => platform.model.to_bhf_s, :default => t('bhf.helpers.entry.edit'))
    end

  end
end