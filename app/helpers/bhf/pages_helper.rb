module Bhf
  module PagesHelper
    
    def get_value(key, platform_name)
      params[platform_name][key] if params[platform_name] && params[platform_name][key]
    end

    def current_order_path(order_by, platform_name)
      params_platfrom = params[platform_name] ? params[platform_name].clone : {}

      if params_platfrom['order'] === order_by && params_platfrom['direction'] != 'desc'
        params_platfrom['direction'] = 'desc'
      else
        params_platfrom['direction'] = 'asc'
      end

      params_platfrom['order'] = order_by

      url_for platform_name => params_platfrom
    end

    def order_class(order_by, platform_name)
      params_platfrom = params[platform_name] ? params[platform_name] : {}
      return unless params_platfrom['order'] === order_by
      
      params_platfrom['direction'] === 'desc' ? 'sorted desc' : 'sorted asc'
    end

  end
end