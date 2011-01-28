class Bhf::EntriesController < Bhf::BhfController
  before_filter :load_platform, :load_model
  before_filter :load_object, :except => [:create, :new]
  
  def show
    
  end
  
  def new
    @object = @model.new
    @form_url = entries_path(@platform.name, @model)
    split_object
  end
  
  def edit
    @form_url = entry_path(@platform.name, @object)
    split_object
  end
  
  def create
    @object = @model.new(params[@model_sym])
    
    if @object.save
      manage_many_to_many
      
      redirect_to(entry_path(@platform.name, @object), :notice => 'yay')
    else
      @form_url = entries_path(@platform.name, @model)
      split_object
      render :new
    end
  end

  def update
    if @object.update_attributes(params[@model_sym])
      manage_many_to_many

      redirect_to(entry_path(@platform.name, @object), :notice => 'yaea')
    else
      @form_url = entry_path(@platform.name, @object)
      split_object
      render :edit
    end
  end
  
  def destroy
    @object.destroy
    redirect_to(bhf_root)
  end

private
  def load_platform
    @platform = @config.find_platform(params[:platform])
  end
  
  def load_model
    @model = @platform.model
    @model_sym = ActiveModel::Naming.singular(@model).to_sym
  end
  
  def load_object
    @object = @model.find(params[:id])
  end
  
  def split_object
    @collection = @platform.collection
  end
  
  def manage_many_to_many
    return unless params[:has_and_belongs_to_many]
    params[:has_and_belongs_to_many].each_pair do |relation, ids|
      reflection = @model.reflections[relation.to_sym]
      
      @object.send(reflection.name).delete_all
      
      ids = ids.values.reject(&:blank?)
      
      return if ids.blank?
      
      reflection.klass.find(ids).each do |relation_obj|
        @object.send(relation) << relation_obj
      end
    end
  end
  
end
