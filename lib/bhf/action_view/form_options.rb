module Bhf::ActionView
  module FormOptions

    def option_groups_from_collection_for_select_with_html_attrs(collection, group_method, group_label_method, option_key_method, option_value_method, selected_key, html_attrs)
      collection.map do |group|
        option_tags = options_from_collection_for_select_with_html_attrs(
          group.send(group_method), option_key_method, option_value_method, selected_key, html_attrs)

        content_tag(:optgroup, option_tags, label: group.send(group_label_method))
      end.join.html_safe
    end

    def options_from_collection_for_select_with_html_attrs(collection, value_method, text_method, selected, html_attrs)
      options = collection.map do |element|
        [
          value_for_collection(element, text_method), value_for_collection(element, value_method), option_html_attributes(element),
          html_attrs.call(element)
        ]
      end
      selected, disabled = extract_selected_and_disabled(selected)
      select_deselect = {
        selected: extract_values_from_collection(collection, value_method, selected),
        disabled: extract_values_from_collection(collection, value_method, disabled)
      }

      options_for_select(options, select_deselect)
    end

  end
end
