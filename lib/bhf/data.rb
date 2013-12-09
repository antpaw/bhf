module Bhf
  module Data
    class AbstractField
      attr_reader :name, :info, :macro, :link, :display_type, :form_type, :show_type, :overwrite_type, :overwrite_display_type, :overwrite_show_type
      
      def initialize(props)
        @name = props[:name]
        @form_type = props[:form_type]
        @show_type = props[:show_type]
        @overwrite_show_type = props[:show_type]
        @display_type = props[:display_type]
        @overwrite_display_type = props[:display_type]
        @info = props[:info]
        @macro = :column
        @link = props[:link].downcase.to_sym unless props[:link].blank?
      end
    end

    class Field

      attr_reader :info, :overwrite_display_type, :overwrite_show_type

      def initialize(props, options = {}, pk = 'id')
        @props = props
        @info = options[:info]

        @overwrite_type = options[:overwrite_type].to_sym if options[:overwrite_type]
        @overwrite_display_type = options[:overwrite_display_type].to_sym if options[:overwrite_display_type]
        @overwrite_show_type = options[:overwrite_show_type].to_sym if options[:overwrite_show_type]

        @primary_key = pk
      end

      def macro
        :column
      end

      def type
        return @overwrite_type if @overwrite_type

        @props.type
      end
      
      def show_type
        return @overwrite_show_type if @overwrite_show_type
      end

      def form_type
        return @overwrite_type if @overwrite_type

        if name == @primary_key || name == 'updated_at' || name == 'created_at'
          :static
        else
          supported_types(@props.type)
        end
      end

      def display_type
        return @overwrite_display_type if @overwrite_display_type
        
        if name == @primary_key
          :primary_key
        elsif name == 'updated_at' || name == 'created_at'
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
          if [:boolean, :text, :array, :hash].include?(check_type)
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
          return :file if type_sym == :file
        end

    end


    class Reflection
      
      attr_reader :reflection, :info, :link, :overwrite_display_type, :overwrite_show_type
      
      def initialize(reflection, options = {})
        @reflection = reflection
        @info = options[:info]
        @link = options[:link].downcase.to_sym unless options[:link].blank?

        @overwrite_type = options[:overwrite_type].to_sym if options[:overwrite_type]
        @overwrite_display_type = options[:overwrite_display_type].to_sym if options[:overwrite_display_type]
        @overwrite_show_type = options[:overwrite_show_type].to_sym if options[:overwrite_show_type]
      end
      
      def macro
        @reflection.macro
      end
      
      def type
        return @overwrite_type if @overwrite_type

        if macro == :has_and_belongs_to_many
          :check_box
        elsif macro == :belongs_to
          :select
        else
          :static
        end
      end

      def form_type
        type
      end

      def display_type
        return @overwrite_display_type if @overwrite_display_type
        :default
      end

      def show_type
        return @overwrite_show_type if @overwrite_show_type
      end

      def name
        @reflection.name.to_s
      end

    end


    class Column

      attr_reader :name, :field, :overwrite_display_type

      def initialize(field)
        @name = field.name
        @field = field
      end

    end

    class Show

      attr_reader :name, :field, :overwrite_show_type

      def initialize(field)
        @name = field.name
        @field = field
      end

    end

  end  
end