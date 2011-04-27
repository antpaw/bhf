module Bhf
  module ViewHelpers
    module ActionView

      def bhf_edit(object, options = {})
        return unless session[Bhf::Engine.config.session_auth_name.to_s] == true

        options[:platform_name] ||= object.class.to_s.pluralize.downcase

        return unless object.bhf_can_edit?(options)

        render :partial => 'bhf/helper/frontend_edit', :locals => { :platform_name => options[:platform_name], :object => object }
      end

    end
  end
end