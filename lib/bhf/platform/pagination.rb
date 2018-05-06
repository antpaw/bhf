Kaminari::Helpers::Tag.class_eval do
  def page_url_for(page)
    if @param_name.is_a?(Array)
      @params[@param_name[0]] = (@params[@param_name[0]] || {}).merge(@param_name[1] => (page <= 1 ? 1 : page))
      return @template.url_for @params
    end

    @template.url_for @params.merge(@param_name => (page <= 1 ? 1 : page))
  end
end
# TODO: monitor https://github.com/amatsuda/kaminari/issues/542#issuecomment-40294388

module Bhf::Platform

  class Pagination

    attr_accessor :template
    attr_reader :offset_per_page, :offset_to_add

    def initialize(offset_per_page = 10, offset_to_add = 5)
      @offset_per_page = offset_per_page || 10
      @offset_to_add = offset_to_add
    end

    def create(platform)
      platform_params = template.params[platform.name] || {}

      links = if !(page_links = template.paginate(platform.objects, {
        theme: 'bhf',
        param_name: [platform.name, :page],
        params: template.params.permit!
      })).blank?
        "#{load_more(platform)} #{page_links}"
      elsif platform.objects.total_pages == 1 && platform.objects.size > @offset_to_add
        load_less(platform)
      end

      if links
        template.content_tag(:div, links.html_safe, {class: 'pagination'})
      end
    end

    def info(platform, options = {})
      collection = platform.objects

      if collection.respond_to?(:num_pages) and collection.num_pages > 1
        I18n.t('bhf.pagination.info.default', {
          name: platform.title,
          count: collection.total_count,
          offset_start: collection.offset_value + 1,
          offset_end: collection.offset_value + collection.limit_value
        })
      else
        I18n.t('bhf.pagination.info', {
          name_zero: platform.title,
          name_singular: platform.title_singular,
          name_plural: platform.title,
          count: collection.size
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

      parsed_paramas = {
        bhf_area: template.params[:bhf_area],
        page: template.params[:page]
      }.merge(platform.name.to_sym => platform_params)
      template.link_to(
        I18n.t("bhf.pagination.load_#{direction}"),
        template.page_path(platform.page_name, parsed_paramas),
        attributes.merge(class: "load_#{direction}")
      )
    end

    def load_less(platform, attributes = {})
      load_more(platform, attributes, false)
    end

  end
end
