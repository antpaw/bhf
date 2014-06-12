module Bhf::Platform
  class Base
    attr_reader :name, :objects, :page_name, :title, :title_zero, :title_singular

    def initialize(options)
      @objects = []

      @name = options.name
      @data = options.hash
      @settings = options.settings_base
      @user = @settings.user

      t_model_path = "activerecord.models.#{model.model_name.to_s.downcase}"
      model_name = I18n.t(t_model_path, count: 2, default: @name.pluralize.capitalize)
      @title = I18n.t("bhf.platforms.#{@name}.title", count: 2, default: model_name)
      model_name = I18n.t(t_model_path, count: 1, default: @name.singularize.capitalize)
      @title_singular = I18n.t("bhf.platforms.#{@name}.title", count: 1, default: model_name)
      model_name = I18n.t(t_model_path, count: 0, default: @name.singularize.capitalize)
      @title_zero = I18n.t("bhf.platforms.#{@name}.title", count: 0, default: model_name)

      @page_name = options.page_name
    end
    
    
    def pagination
      @pagination ||= Bhf::Platform::Pagination.new(entries_per_page)
    end

    def prepare_objects(options, paginate_options = nil)
      if user_scope?
        chain = @user.send(table_value(:user_scope).to_sym)
      else
        chain = model
        chain = chain.send data_source if data_source
      end

      unless options[:order].blank?
        chain = chain.reorder("#{options[:order]} #{options[:direction]}")
      end

      if search? && options[:search].present?
        chain = do_search(chain, options[:search])
      end


      if paginate_options && !sortable
        chain = chain.page(paginate_options[:page]).per(paginate_options[:per_page])
      elsif chain == model
        chain = chain.all
      end

      @objects = chain
    end

    def model
      @model ||= if @data['model']
        @data['model'].constantize 
      else
        @name.singularize.camelize.constantize
      end
    end

    def model_name
      ActiveModel::Naming.singular(model)
    end
    
    def table_hide?
      table_value(:hide) == true || model.bhf_embedded?
    end

    def fields
      default_attrs(form_value(:display), collection, false)
    end

    def columns
      default_attrs(table_columns, collection[0..5]).
      each_with_object([]) do |field, obj|
        obj << Bhf::Platform::Data::Column.new(field)
      end
    end

    def definitions
      default_attrs(show_value(:display) || show_value(:definitions), collection, false).
      each_with_object([]) do |field, obj|
        obj << Bhf::Platform::Data::Show.new(field)
      end
    end

    def has_file_upload?
      return true if form_value(:multipart) == true
      
      fields.each do |field|
        return true if field.form_type.to_sym == :file
      end
      false
    end

    def to_s
      @name
    end







    def search?
      table_value(:search) != false
    end

    def search_field?
      table_value(:search_field) != false
    end

    def custom_search
      table_value(:custom_search)
    end

    def table_columns
      table_value(:display) || table_value(:columns)
    end

    def custom_columns?
      table_columns.is_a?(Array)
    end

    def user_scope?
      @user && table_value(:user_scope)
    end

    def table
      @data['table']
    end

    def show
      @data['show']
    end

    def form
      @data['form']
    end

    def hooks(method)
      if @data['hooks'] && @data['hooks'][method.to_s]
        @data['hooks'][method.to_s].to_sym
      end
    end

    def sortable
      table_value 'sortable'
    end

    def sortable_property
      (@data['sortable_property'] || :position).to_sym
    end

    def columns_count
      columns.count + (sortable ? 2 : 1)
    end

    def hide_edit
      table_value 'hide_edit'
    end

    def hide_create
      table_value('hide_create') || table_value('hide_new') || table_value('hide_add')
    end

    def show_duplicate
      table_value 'show_duplicate'
    end

    def hide_delete
      table_value('hide_delete') || table_value('hide_destroy')
    end

    def custom_link
      table_value 'custom_link'
    end

    def custom_partial
      table_value 'partial'
    end

    def data_source
      table_value(:source) || table_value(:scope)
    end

    def show_extra_fields
      show_value(:extra_fields)
    end

    def entries_per_page
      table_value(:per_page)
    end




    private

      def do_search(chain, search_params)
        if table_value(:search)
          chain.send table_value(:search), search_params
        else
          chain.bhf_default_search(search_params)
        end
      end

      def default_attrs(attrs, d_attrs, warning = true)
        return d_attrs unless attrs

        model_respond_to?(attrs) if warning
        attrs.each_with_object([]) do |attr_name, obj|
          obj << (
            collection.select{ |field| attr_name == field.name }[0] ||
            Bhf::Platform::Data::AbstractField.new({
              name: attr_name,
              form_type: form_value(:types, attr_name) || attr_name,
              display_type: table_value(:types, attr_name) || attr_name,
              show_type: show_value(:types, attr_name) || table_value(:types, attr_name) || attr_name,
              info: I18n.t("bhf.platforms.#{@name}.infos.#{attr_name}", default: ''),
              link: (@settings.find_platform_settings(form_value(:links, attr_name)) if form_value(:links, attr_name))
            })
          )
        end
      end

      def collection
        return @collection if @collection
        
        all = {}

        model.columns_hash.each_pair do |name, props|
          next if name == sortable
          all[name] = Bhf::Platform::Data::Field.new(props, {
            overwrite_type: form_value(:types, name),
            overwrite_display_type: table_value(:types, name),
            overwrite_show_type: show_value(:types, name) || table_value(:types, name),
            info: I18n.t("bhf.platforms.#{@name}.infos.#{name}", default: '')
          }, model.bhf_primary_key)
        end

        model.reflections.each_pair do |name, props|
          all[name.to_s] = Bhf::Platform::Data::Reflection.new(props, {
            overwrite_type: form_value(:types, name),
            overwrite_display_type: table_value(:types, name),
            overwrite_show_type: show_value(:types, name) || table_value(:types, name),
            info: I18n.t("bhf.platforms.#{@name}.infos.#{name}", default: ''),
            link: (@settings.find_platform_settings(form_value(:links, name)) if form_value(:links, name))
          })

          fk = all[name.to_s].reflection.foreign_key
          if all.has_key?(fk) and fk != name.to_s
            all.delete(fk)
          end
        end

        @collection = default_sort(all)
      end

      def default_sort(attrs)
        id = []
        static_dates = []
        output = []

        attrs.each_pair do |key, value|
          if key == model.bhf_primary_key
            id << value
          elsif key == 'created_at' || key == 'updated_at'
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



      def form_value(key, attribute = nil)
        lookup_value form, key, attribute
      end

      def table_value(key, attribute = nil)
        lookup_value table, key, attribute
      end

      def show_value(key, attribute = nil)
        lookup_value show, key, attribute
      end

      def lookup_value(main_key, key, attribute = nil)
        if main_key
          if attribute == nil
            main_key[key.to_s]
          elsif main_key[key.to_s]
            main_key[key.to_s][attribute.to_s]
          end
        end
      end

  end
end