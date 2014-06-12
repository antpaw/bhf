module Bhf::Settings

  class Base
    
    attr_accessor :user

    def initialize(settings_hash, user = nil)
      @settings_hash = settings_hash
      @user = user
      
      t = pages.each_with_object([]) do |page, obj|
        content_for_page(page).each do |platform|
          obj << platform.keys.flatten
        end
      end.flatten!
      if t.nil?
        raise Exception.new("No bhf pages found")
      end
      if t.uniq.length != t.length
        raise Exception.new("Platforms with identical names: '#{t.detect{ |e| t.count(e) > 1 }}'")
      end
    end

    def pages
      @pages ||= @settings_hash['pages'].each_with_object([]) do |page, obj|
        if page.is_a?(String)
          page = {page => nil}
        end
        obj << page.keys[0]
      end
    end

    def content_for_page(selected_page)
      @settings_hash['pages'].each do |page|
        page = {page => nil} if page.is_a?(String)
        
        if selected_page == page.keys[0]
          return page.values.flatten
        end
      end
      nil
    end

    def find_platform_settings(platform_name)
      pages.each do |page|
        content_for_page(page).each do |platform_hash|
          if platform_hash.keys[0] == platform_name.to_s
            return Bhf::Settings::Platform.new(platform_hash, page, self)
          end
        end
      end
      nil
    end

  end

end