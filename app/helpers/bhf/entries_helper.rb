module Bhf
  module EntriesHelper
    
    def node(f, field, &block)
      render :partial => 'bhf/helper/node', :locals => {:f => f, :field => field, :input => with_output_buffer(&block)}
    end

    def reflection_node(f, field, &block)
      return if field.form_type === :static && f.object.new_record? && f.object.send(field.reflection.name).blank?
      render :partial => 'bhf/helper/reflection_node', :locals => {
        :f => f, :field => field, :input => with_output_buffer(&block)
      }
    end

  end
end