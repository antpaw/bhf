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
    
    class Field
      
      attr_accessor :info
      
      def initialize(props, options = {}, pk = 'id')
        @props = props
        @info = options[:info] if options[:info]

        @overwrite_type = options[:overwrite_type].to_sym if options[:overwrite_type]
      
        @primary_key = pk
      end
      
      def macro
        :column
      end
      
      def type
        return @overwrite_type if @overwrite_type
        
        @props.type
      end

      def form_type
        return @overwrite_type if @overwrite_type

        if name === @primary_key || name === 'updated_at' || name === 'created_at'
          :static
        else
          supported_types(@props.type)
        end
      end

      def display_type
        if name === @primary_key
          :primary_key
        elsif name === 'updated_at' || name === 'created_at'
          :date
        else
          supported_types(@props.type)
        end
      end

      def name
        @props.name
      end

      private

        def supported_types(check_type)
          if [:boolean, :text].include?(check_type)
            check_type
          elsif type_sym = group_types(check_type)
            type_sym
          else
            :string
          end
        end

        def group_types(type_sym)
          return :date if [:date, :datetime, :timestamp, :time, :year].include?(type_sym)
          return :number if [:integer, :float].include?(type_sym)
        end
      
    end
    
    class Reflection
      
      attr_accessor :reflection, :info, :link
      
      def initialize(reflection, options = {})
        @reflection = reflection
        @info = options[:info] if options[:info]
        @link = options[:link].to_sym if options[:link]

        @overwrite_type = options[:overwrite_type].to_sym if options[:overwrite_type]
      end
      
      def macro
        @reflection.macro
      end
      
      def type
        return @overwrite_type if @overwrite_type
        
        if macro === :has_and_belongs_to_many
          :check_box
        elsif macro === :belongs_to
          :select
        else
          :static
        end
      end
      
      def form_type
        type
      end

      def display_type
        :default
      end
      
      def name
        @reflection.name.to_s
      end
      
    end
    
  end  
end
