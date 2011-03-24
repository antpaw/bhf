class Bhf::PagesController < Bhf::ApplicationController
  before_filter :set_page, :store_location

  def show
    unless platform_options = @config.content_for_page(@page)
      raise Exception.new("Page '#{@page}' could not be found")
    end

    # TODO: page offset form bhf.yml - platform.entries_per_page
    @pagination = Bhf::Pagination.new(10)
    
    if request.xhr?
      params.each do |key, value|
        return render_platform(key) if value.is_a?(Hash)
      end
    end

    @platforms = platform_options.each_with_object([]) do |opts, obj|
      platform = Bhf::Platform.new(opts, @page, current_account)
      platform.paginated_objects = paginate_platform_objects(platform)
      obj << platform
    end
  end

  private

    def set_page
      @page = params[:page]
    end

    def render_platform(platform_name)
      @platform = @config.find_platform(platform_name)

      @platform.paginated_objects = paginate_platform_objects(@platform)

      render '_platform', :layout => false
    end

    def check_params(platform)
      page = 1
      if params[platform.name] && !params[platform.name][:page].blank?
        page = params[platform.name][:page].to_i
      end
      
      per_page = @pagination.offset_per_page
      if params[platform.name] && !params[platform.name][:per_page].blank?
        per_page = params[platform.name][:per_page].to_i
      end

      return :page => page, :per_page => per_page
    end

    def paginate_platform_objects(platform)
      platform.prepare_objects(params[platform.name] || {}).paginate(check_params(platform))
    end

end
