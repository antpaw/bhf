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
        attr_reader :name, :macro, :klass, :primary_key_name

        def initialize(mongoid_field)
          @name = mongoid_field.name
          @klass = mongoid_field.class_name.constantize
          @primary_key_name = mongoid_field.key
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
    
        if self.respond_to? :attributes
          return title if attributes['title']
          return name if attributes['name']
          return "#{self.class.to_s.humanize} ID: #{send(self.class.primary_key)}" if attributes[self.class.primary_key]
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
        
        def bhf_primary_key
          '_id'
        end
        
        def except(key)
          if key == :order || key == :sort
            #order_by.extras(:sort => []) #TODO: drop default_scope criteria
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
          return where(:name => /^antp/i)
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
            if parent.relations[meta.inverse_of.to_s].macro == :embeds_one
              parent.send("build_#{meta.inverse_of}", params)
            else
              parent.send(meta.inverse_of).build(params)
            end
          end
        end

        def bhf_find_embed(parent_id, ref_id)
          get_embedded_parent parent_id do |parent, meta|
            relation = parent.send(meta.inverse_of)
            if parent.relations[meta.inverse_of.to_s].macro == :embeds_one
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
