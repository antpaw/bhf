module Bhf::Platform::Attribute
  class Abstract

    attr_reader :name, :title, :info

    def initialize(options)
      @name = options[:name]
      @title = options[:title]
      @info = options[:info]

      @options_form_type = options[:form_type].to_sym if options[:form_type]
      @options_display_type = options[:display_type].to_sym if options[:display_type]
      @options_show_type = options[:show_type].to_sym if options[:show_type]

      @link_platform_settings = options[:link] unless options[:link].blank?
    end

    def macro
      :column
    end

    def form_type
      @options_form_type || @name
    end

    def display_type
      @options_display_type || @name
    end

    def show_type
      @options_show_type || display_type || @name
    end

    def link
      return unless @link_platform_settings
      @link ||= Bhf::Platform::Base.new(@link_platform_settings)
    end

    def reflection
      false
    end

    def db_name
      name
    end

    def reorderble
      false
    end

  end
end
