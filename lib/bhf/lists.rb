module Bhf
  module Lists
    
    class Column
      
      attr_accessor :name, :field
      
      def initialize(name, field)
        @name = name
        @field = field
      end
      
    end
    
    class Platform
      
      attr_accessor :name, :title, :data
      
      def initialize(settings)
        @name = settings.keys[0]
        @title = I18n.t("bhf.platforms.#{@name}.title", :page => @name.humanize, :default => I18n.t('bhf.platforms.title'))
        @data = settings.values[0]
      end
      
      def objects
        if table
          if table['source']
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
          collection_content[field.name] = field
        end
        
        if table && table['columns']
          cols_array = table['columns']
        else
          cols_array = []
          
          cols_array << model.primary_key if collection_content[model.primary_key]
          
          i = 0
          collection.each do |field|
            unless [model.primary_key, 'updated_at', 'created_at'].include?(field.name) or i > 4
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
      
      def model_name
        ActiveModel::Naming.singular(model)
      end
      
      def collection
        all = {}
        
        model.columns_hash.each_pair do |name, props|
          all[name] = Bhf::Form::Field.new(props, overwrite_type(name), model.primary_key)
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
        
        id = []
        static_dates = []
        
        output = []
        all.each_pair do |key, value|
          if key === model.primary_key
            id << value
          elsif key === 'created_at' || key === 'updated_at'
            static_dates << value
          else
            output << value
          end
        end
        
        id + output.sort_by(&:name) + static_dates
      end
      
      def table
        @data['table']
      end
    
      def form
        @data['form']
      end
      
      def hooks(method)
        @data['hooks'][method.to_s] if @data['hooks']
      end
      
      private
      
        def overwrite_type(attribute)
          if form && form['types']
            return form['types'][attribute]
          end
        end
      
    end
    
  end
end
