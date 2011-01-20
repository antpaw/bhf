class Bhf::EntriesController < Bhf::BhfController
  before_filter :load_model
  before_filter :load_object, :except => [:create, :new]
  
  def show
    
  end
  
  def new
    @object = @model.new
    @form_url = new_entry_path(@object)
    split_object
  end
  
  def edit
    @form_url = entry_path(@object)
    split_object
  end
  
  def create
    @object = @model.new(params[@model_sym])
    
    if @object.save
      redirect_to(entry_path(@object), :notice => 'yay')
    else
      render :action => 'new'
    end
  end

  def update
    if params[:belongs_to]
      params[:belongs_to].each_pair do |relation, id|
        params[@model_sym][relation] = id
      end
    end
    
    if @object.update_attributes(params[@model_sym])
      if params[:has_and_belongs_to_many]
        params[:has_and_belongs_to_many].each_pair do |relation, ids|
          @object.send(relation).delete_all
          relation.singularize.camelize.constantize.find(ids.values).each do |relation_obj|
            @object.send(relation) << relation_obj
          end
        end
      end
      
      redirect_to(entry_path(@object), :notice => 'yaea')
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @object.destroy
    redirect_to(bhf_root)
  end

private
  def load_model
    @model = params[:source].camelize.constantize
    @model_sym = @model.to_s.singularize.underscore.to_sym
  end
  
  def load_object
    @object = @model.find(params[:id])
  end
  
  def split_object
    @collection = {}
    @model.columns_hash.each_pair do |name, props|
      #@collection[name.to_sym] = 
    end
    #@model.reflections.each_pair do |name, props|
  end
  
end

