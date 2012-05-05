class Bhf::EntriesController < Bhf::ApplicationController
  before_filter :load_platform, :load_model, :set_page, :set_quick_edit
  before_filter :load_object, except: [:create, :new, :sort]
  before_filter :load_new_object, only: [:create, :new]

  def new
    @form_url = bhf_entries_path(@platform.name)
  end

  def edit
    @form_url = bhf_entry_path(@platform.name, @object)

    render layout: 'bhf/quick_edit' if @quick_edit
  end

  def create
    before_save
    if @object.save
      manage_many_to_many
      after_save

      redirect_back_or_default(bhf_entries_path(@platform.name), notice: set_message('create.success', @model))
    else
      @form_url = bhf_entries_path(@platform.name)
      render :new
    end
  end

  def update
    before_save
    if @object.update_attributes(params[@model_sym])
      manage_many_to_many
      after_save

      if @quick_edit
        render json: object_to_bhf_display_hash, status: :ok
      else
        redirect_back_or_default(bhf_entries_path(@platform.name), notice: set_message('update.success', @model))
      end
    else
      @form_url = bhf_entry_path(@platform.name, @object)

      r_settings = {status: :unprocessable_entity}
      r_settings[:layout] = 'bhf/quick_edit' if @quick_edit
      render :edit, r_settings
    end
  end

  def sort
    return unless @platform.sortable
    
    sort_attr = @platform.sortable.to_sym

    params[:order].each do |order|
      @model.
        find(order[1].gsub("_#{@platform.name}", '')).
        update_attribute(sort_attr, order[0].to_i)
    end
    
    head :ok
  end

  def destroy
    @object.destroy
    if @quick_edit
      head :ok
    else
      redirect_back_or_default(bhf_page_url(@platform.page_name, anchor: "#{@platform.name}_platform"), notice: set_message('destory.success', @model))
    end
  end

  private

    def object_to_bhf_display_hash
      @platform.columns.each_with_object({to_bhf_s: @object.to_bhf_s}) do |column, hash|
        unless column.field.macro == :column && @object.send(column.name).blank?
          p = "bhf/pages/macro/#{column.field.macro}/#{column.field.display_type}.html"
          hash[column.name] = render_to_string partial: p, locals: {column: column, object: @object}
        end
      end
    end

    def load_platform
      @platform = @config.find_platform(params[:platform], current_account)
    end

    def load_model
      @model = @platform.model
      @model_sym = ActiveModel::Naming.singular(@model).to_sym
    end

    def load_object
      @object = @model.find(params[:id])
      after_load
    end

    def load_new_object
      @object = @model.new(params[@model_sym])
      after_load
    end

    def manage_many_to_many
      return unless params[:has_and_belongs_to_many]
      params[:has_and_belongs_to_many].each_pair do |relation, ids|
        reflection = @model.reflections[relation.to_sym]

        @object.send(reflection.name).delete_all # TODO: drop only the diff

        ids = ids.values.reject(&:blank?)

        return if ids.blank?

        reflection.klass.find(ids).each do |relation_obj|
          @object.send(relation) << relation_obj
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
    
end
