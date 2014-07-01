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

    def get_objects(options = {}, paginate_options = nil)
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

    def remove_excludes(attrs, excludes)
      return attrs unless excludes
      attrs.each_with_object([]) do |attribute, obj|
        next if excludes.include?(attribute.name.to_s)
        obj << attribute
      end
    end

    def fields
      @fields ||= remove_excludes(default_attrs(form_value(:display), attributes), form_value(:exclude))
    end

    def columns
      return @columns if @columns
      
      tmp = default_attrs(table_columns, attributes[0..5], true)
      @columns = remove_excludes(tmp, table_value(:exclude))
    end

    def definitions
      return @definitions if @definitions
      
      tmp = default_attrs(show_value(:display) || show_value(:definitions), attributes)
      @definitions = remove_excludes(tmp, show_value(:exclude))
    end

    def has_file_upload?
      return true if form_value(:multipart) == true
      
      fields.each do |field|
        return true if field.form_type == :file
      end
      false
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
      
      def find_platform_settings_for_link(link_name)
        if form_value(:links, link_name) != false
          if form_value(:links, link_name)
            @settings.find_platform_settings(form_value(:links, link_name))
          else
            @settings.find_platform_settings(link_name.to_s.pluralize) || @settings.find_platform_settings(link_name.to_s.singularize)
          end
        end
      end

      def default_attrs(attrs, d_attrs, warning = false)
        return d_attrs unless attrs

        model_respond_to?(attrs) if warning
        attrs.each_with_object([]) do |name, obj|
          obj << (
            attributes.select{ |field| name == field.name }[0] ||
            Bhf::Platform::Attribute::Abstract.new(default_attribute_options(name).merge({
              name: name,
              link: find_platform_settings_for_link(name)
            }))
          )
        end
      end

      def attributes
        return @attributes if @attributes
        
        all = {}

        model.columns_hash.each_pair do |name, props|
          next if sortable && name == sortable_property
          all[name] = Bhf::Platform::Attribute::Column.new(props, default_attribute_options(name).merge({
            primary_key: model.bhf_primary_key
          }))
        end

        model.reflections.each_pair do |name, props|
          fk = props.foreign_key
          all[name.to_s] = Bhf::Platform::Attribute::Reflection.new(props, default_attribute_options(name).merge({
            link: find_platform_settings_for_link(name),
            reorderble: model.bhf_attribute_method?(fk)
          }))

          if all.has_key?(fk) and fk != name.to_s
            all.delete(fk)
          end
        end

        @attributes = default_sort(all)
      end

      def default_sort(attrs)
        id = []
        headlines = []
        static_dates = []
        output = []

        attrs.each_pair do |key, value|
          if key == model.bhf_primary_key
            id << value
          elsif key == 'title' || key == 'name' || key == 'headline'
            headlines << value
          elsif key == 'created_at' || key == 'updated_at'
            static_dates << value
          else
            output << value
          end
        end

        id + headlines + output.sort_by(&:name) + static_dates
      end

      def model_respond_to?(attrs)
        new_obj = model.new
        attrs.each do |attribute|
          unless new_obj.respond_to?(attribute)
            raise Exception.new("Model '#{model}' does not respond to '#{attribute}'")
            return false
          end
        end
        true
      end

      def default_attribute_options(name)
        {
          title: model.human_attribute_name(name),
          form_type: form_value(:types, name),
          display_type: table_value(:types, name),
          show_type: show_value(:types, name),
          info: I18n.t("bhf.platforms.#{@name}.infos.#{name}", default: '')
        }
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