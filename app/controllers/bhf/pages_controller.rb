class Bhf::PagesController < Bhf::BhfController
  before_filter :set_page

  def show
    settings = @config.content_for_page(@page)
    
    @platforms = settings.each_with_object([]) do |cfg, obj|
      obj << Bhf::Lists::Platform.new(cfg, @page)
    end
    
  end

  def set_page
    @page = params[:page]
  end

end