module Bhf
  module ActiveRecord

      def to_bhf_s
        return title if self.respond_to? :title
        return name if self.respond_to? :name

        if self.respond_to? :attributes
          return title if attributes['title']
          return name if attributes['name']
          return "#{self.class.to_s.humanize} ID: #{send(self.class.primary_key)}" if attributes[self.class.primary_key]
        end

        self.to_s.humanize
      end

  end
end