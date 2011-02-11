class Bhf::PagesController < Bhf::BhfController
  before_filter :set_page, :store_location

  def show
    platform_options = @config.content_for_page(@page)

    @pagination = Bhf::Pagination.new(2, 3)
    
    if request.xhr?
      params.each do |key, val|
        return render_platform(key) if val.is_a?(Hash)
      end
    end

    @platforms = platform_options.each_with_object([]) do |opts, obj|
      platform = Bhf::Platform.new(opts, @page)
      platform.paginated_objects = platform_objects(platform)
      obj << platform
    end
  end

  private

    def render_platform(platform_name)
      @platform = @config.find_platform(platform_name)

      @platform.paginated_objects = platform_objects(@platform)

      render '_platform', :layout => false
    end

    def set_page
      @page = params[:page]
    end

    def check_params(platform)
      page = 1
      page = params[platform][:page].to_i if params[platform] && !params[platform][:page].blank?
      per_page = @pagination.offset_per_page
      per_page = params[platform][:per_page].to_i if params[platform] && !params[platform][:per_page].blank?

      return :page => page, :per_page => per_page
    end
    
    def platform_objects(platform)
      platform.prepare_objects(params[platform.name] || {}).paginate(check_params(platform.name))
    end

end
