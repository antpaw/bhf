module Bhf
  module ActiveRecord

      # TODO: Test this
      def to_bhf_s
        if self.respond_to? :model_name
          # TODO: Why does rails use .human ?
          return model_name.human
        end

        return title if self.respond_to? :title
        return name if self.respond_to? :name

        if self.respond_to? :attributes
          return title if attributes['title']
          return name if attributes['name']
          return "#{self.class.to_s.humanize} ID: #{id}" if attributes['id']
        end

        self.to_s.humanize
      end

  end
end