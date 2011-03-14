module Bhf
  class Platform

    attr_accessor :paginated_objects
    attr_reader :name, :title, :page_name

    def initialize(options, page_name)
      @paginated_objects = []

      if options.is_a?(String)
        options = {options => nil}
      end
      @name = options.keys[0]
      @data = options.values[0] || {}
      @collection = get_collection

      human_title = if model.to_s === @name.singularize.camelize
        model.model_name.human
      else
        @name.humanize
      end

      @title = I18n.t("bhf.platforms.#{@name}.title", :platform_title => human_title, :default => human_title).pluralize
      @page_name = page_name
    end

    def search?
      table_options(:search) != false
    end

    def custom_columns?
      table_options(:columns).is_a?(Array)
    end

    def search
      table_options(:search) || :where
    end

    def prepare_objects(options)
      chain = model

      if options[:order]
        chain = chain.unscoped.order("#{options[:order]} #{options[:direction]}")
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

    def fields
      default_attrs(form_options(:display), @collection)
    end

    def columns
      default_attrs(table_options(:columns), @collection[0..5]).
      each_with_object([]) do |field, obj|
        obj << Bhf::Data::Column.new(field)
      end
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

      def do_search(chain, search_term)
        search_condition = if table_options(:search)
          search_term
        else
          where_statement = []
          model.columns_hash.each_pair do |name, props|
            is_number = search_term.to_i.to_s === search_term || search_term.to_f.to_s === search_term
            
            if props.type === :string || props.type === :text
              where_statement << "#{name} LIKE '%#{search_term}%'"
            elsif props.type === :integer && is_number
              where_statement << "#{name} = #{search_term.to_i}"
            elsif props.type === :float && is_number
              where_statement << "#{name} = #{search_term.to_f}"
            end
          end

          where_statement.join(' OR ')
        end

        chain.send search, search_condition
      end

      def data_source
        table_options(:source) || :all
      end

      def default_attrs(attrs, default_attrs)
        return default_attrs unless attrs
        
        model_respond_to?(attrs)
        attrs.each_with_object([]) do |attr_name, obj|
          obj << @collection.select{ |field| attr_name === field.name }[0]
        end
      end

      def get_collection
        all = {}

        model.columns_hash.each_pair do |name, props|
          all[name] = Bhf::Data::Field.new(props, {
            :overwrite_type => form_options(:types, name),
            :info => I18n.t("bhf.platforms.#{@name}.infos.#{name}", :default => '')
          }, model.primary_key)
        end

        model.reflections.each_pair do |name, props|
          all[name.to_s] = Bhf::Data::Reflection.new(props, {
            :overwrite_type => form_options(:types, name),
            :info => I18n.t("bhf.platforms.#{@name}.infos.#{name}", :default => ''),
            :link => form_options(:links, name)
          })

          fk = all[name.to_s].reflection.primary_key_name
          if all.has_key?(fk)
            all.delete(fk)
          end
        end

        default_sort(all)
      end

      def default_sort(attrs)
        id = []
        static_dates = []
        output = []
      
        attrs.each_pair do |key, value|
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

      def model_respond_to?(field_names)
        new_obj = model.new
        field_names.each do |field_name|
          unless new_obj.respond_to?(field_name)
            raise Exception.new("Model '#{model}' does not respond to '#{field_name}'")
            return false
          end
        end
        true      
      end

      def form_options(key, attribute = nil)
        if form
          if attribute === nil
            form[key.to_s]
          elsif form[key.to_s]
            form[key.to_s][attribute.to_s]
          end
        end
      end

      def table_options(key)
        if table
          return table[key.to_s]
        end
      end

  end
end