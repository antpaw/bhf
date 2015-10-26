module Bhf::Platform::Attribute
  class Column

    attr_reader :name, :title, :info, :type

    def initialize(props, options = {})
      @name = props.name
      @title = options[:title]
      @info = options[:info]
      @type = props.type

      @options_form_type = options[:form_type].to_sym if options[:form_type]
      @options_display_type = options[:display_type].to_sym if options[:display_type]
      @options_show_type = options[:show_type].to_sym if options[:show_type]

      @pk = options[:primary_key]
    end

    def macro
      :column
    end

    def form_type
      return @options_form_type if @options_form_type

      if name == @pk || name == 'updated_at' || name == 'created_at'
        :static
      elsif name == 'type'
        :type
      else
        supported_types(@type)
      end
    end

    def display_type
      return @options_display_type if @options_display_type

      if name == @pk
        :primary_key
      elsif name == 'type'
        :type
      else
        supported_types(@type)
      end
    end

    def show_type
      @options_show_type || display_type
    end

    def reflection
      false
    end

    def db_name
      name
    end

    def reorderble
      true
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
end
