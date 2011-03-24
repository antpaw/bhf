module Bhf

  class Settings

    def initialize(options)
      @options = options
    end

    def pages
      @options['pages'].each_with_object([]) do |page, obj|
        if page.is_a?(String)
          page = {page => nil}
        end
        obj << page.keys[0]
      end
    end

    def content_for_page(selected_page)
      @options['pages'].each do |page|
        page = {page => nil} if page.is_a?(String)
        
        if selected_page == page.keys[0]
          return page.values.flatten
        end
      end
      nil
    end

    def find_platform(platform_name, current_account = nil)
      pages.each do |page|
        content_for_page(page).each do |platform|
          bhf_platform = Bhf::Platform.new(platform, page, current_account)
          return bhf_platform if bhf_platform.name == platform_name
        end
      end
    end

  end

end