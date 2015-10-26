class Bhf::EntriesController < Bhf::ApplicationController
  before_filter :load_platform, :load_model, :set_page, :set_quick_edit
  before_filter :crop_readonly, only: [:update]
  before_filter :params_permit_default, except: [:update, :create]
  before_filter :params_permit, only: [:update, :create]
  before_filter :load_object, except: [:create, :new, :sort]
  before_filter :load_new_object, only: [:create, :new]

  def new
    @form_url = entries_path(@platform.name)
    
    render layout: 'bhf/quick_edit' if @quick_edit
  end

  def edit
    render file: 'public/404.html', layout: false and return unless @object
    
    @form_url = entry_path(@platform.name, @object)
    
    render layout: 'bhf/quick_edit' if @quick_edit
  end
  
  def show
    render file: 'public/404.html', layout: false and return unless @object
    
    respond_to do |format|
      format.html
      format.json  { render json: @object }
    end
  end

  def create
    before_save
    if @object.save
      manage_many_to_many
      after_save

      if @quick_edit
        render json: object_to_bhf_hash, status: :ok
      else
        redirect_after_save(notice: set_message('create.success', @model), referral_entry: {id: @object.id, platform: @platform.name})
      end
    else
      @form_url = entries_path(@platform.name)

      r_settings = {status: :unprocessable_entity}
      if @quick_edit
        r_settings[:layout] = 'bhf/quick_edit'
        r_settings[:formats] = [:html]
      end
      render :new, r_settings
    end
  end

  def update
    render file: 'public/404.html', layout: false and return unless @object
    
    before_save
    if @object.update_attributes(@permited_params)
      manage_many_to_many
      after_save

      if @quick_edit
        render json: object_to_bhf_hash, status: :ok
      else
        redirect_after_save(notice: set_message('update.success', @model), referral_entry: {id: @object.id, platform: @platform.name})
      end
    else
      @form_url = entry_path(@platform.name, @object)

      r_settings = {status: :unprocessable_entity}
      if @quick_edit
        r_settings[:layout] = 'bhf/quick_edit'
        r_settings[:formats] = [:html]
      end
      render :edit, r_settings
    end
  end
  
  def duplicate
    new_record = @object.dup
    new_record.before_bhf_duplicate(@object) if new_record.respond_to?(:before_bhf_duplicate)
    if new_record.save
      new_record.after_bhf_duplicate(@object) if new_record.respond_to?(:after_bhf_duplicate)
      redirect_to(page_url(@platform.page_name, anchor: "#{@platform.name}_platform"), notice: set_message('duplicate.success', @model), flash: {referral_entry: {id: new_record.id, platform: @platform.name}})
    else
      redirect_to(page_url(@platform.page_name, anchor: "#{@platform.name}_platform"), notice: set_message('duplicate.error', @model))
    end
  end
  
  def sort
    params[:order].each do |order|
      @model.
        find(order[1].gsub("_#{@platform.name}", '')).
        update_attribute(@platform.sortable_property, order[0].to_i)
    end
    
    head :ok
  end

  def destroy
    object = @object.destroy
    if @quick_edit
      respond_to do |f|
        f.json { render status: :ok, json: object }
      end
    else
      redirect_back_or_default(page_url(@platform.page_name, anchor: "#{@platform.name}_platform"), notice: set_message('destory.success', @model))
    end
  end

  private

    def object_to_bhf_hash
      extra_data = {
        to_bhf_s:  @object.to_bhf_s, 
        object_id: @object.send(@object.class.bhf_primary_key).to_s
      }
      extra_data.merge!(@object.to_bhf_hash) if @object.respond_to?(:to_bhf_hash)
      
      @platform.columns.each_with_object(extra_data) do |column, hash|
        next if column.is_a?(Bhf::Platform::Attribute::Abstract)
        column_value = @object.send(column.name)
        unless column.macro == :column && column_value.blank?
          p = "bhf/table/#{column.macro}/#{column.display_type}"
          hash[column.name] = render_to_string partial: p, formats: [:html],
            locals: { object: @object, column_value: column_value, link: false,
              add_quick_link: false, column_name: column.name }
        end
      end
    end

    def load_platform
      @platform = find_platform(params[:platform])
    end

    def load_model
      @model = @platform.model
    end

    def params_permit_default
      parms = params[@platform.model_name.to_sym]
      @permited_params = ActionController::Parameters.new(parms).permit!
    end

    def params_permit
      skip_blank = @settings.find_platform_settings(params['platform']).
        hash['form']['skip_blank']
      parms =
      if skip_blank
        params[@platform.model_name.to_sym].select do |key, value|
          !skip_blank.include?(key) || !value.blank?
        end
      else
        params[@platform.model_name.to_sym]
      end.map do |param, value|
        if /(?<model_name>.*)_ids?$/ =~ param && value.is_a?(Array)
          value.delete_if { |id| id !~ /^\d+$/ }
          if !@model.instance_methods.include?("#{param}=".to_sym)
            next [ model_name,
                   model_name.camelize.constantize.find_by_id(value.pop) ]
          end
        end
        [ param, value ]
      end.to_h
      @permited_params = ActionController::Parameters.new(parms).permit!
    end

    def crop_readonly
      ro = @settings.find_platform_settings(params['platform']).
        hash['form']['readonly']
      if ro
        params[@platform.model_name.to_sym].delete_if { |key| ro.include?(key) }
      end
    end

    def load_object
      @object = @model.unscoped.find(params[:id]) rescue nil
      @object.assign_attributes(@permited_params) if @object and @permited_params
      after_load
    end

    def load_new_object
      @object = @model.new(@permited_params)
      after_load
    end

    def manage_many_to_many
      return unless params[:has_and_belongs_to_many]
      params[:has_and_belongs_to_many].each_pair do |relation, ids|
        reflection = @model.reflections[relation]

        next unless ids.any?
        relation_array = @object.send(relation)
        reflection.klass.unscoped.find(ids.keys).each do |relation_obj|
          has_relation = relation_array.include?(relation_obj)
          
          if ids[relation_obj.send(relation_obj.class.bhf_primary_key).to_s].blank?
            if has_relation
              relation_array.delete(relation_obj)
            end
          else
            if ! has_relation
              relation_array << relation_obj
            end
          end
        end
      end
    end

    def after_load
      @object.send(@platform.hooks(:after_load)) if @platform.hooks(:after_load)
    end

    def before_save
      @object.send(@platform.hooks(:before_save), params) if @platform.hooks(:before_save)
    end

    def after_save
      @object.send(@platform.hooks(:after_save), params) if @platform.hooks(:after_save)
    end

    def set_page
      @page = @platform.page_name
    end

    def set_quick_edit
      @quick_edit = request.xhr?
    end
    
    def redirect_after_save(flash)
      if params[:return_to_edit]
        redirect_to edit_entry_path(@platform.name, @object), flash
      elsif params[:return_to_new]
        redirect_to new_entry_path(@platform.name), flash
      else
        redirect_back_or_default(page_url(@platform.page_name, anchor: "#{@platform.name}_platform"), flash)
      end
    end
end
