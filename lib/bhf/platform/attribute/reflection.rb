module Bhf::Platform::Attribute
  class Reflection
  
    attr_reader :name, :title, :info
  
    def initialize(reflection, options = {})
      @name = reflection.name.to_s
      @title = options[:title]
      @info = options[:info]
      @reflection = reflection
      
      @options_form_type = options[:form_type].to_sym if options[:form_type]
      @options_display_type = options[:display_type].to_sym if options[:display_type]
      @options_show_type = options[:show_type].to_sym if options[:show_type]
      
      @link_platform_settings = options[:link] unless options[:link].blank?
      
      @reorderble = options[:reorderble]
    end
    
    def macro
      return :has_and_belongs_to_many if @reflection.macro == :has_many && @reflection.options[:through]
      @reflection.macro
    end

    def form_type
      type
    end

    def display_type
      @options_display_type || :default
    end

    def show_type
      @options_show_type || display_type
    end
    
    def type
      return @options_form_type if @options_form_type

      if macro == :has_and_belongs_to_many
        :check_box
      elsif macro == :belongs_to
        :select
      else
        :static
      end
    end
  
    def reflection
      @reflection
    end

    def db_name
      @reflection.foreign_key
    end
    
    def reorderble
      @reorderble
    end
    
    def link
      return unless @link_platform_settings
      @link ||= Bhf::Platform::Base.new(@link_platform_settings)
    end

  end
end