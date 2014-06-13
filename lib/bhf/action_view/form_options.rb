module Bhf::ActionView
  class FormOptions
  
    include ActionView::Helpers::FormOptionsHelper

  
    def options_from_collection_for_select_with_link_data(collection, value_method, text_method, selected, html_attrs)
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