module Bhf
  module ActiveRecord
    module Object

      extend ActiveSupport::Concern
      
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

      module ClassMethods
        def bhf_default_search(search_params)
          return if (search_term = search_params[:text]).blank?
          where_statement = []
          columns_hash.each_pair do |name, props|
            is_number = search_term.to_i.to_s == search_term || search_term.to_f.to_s == search_term

            if props.type == :string || props.type == :text
              where_statement << "LOWER(#{name}) LIKE LOWER('%#{search_term}%')"
            elsif props.type == :integer && is_number
              where_statement << "#{name} = #{search_term.to_i}"
            elsif props.type == :float && is_number
              where_statement << "#{name} = #{search_term.to_f}"
            end
          end

          where_statement.join(' OR ')
        end
        
        def bhf_primary_key
          primary_key
        end
        
        def bhf_embedded?
          false
        end
      end
      
    end
  end
end