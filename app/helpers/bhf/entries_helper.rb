module Bhf
  module EntriesHelper
    
    def node(f, field, &block)
      render partial: 'bhf/helper/node', locals: {f: f, field: field, input: with_output_buffer(&block)}
    end
    
    def definition_item(object, column, &block)
      render partial: 'bhf/helper/definition_item', locals: {object: object, column: column, content: with_output_buffer(&block)}
    end
    
    def reflection_node(f, field, &block)
      return if !f.object.respond_to?(field.reflection.name) || (field.form_type == :static && f.object.new_record? && f.object.send(field.reflection.name).blank?)
      render partial: 'bhf/helper/reflection_node', locals: {
        f: f, field: field, input: with_output_buffer(&block)
      }
    end
    
    def reflection_title(f, field)
      title = f.object.class.human_attribute_name(field.reflection.name)
      if field.link
        title = t("bhf.platforms.#{field.link}.title", count: f.object.send(field.reflection.name).to_a.count, default: title)
      end
      title
    end
  end
end