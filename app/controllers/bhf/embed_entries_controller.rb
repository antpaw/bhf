class Bhf::EmbedEntriesController < Bhf::EntriesController

  def new
    @form_url = entry_embed_index_path(@platform.name, @model.get_embedded_parent(params[:entry_id]))

    render 'bhf/entries/new', ({layout: 'bhf/quick_edit'} if @quick_edit) || {}
  end

  def edit
    @form_url = entry_embed_path(@platform.name, @model.get_embedded_parent(params[:entry_id]), @object)

    render 'bhf/entries/edit', ({layout: 'bhf/quick_edit'} if @quick_edit) || {}
  end

  def create
    before_save
    if @object.save
      manage_many_to_many
      after_save

      edit_path = edit_entry_embed_path(@platform.name, @model.get_embedded_parent(params[:entry_id]), @object)
      if @quick_edit
        render json: object_to_bhf_display_hash.merge(edit_path: edit_path), status: :ok
      else
        redirect_to(edit_path, notice: set_message('create.success', @model))
      end
    else
      @form_url = entry_embed_index_path(@platform.name, @model.get_embedded_parent(params[:entry_id]))

      r_settings = {status: :unprocessable_entity}
      r_settings[:layout] = 'bhf/quick_edit' if @quick_edit
      render 'bhf/entries/new', r_settings
    end
  end

  def update
    before_save
    if @object.update_attributes(@permited_params)
      manage_many_to_many
      after_save

      if @quick_edit
        render json: object_to_bhf_display_hash, status: :ok
      else
        redirect_to(edit_entry_embed_path(@platform.name, @model.get_embedded_parent(params[:entry_id]), @object), notice: set_message('update.success', @model))
      end
    else
      @form_url = entry_embed_path(@platform.name, @model.get_embedded_parent(params[:entry_id]), @object)

      r_settings = {status: :unprocessable_entity}
      r_settings[:layout] = 'bhf/quick_edit' if @quick_edit
      render 'bhf/entries/edit', r_settings
    end
  end

  private

    def load_object
      @object = @model.bhf_find_embed(params[:entry_id], params[:id])
      after_load
    end

    def load_new_object
      @object = @model.bhf_new_embed(params[:entry_id], @permited_params)
      after_load
    end

end