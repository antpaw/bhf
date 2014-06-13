module Bhf::ActionView

  class FormBuilder < ActionView::Helpers::FormBuilder
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
    
    def options_from_collection_for_select_with_link_data(collection, value_method, text_method, selected, html_attrs)
      a = Bhf::ActionView::FormOptions.new
      a.options_from_collection_for_select_with_link_data(collection, value_method, text_method, selected, html_attrs)
    end

    def many_to_many_check_box(obj, ref_name, params, hide_label = false, bhf_primary_key = nil)
      mm = :has_and_belongs_to_many
      bhf_primary_key ||= obj.send(obj.class.bhf_primary_key).to_s
      checked = if params[mm] && params[mm][ref_name]
        params[mm][ref_name][bhf_primary_key] != ''
      else
        object.send(ref_name).include?(obj)
      end

      html = hidden_field_tag("#{mm}[#{ref_name}][#{bhf_primary_key}]", '', id: "hidden_#{mm}_#{ref_name}_#{bhf_primary_key}")
      html = html+' '+check_box_tag("#{mm}[#{ref_name}][#{bhf_primary_key}]", bhf_primary_key, checked)
      html = html+' '+label_tag("#{mm}_#{ref_name}_#{bhf_primary_key}", obj.to_bhf_s) unless hide_label
      
      html
    end
  end

end  
