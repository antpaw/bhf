class Bhf::BhfController < ActionController::Base

  helper_method :entry_path, :edit_entry_path, :new_entry_path, :d
  layout 'bhf'
  
  def index
    
  end
  
  
private
  def d(var)
    raise var.inspect.split(', ').join(", \n")
  end
  
  def new_entry_path(object)
    bhf_entries_path object.class.to_s.singularize.underscore
  end

  def entry_path(object)
    bhf_entry_path object.class.to_s.singularize.underscore, object
  end

  def edit_entry_path(object)
    edit_bhf_entry_path object.class.to_s.singularize.underscore, object
  end
   
end