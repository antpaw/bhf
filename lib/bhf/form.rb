module Bhf
  module Form
    
    class Builder < ActionView::Helpers::FormBuilder
      include ActionView::Helpers::FormTagHelper
      
      def error_label(name, message)
        label name, "#{name.to_s.humanize} #{message}"
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
    
    class Field
      
      def initialize(props, overwrite_type = nil)
        @props = props
        @overwrite_type = overwrite_type
      end
      
      def macro
        :column
      end
      
      def type
        return @overwrite_type if @overwrite_type
        
        # TODO: int and float are different, really?
        if name === 'id' || name === 'updated_at' || name === 'created_at'
          'static'
        elsif [:integer, :float, :boolean, :text, :datetime].include?(@props.type)
          @props.type
        else
          'string'
        end
      end
      
      def name
        @props.name
      end
      
    end
    
    class Reflection
      
      attr_accessor :reflection
      
      def initialize(reflection, overwrite_type = nil)
        @reflection = reflection
        @overwrite_type = overwrite_type
      end
      
      def macro
        @reflection.macro
      end
      
      def type
        return @overwrite_type if @overwrite_type
        
        if macro === :has_and_belongs_to_many
          'check_box'
        elsif macro === :belongs_to
          'select'
        else
          'static'
        end
      end
      
      def name
        @reflection.name
      end
      
    end
    
  end  
end