module Bhf
  module Lists
    
    class Column
      attr_accessor :name, :macro
      def initialize(name, macro)
        @name = name
        @macro = macro
      end
    end
    
    class Platform
      
      attr_accessor :name, :title, :data
      
      def initialize(settings)
        # i18n
        @name = settings.keys[0]
        @title = settings.keys[0]
        @data = settings.values[0]
      end
      
      def objects
        if table
          if table['source']
            # TODO: arguments for method with array
            return model.send table['source']
          elsif table['sql']
            return model.find_by_sql table['sql']
          end
        end
        model.all
      end
      
      def columns
        collection_content = {}
        collection.each do |field|
          collection_content[field.name] = field.macro
        end
        
        if table && table['columns']
          cols_array = table['columns']
        else
          cols_array = []
          
          cols_array << 'id' if collection_content['id']
          
          i = 0
          collection.each do |field|
            unless ['id', 'updated_at', 'created_at'].include?(field.name) or i > 4
              cols_array << field.name
              i += 1
            end
          end
          
          cols_array << 'updated_at' if collection_content['updated_at']
          cols_array << 'created_at' if collection_content['created_at']
        end
        
        cols_array.each_with_object([]) do |field_name, obj|
          obj << Bhf::Lists::Column.new(field_name, collection_content[field_name])
        end
      end
      
      def model
        @data['model'].constantize
      end
      
      def collection
        all = {}
        
        model.columns_hash.each_pair do |name, props|
          all[name] = Bhf::Form::Field.new(props, overwrite_type(name))
        end

        model.reflections.each_pair do |name, props|
          all[name.to_s] = Bhf::Form::Reflection.new(props, overwrite_type(name))
          
          fk = all[name.to_s].reflection.association_foreign_key
          if all.has_key?(fk)
            all.delete(fk)
          end
        end

        if form && form['display']
          return form['display'].each_with_object([]) do |attribute, obj|
            # TODO: all[attribute] can be nil if attribute doesn't exsist, throw some
            obj << all[attribute]
          end
        end
        
        output = []
        all.each_pair do |key, value|
          output << value
        end
        output
      end
      
      private
      
      def overwrite_type(attribute)
        if form && form['types'] && form['types'][attribute]
          return form['types'][attribute]
        end
      end
      
      def table
        @data['table']
      end
      
      def form
        @data['form']
      end
      
    end
    
  end
end