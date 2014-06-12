module Bhf::Platform::Data
  class AbstractField
    attr_reader :name, :info, :macro, :display_type, :form_type, :show_type, :overwrite_type, :overwrite_display_type, :overwrite_show_type
    
    def initialize(props)
      @name = props[:name]
      @form_type = props[:form_type]
      @show_type = props[:show_type]
      @overwrite_show_type = props[:show_type]
      @display_type = props[:display_type]
      @overwrite_display_type = props[:display_type]
      @info = props[:info]
      @macro = :column
      @link_platform_settings = props[:link] unless props[:link].blank?
    end
    
    def link
      return unless @link_platform_settings
      @link ||= Bhf::Platform::Base.new(@link_platform_settings)
    end
    
  end
end