class Bhf::BhfController < ActionController::Base
  
  protect_from_forgery
  
  before_filter :check_admin_account, :load_config

  helper_method :entry_path, :new_entry_path, :entries_path, :edit_entry_path
  layout 'bhf'

  def index
    
  end


private

  def check_admin_account
    auth_logic = Bhf::Engine.config.auth_logic_from.constantize.new
    
    if auth_logic.respond_to?(:current_admin_account) && auth_logic.current_admin_account
      return true
    else
      redirect_to(root_url) and return false
    end
  end

  def load_config
    @config = Bhf::Settings::Pages.new(
      YAML::load(IO.read('config/bhf.yml'))
    )
  end


  def new_entry_path(platform, extra_params = {})
    new_bhf_entry_path platform, extra_params
  end

  def entries_path(platform, extra_params = {})
    bhf_entries_path platform, extra_params
  end

  def entry_path(platform, object, extra_params = {})
    bhf_entry_path platform, object, extra_params
  end

  def edit_entry_path(platform, object, extra_params = {})
    edit_bhf_entry_path platform, object, extra_params
  end

end

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
          collection_content[field.name] = field
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
        
        id = []
        static_dates = []
        
        output = []
        all.each_pair do |key, value|
          if key === 'id'
            id << value
          elsif key === 'created_at' || key === 'updated_at'
            static_dates << value
          else
            output << value
          end
        end
        
        id + output.sort_by(&:name) + static_dates
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

module Bhf
  module Form
    
    class Builder < ActionView::Helpers::FormBuilder
      include ActionView::Helpers::FormTagHelper
      
      def error_label(name, message)
        label name, "#{name.to_s.humanize} #{message}"
      end
      
      def many_to_many_check_box(obj, ref_name, params)
        mm = :has_and_belongs_to_many
        checked = if params[mm] && params[mm][ref_name]
          params[mm][ref_name][obj.id.to_s] != ''
        else
          object.send(ref_name).include?(obj)
        end
        
        hidden_field_tag("#{mm}[#{ref_name}][#{obj.id}]", '', :id => "hidden_has_and_belongs_to_many_#{ref_name}_#{obj.id}")+' '+
        check_box_tag("#{mm}[#{ref_name}][#{obj.id}]", obj.id, checked)+' '+
        label_tag("#{mm}_#{ref_name}_#{obj.id}", obj.to_bhf_s)
      end
      
    end
    
    class Field
      
      def initialize(props, overwrite_type = nil)
        @props = props
        @overwrite_type = overwrite_type
      end
      
      def macro
        :column
      end
      
      def real_type
        @props.type
      end
      
      def type(real_type = false)
        return @overwrite_type if @overwrite_type
        
        if !real_type && (name === 'id' || name === 'updated_at' || name === 'created_at')
          'static'
        elsif [:boolean, :text].include?(@props.type)
          @props.type
        elsif type_sym = group_types(@props.type)
          type_sym
        else
          'string'
        end
      end
      
      def name
        @props.name
      end
      
      private
      
      def group_types(type_sym)
        return :date if [:date, :datetime, :timestamp, :time, :year].include?(type_sym)
        return :number if [:integer, :float].include?(type_sym)
      end
      
    end
    
    class Reflection
      
      attr_accessor :reflection
      
      def initialize(reflection, overwrite_type = nil)
        @reflection = reflection
        @overwrite_type = overwrite_type
      end
      
      def macro
        @reflection.macro
      end
      
      def type
        return @overwrite_type if @overwrite_type
        
        if macro === :has_and_belongs_to_many
          'check_box'
        elsif macro === :belongs_to
          'select'
        else
          'static'
        end
      end
      
      def name
        @reflection.name.to_s
      end
      
    end
    
  end  
end

::ActiveRecord::Base.send :include, Bhf::ActiveRecord
::ActiveRecord::Base.send :extend, Bhf::ActiveRecord