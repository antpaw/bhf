module Bhf

  class Pagination

    attr_accessor :template
    attr_reader :offset_per_page, :offset_to_add

    def initialize(offset_per_page = 10, offset_to_add = 5)
      @offset_per_page = offset_per_page || 10
      @offset_to_add = offset_to_add
    end

    def create(platform)
      platform_params = template.params[platform.name] || {}

      if page_links = template.will_paginate(platform.objects, {
        :previous_label => I18n.t('bhf.pagination.previous_label'),
        :next_label => I18n.t('bhf.pagination.next_label'),
        :renderer => LinkRenderer.new(self, platform),
        :container => false
      })
        links = "#{load_more(platform)} #{page_links}"
      elsif platform.objects.total_pages == 1 && platform.objects.size + @offset_to_add > @offset_per_page
        links = load_less(platform)
      end

      if links
        template.content_tag(:div, links.html_safe, {:class => 'pagination'})
      end
    end

    def info(platform, options = {})
      collection = platform.objects
      
      unless collection.respond_to?(:total_pages)
        collection = collection.paginate({:page => 1, :per_page => collection.count+1})
      end

      if collection.total_pages > 1
        I18n.t('bhf.pagination.info.default', {
          :name => platform.title,
          :count => collection.total_entries,
          :offset_start => collection.offset + 1,
          :offset_end => collection.offset + collection.length
        })
      else
        I18n.t('bhf.pagination.info', {
          :name_zero => platform.title_zero,
          :name_singular => platform.title_singular,
          :name_plural => platform.title,
          :count => collection.size
        })
      end.html_safe
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
      
      direction = plus ? 'more' : 'less'
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


    class LinkRenderer < WillPaginate::ViewHelpers::LinkRenderer

      def initialize(bhf_pagination, platform)
        @b_p = bhf_pagination
        @platform = platform
      end

      def link(text, page, attributes = {})
        platform_params = @b_p.template.params[@platform.name] || {}
        platform_params[:page] = page
        
        @b_p.template.link_to(
          text, 
          @b_p.template.bhf_page_path(
            @platform.page_name,
            @b_p.template.params.merge(@platform.name => platform_params)
          ), {:class => 'page_number'}.merge(attributes)
        )
      end

    end
    
  end
end