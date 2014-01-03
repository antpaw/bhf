module Bhf

  class Settings

    def initialize(options)
      @options = options
      
      t = pages.each_with_object([]) do |page, obj|
        content_for_page(page).each do |platform|
          obj << platform.keys.flatten
        end
      end.flatten!
      if t.nil?
        raise Exception.new("No Bhf Pages found")
      end
      if t.uniq.length != t.length
        raise Exception.new("Platforms with identical names: '#{t.detect{ |e| t.count(e) > 1 }}'")
      end
    end

    def pages
      return @pages if @pages
      @pages = @options['pages'].each_with_object([]) do |page, obj|
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