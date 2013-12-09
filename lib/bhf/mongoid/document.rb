module Bhf
  module Mongoid
    module Document
      
      extend ActiveSupport::Concern

      class Field
        attr_reader :type, :name

        def initialize(mongoid_field)
          @name = mongoid_field.name
          @type = mongoid_field.type.to_s.downcase.to_sym
          @type = :primary_key if @type == :'bson::objectid'
        end
      end

      class Reflection
        attr_reader :name, :macro, :klass, :foreign_key

        def initialize(mongoid_field)
          @name = mongoid_field.name
          @klass = mongoid_field.class_name.constantize
          @foreign_key = mongoid_field.key
          @macro = case mongoid_field.macro
            when :references_and_referenced_in_many
              :has_and_belongs_to_many
            when :references_many
              :has_many
            when :references_one
              :has_one
            when :referenced_in
              :belongs_to
            else
              mongoid_field.macro
          end
        end
      end
  
      def to_bhf_s
        return title if self.respond_to? :title
        return name if self.respond_to? :name

        if self.respond_to?(:attributes)
          return title if attributes['title']
          return name if attributes['name']
          klass_name = if self.class.respond_to?(:model_name)
            self.class.model_name.human
          else
            self.class.to_s.humanize
          end
          return "#{klass_name} ID: #{send(self.class.bhf_primary_key)}" if attributes[self.class.bhf_primary_key]
        end

        self.to_s.humanize
      end

      module ClassMethods
        def columns_hash
          c = {}
          fields.each_pair do |key, meta|
            next if meta.options[:metadata]
            next if key == '_type'
            c[key] = Field.new(meta)
          end
          c
        end
        
        def reflections
          c = {}
          relations.each do |key, meta|
            next if meta.macro == :embedded_in
            c[key.to_sym] = Reflection.new(meta)
          end
          c
        end
        
        def bhf_attribute_method?(column_name)
          attribute_method?(column_name)
        end
        
        def bhf_primary_key
          '_id'
        end
        
        def except(key)
          if key == :order || key == :sort
            #order_by.extras(sort: []) #TODO: drop default_scope criteria
          end
          self
        end
        
        def order(a)
          field, direction = a.split(' ')
          return self if field.blank? or direction.blank?
          self.send(direction.downcase, field)
        end
        
        def bhf_default_search(search_params)
          return if (search_term = search_params[:text]).blank?
          
          # TODO: add mongoid search
          return where(name: /^antp/i)
          #return where("this.nick == 'antpaw'")
        end

        def get_embedded_parent(parent_id, &block)
          relations.each do |key, meta|
            next unless meta.macro == :embedded_in
            parent = meta.class_name.constantize
            parent = parent.find(parent_id) rescue nil
            
            if parent
              return parent unless block_given?
              return block.call(parent, meta)
            end
          end
        end

        def bhf_new_embed(parent_id, params = nil)
          get_embedded_parent parent_id do |parent, meta|
            key_name = if meta.inverse_of?
              meta.inverse_of
            else
              meta.inverse_foreign_key.pluralize
            end.to_s
            if parent.relations[key_name].macro == :embeds_one
              parent.send("build_#{key_name}", params)
            else
              parent.send(key_name).build(params)
            end
          end
        end

        def bhf_find_embed(parent_id, ref_id)
          get_embedded_parent parent_id do |parent, meta|
            # :forced_nil_inverse?, :foreign_key, :foreign_key_check, :foreign_key_setter, :index, :indexed?, :inspect, :inverses, :inverse, :inverse_class_name, :inverse_class_name?, :inverse_foreign_key, :inverse_klass, :inverse_metadata, :inverse_of, :inverse_of?, :inverse_setter, :inverse_type, :inverse_type_setter
            key_name = if meta.inverse_of?
              meta.inverse_of
            else
              meta.inverse_foreign_key.pluralize
            end.to_s
            relation = parent.send(key_name)
            if parent.relations[key_name].macro == :embeds_one
              relation
            else
              relation.find(ref_id)
            end
          end
        end

        def bhf_embedded?
          embedded?
        end
      end

    end
  end
end
