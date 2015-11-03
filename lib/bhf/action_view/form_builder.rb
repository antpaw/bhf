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

    def many_to_many_or_has_many_check_box(mm, obj, ref_name, params, hide_label = false, checked = false, bhf_primary_key = nil, extra_html_attrs = {})
      bhf_primary_key ||= obj.send(obj.class.bhf_primary_key).to_s
      unless checked
        checked = if params[mm] && params[mm][ref_name]
          params[mm][ref_name][bhf_primary_key] != ''
        else
          object.send(ref_name).include?(obj)
        end
      end

      html = hidden_field_tag("#{mm}[#{ref_name}][#{bhf_primary_key}]", '', extra_html_attrs.merge(id: "hidden_#{mm}_#{ref_name}_#{bhf_primary_key}"))
      html = html+' '+check_box_tag("#{mm}[#{ref_name}][#{bhf_primary_key}]", bhf_primary_key, checked, extra_html_attrs)
      html = html+' '+label_tag("#{mm}_#{ref_name}_#{bhf_primary_key}", obj.to_bhf_s) unless hide_label

      html
    end

    def many_to_many_check_box(obj, ref_name, params, hide_label = false, checked = false, bhf_primary_key = nil, extra_html_attrs = {})
      many_to_many_or_has_many_check_box(:has_and_belongs_to_many, obj, ref_name, params, hide_label, checked, bhf_primary_key, extra_html_attrs)
    end

    def has_many_check_box(obj, ref_name, params, hide_label = false, checked = false, bhf_primary_key = nil, extra_html_attrs = {})
      many_to_many_or_has_many_check_box(:has_many, obj, ref_name, params, hide_label, checked, bhf_primary_key, extra_html_attrs)
    end

  end
end
