module Bhf
  module PagesHelper
    
    def get_value(key, p)
      return unless p.is_a?(Hash)

      return p[key[0]][key[1]] if key.is_a?(Array) && p[key[0]].is_a?(Hash) && p[key[0]][key[1]].is_a?(String) #omg
      
      p[key] if p[key] && p[key].is_a?(String)
    end

    def current_order_path(order_by, platform_name)
      params_platfrom = params[platform_name] ? params[platform_name].clone : {}

      if params_platfrom['order'] == order_by && params_platfrom['direction'] != 'desc'
        params_platfrom['direction'] = 'desc'
      else
        params_platfrom['direction'] = 'asc'
      end

      params_platfrom['order'] = order_by

      url_for platform_name => params_platfrom
    end

    def order_class(order_by, platform_name)
      params_platfrom = params[platform_name] ? params[platform_name] : {}
      return unless params_platfrom['order'] == order_by
      
      params_platfrom['direction'] == 'desc' ? 'sorted desc' : 'sorted asc'
    end
    
    def has_link?(display_type)
      display_type.to_s.include? '_link'
    end

  end
end