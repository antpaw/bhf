module Bhf
  module EntriesHelper
    include Bhf::ActionView::FormOptions

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

    def reflection_title(f, field, count = 2)
      title = f.object.class.human_attribute_name(field.reflection.name)
      if field.link
        title = t("bhf.platforms.#{field.link.name}.title", count: count, default: title)
      end
      title
    end

  end
end
