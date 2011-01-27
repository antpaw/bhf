module Bhf
  module Settings
    
    class Pages
      
      def initialize(cfg)
        @cfg = cfg
      end
      
      def pages
        @cfg['pages'].each_with_object([]) do |page, obj|
          obj << page.keys[0]
        end
      end
      
      def content_for_page(selected_page)
        @cfg['pages'].each do |page|
          if selected_page == page.keys[0]
            return page.values.flatten
          end
        end
      end

      def find_platform(platform_name)
        pages.each do |page|
          content_for_page(page).each do |platform|
            bhf_platform = Bhf::Lists::Platform.new(platform)
            return bhf_platform if bhf_platform.name == platform_name
          end
        end
      end

    end
    
  end
end