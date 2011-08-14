module Bhf
  module EntriesHelper
    
    def node(f, field, &block)
      render :partial => 'bhf/helper/node', :locals => {:f => f, :field => field, :input => with_output_buffer(&block)}
    end

    def reflection_node(f, field, &block)
      return if field.form_type == :static && f.object.new_record? && f.object.send(field.reflection.name).blank?
      render :partial => 'bhf/helper/reflection_node', :locals => {
        :f => f, :field => field, :input => with_output_buffer(&block)
      }
    end

    def is_image?(file)
      file.match(/\.png|\.jpg|\.jpeg|\.gif|\.svg/i).to_b
    end

    def reflection_title(f, field)
      title = f.object.class.human_attribute_name(field.reflection.name)
      if field.link
        title = t("bhf.platforms.#{field.link}.title", :count => f.object.send(field.reflection.name).to_a.count, :default => title)
      end
      title
    end
  end
end