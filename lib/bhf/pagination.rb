module Bhf

  class Pagination

    attr_accessor :template
    attr_reader :offset_per_page, :offset_to_add

    def initialize(offset_per_page = 10, offset_to_add = 5)
      @offset_per_page = offset_per_page
      @offset_to_add = offset_to_add
    end

    def paginate(platform)
      platform_params = template.params[platform.name] || {}

      if page_links = template.will_paginate(platform.paginated_objects, {
        :previous_label => I18n.t('bhf.pagination.previous_label'),
        :next_label => I18n.t('bhf.pagination.next_label'),
        :renderer => LinkRenderer.new(self, platform),
        :container => false
      })
        links = "#{load_more(platform)} #{page_links}"
      elsif platform.paginated_objects.total_pages == 1 && platform.paginated_objects.size > @offset_to_add
        links = load_less(platform)
      end

      if links
        template.content_tag(:div, links.html_safe, {:class => 'pagination'})
      end
    end

    def info(platform, options = {})
      collection = platform.paginated_objects
      
      entry_name = options[:entry_name] ||
        (collection.empty?? 'entry' : collection.first.class.model_name.human)
  
      info = if collection.total_pages < 2
        case collection.size
          when 0
            I18n.t 'bhf.pagination.info.nothing_found', :name => entry_name.pluralize
          when 1
            I18n.t 'bhf.pagination.info.one_found', :name => entry_name
          else
            I18n.t 'bhf.pagination.info.all_displayed', :total_count => collection.size, :name => entry_name.pluralize
        end
      else
        I18n.t('bhf.pagination.info.default', {
          :name => entry_name.pluralize,
          :total_count => collection.total_entries,
          :offset_start => collection.offset + 1,
          :offset_end => collection.offset + collection.length
        })
      end
    
      info.html_safe
    end

    def load_more(platform, attributes = {}, plus = true)
      platform_params = template.params[platform.name] || {}
      load_offset = @offset_per_page
      load_offset = platform_params[:per_page].to_i if platform_params[:per_page]
      if plus
        load_offset += @offset_to_add
      else
        load_offset -= @offset_to_add
      end

      platform_params.delete(:page)
      platform_params[:per_page] = load_offset
      
      direction = (plus ? 'more' : 'less')
      template.link_to(
        I18n.t("bhf.pagination.load_#{direction}"),
        template.bhf_page_path(
          platform.page_name,
          template.params.merge(platform.name => platform_params)
        ), attributes.merge(:class => "load_#{direction}")
      )
    end
    
    def load_less(platform, attributes = {})
      load_more(platform, attributes, false)
    end


    class LinkRenderer < WillPaginate::LinkRenderer
      
      def initialize(bhf_pagination, platform)
        @b_p = bhf_pagination
        @platform = platform
      end

      def page_link(page, text, attributes = {})
        platform_params = @b_p.template.params[@platform.name] || {}
        platform_params[:page] = page
        
        @b_p.template.link_to(
          text, 
          @b_p.template.bhf_page_path(
            @platform.page_name,
            @b_p.template.params.merge(@platform.name => platform_params)
          ), attributes
        )
      end

    end

  end

end