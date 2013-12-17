module Bhf
  module FrontendHelper

    def bhf_edit(object, options = {}) # TODO: add a block of html for custom editing buttons and links
      return unless session[Bhf::Engine.config.session_auth_name.to_s] == true

      options[:platform_name] ||= object.class.to_s.pluralize.downcase
      
      if object.respond_to?(:'bhf_can_edit?', true)
        return unless object.bhf_can_edit?(options)
      end

      render partial: 'bhf/helper/frontend_edit', locals: { platform_name: options[:platform_name], object: object }
    end

  end
end