module Bhf::Platform::Data
  class Reflection
  
    attr_reader :reflection, :info, :overwrite_display_type, :overwrite_show_type
  
    def initialize(reflection, options = {})
      @reflection = reflection
      @info = options[:info]
      @link_platform_settings = options[:link] unless options[:link].blank?

      @overwrite_type = options[:overwrite_type].to_sym if options[:overwrite_type]
      @overwrite_display_type = options[:overwrite_display_type].to_sym if options[:overwrite_display_type]
      @overwrite_show_type = options[:overwrite_show_type].to_sym if options[:overwrite_show_type]
    end
  
    def link
      return unless @link_platform_settings
      @link ||= Bhf::Platform::Base.new(@link_platform_settings)
    end
  
    def macro
      return :has_and_belongs_to_many if @reflection.macro == :has_many && @reflection.options[:through]
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
end