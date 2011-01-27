class Bhf::BhfController < ActionController::Base

  before_filter :load_config

  helper_method :entry_path, :edit_entry_path, :new_entry_path
  layout 'bhf'

  def index
    
  end


private

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

::ActiveRecord::Base.send :include, Bhf::ActiveRecord
::ActiveRecord::Base.send :extend, Bhf::ActiveRecord