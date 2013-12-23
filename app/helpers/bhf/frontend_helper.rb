module Bhf
  module FrontendHelper

    def bhf_edit(object, options = {}, &block)
      return unless session[Bhf::Engine.config.session_auth_name.to_s] == true

      options[:platform_name] ||= object.class.to_s.pluralize.downcase
      
      if object.respond_to?(:'bhf_can_edit?', true)
        return unless object.bhf_can_edit?(options)
      end

      render partial: 'bhf/helper/frontend_edit', locals: { platform_name: options[:platform_name], object: object, block: (with_output_buffer(&block) if block_given?)}
    end

  end
end