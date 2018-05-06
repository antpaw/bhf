class Bhf::PagesController < Bhf::ApplicationController
  before_action :set_page

  def show
    @edit_params = {}
    unless platform_options = @settings.content_for_page(@page)
      raise Exception.new("Page '#{@page}' could not be found")
    end

    if request.xhr?
      params.each do |key, value|
        return render_platform(key) if value.is_a?(Hash)
      end
    end

    @platforms = platform_options.each_with_object([]) do |opts, obj|
      platform = find_platform(opts.keys[0])

      next if platform.table_hide?
      paginate_platform_objects(platform)
      obj << platform
    end
  end

  private

    def set_page
      @page = params[:page]
    end

    def render_platform(platform_name)
      platform = find_platform(platform_name)

      paginate_platform_objects(platform)

      render layout: false, partial: 'platform', locals: {platform: platform}
    end

    def paginate_platform_objects(platform)
      p = (params[platform.name] || {})
      page = 1
      unless p[:page].blank?
        page = p[:page].to_i
      end

      per_page = platform.pagination.offset_per_page
      unless p[:per_page].blank?
        per_page = p[:per_page].to_i
      end

      page_params = { page: page, per_page: per_page }

      @edit_params[platform.name] = page_params

      platform.get_objects(p, page_params)
    end

end
