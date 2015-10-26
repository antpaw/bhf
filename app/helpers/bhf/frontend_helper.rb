module Bhf
  module FrontendHelper

    def bhf_edit(object, options = {}, &block)
      return unless session[Bhf.configuration.session_auth_name.to_s] == true

      options[:platform_name] ||= object.class.to_s.pluralize.downcase

      if object.respond_to?(:'bhf_can_edit?', true)
        return unless object.bhf_can_edit?(options)
      end

      area = if options[:area]
        options[:area]
      elsif object.respond_to?(:bhf_area, true)
        object.bhf_area(options)
      end

      render partial: 'bhf/helper/frontend_edit', locals: { area: area, platform_name: options[:platform_name], object: object, block: (with_output_buffer(&block) if block_given?)}
    end

  end
end
