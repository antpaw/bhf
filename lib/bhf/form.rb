module Bhf
  module Form

    class Builder < ActionView::Helpers::FormBuilder
      include ActionView::Helpers::FormTagHelper

      def error_label(name, message)
        label name, "#{object.class.human_attribute_name(name)} #{message}"
      end

      def field_errors(field)
        object.errors[field.to_sym]
      end

      def field_has_errors?(field)
        field_errors(field).any?
      end

      def many_to_many_check_box(obj, ref_name, params)
        mm = :has_and_belongs_to_many
        checked = if params[mm] && params[mm][ref_name]
          params[mm][ref_name][obj.id.to_s] != ''
        else
          object.send(ref_name).include?(obj)
        end

        hidden_field_tag("#{mm}[#{ref_name}][#{obj.id}]", '', :id => "hidden_has_and_belongs_to_many_#{ref_name}_#{obj.id}")+' '+
        check_box_tag("#{mm}[#{ref_name}][#{obj.id}]", obj.id, checked)+' '+
        label_tag("#{mm}_#{ref_name}_#{obj.id}", obj.to_bhf_s)
      end

    end

  end  
end
