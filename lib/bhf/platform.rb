module Bhf
  class Platform
    
    attr_accessor :paginated_objects
    attr_reader :name, :title, :data, :page_name, :objects, :collection, :columns
    
    def initialize(options, page_name)
      @paginated_objects = []

      if options.is_a?(String)
        options = {options => nil}
      end
      @name = options.keys[0]
      @data = options.values[0] || {}

      human_title = if model.to_s === @name.singularize.camelize
        model.model_name.human
      else
        @name.humanize
      end

      @title = I18n.t("bhf.platforms.#{@name}.title", :platform_title => human_title, :default => human_title).pluralize
      @page_name = page_name
      @collection = get_collection
      @columns = get_columns
    end

    def data_source
      read_table_options(:source) || :all
    end

    def search?
      read_table_options(:search) != false
    end

    def search
      read_table_options(:search) || :where
    end

    def do_search(chain, search_term)
      search_condition = if read_table_options(:search)
        search_term
      else
        where_statement = []
        model.columns_hash.each_pair do |name, props|
          if props.type === :string
            where_statement << "#{name} LIKE '%#{search_term}%'"
          elsif props.type === :integer
            where_statement << "#{name} = #{search_term.to_i}"
          elsif props.type === :float
            where_statement << "#{name} = #{search_term.to_f}"
          end
        end

        where_statement.join(' OR ')
      end

      chain.send search, search_condition
    end

    def prepare_objects(options)
      chain = model

      if options[:order]
        chain = chain.order("#{options[:order]} #{options[:direction]}")
      end

      if search? && options[:search].present?
        chain = do_search(chain, options[:search])
      end

      @objects = chain.send(data_source)
    end
    
    def model
      return @data['model'].constantize if @data['model']
      @name.singularize.camelize.constantize
    end
    
    def model_name
      ActiveModel::Naming.singular(model)
    end

    def get_columns
      collection_content = {}
      raw_collection = get_collection(true)
      raw_collection.each do |field|
        collection_content[field.name] = field
      end
      
      if table && table['columns']
        cols_array = table['columns']
      else
        cols_array = []
        
        cols_array << model.primary_key if collection_content[model.primary_key]
        
        raw_collection.each_with_index do |field, index|
          unless [model.primary_key, 'updated_at', 'created_at'].include?(field.name) or index > 4
            cols_array << field.name
          end
        end
        
        cols_array << 'updated_at' if collection_content['updated_at']
        cols_array << 'created_at' if collection_content['created_at']
      end

      new_obj = model.new
      cols_array.each_with_object([]) do |field_name, obj|
        unless new_obj.respond_to?(field_name)
          raise Exception.new("Model '#{model}' does not respond to '#{field_name}'")
        end
        obj << Column.new(field_name, collection_content[field_name])
      end
    end

    def get_collection(raw = false)
      all = {}

      model.columns_hash.each_pair do |name, props|
        all[name] = Bhf::Form::Field.new(props, {
          :overwrite_type => read_form_options(:types, name),
          :info => I18n.t("bhf.platforms.#{@name}.infos.#{name}", :default => '')
        }, model.primary_key)
      end

      model.reflections.each_pair do |name, props|
        all[name.to_s] = Bhf::Form::Reflection.new(props, {
          :overwrite_type => read_form_options('types', name),
          :info => I18n.t("bhf.platforms.#{@name}.infos.#{name}", :default => ''),
          :link => read_form_options(:links, name)
        })

        fk = all[name.to_s].reflection.association_foreign_key
        if all.has_key?(fk)
          all.delete(fk)
        end
      end

      if !raw && form && form['display']
        new_obj = model.new
        return form['display'].each_with_object([]) do |attribute, obj|
          unless new_obj.respond_to?(attribute)
            raise Exception.new("Model '#{model}' does not respond to '#{attribute}'")
          end
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
    
    def has_file_upload?
      @collection.each do |field|
        return true if field.form_type === :file
      end
      return false
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
    
      def read_form_options(key, attribute)
        if form && form[key.to_s]
          return form[key.to_s][attribute.to_s]
        end
      end
  
      def read_table_options(key)
        if table
          return table[key.to_s]
        end
      end

    class Column
    
      attr_reader :name, :field
    
      def initialize(name, field)
        @name = name
        @field = field
      end
    
    end

  end
end