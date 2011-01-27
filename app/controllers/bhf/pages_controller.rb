class Bhf::PagesController < Bhf::BhfController

  def show
    settings = @config.content_for_page(params[:page])
    
    @platforms = settings.each_with_object([]) do |cfg, obj|
      obj << Bhf::Lists::Platform.new(cfg)
    end
    
  end

end