module Bhf

  module ConfigParser
    
    class << self
      def parse(roles_array, area = nil)
        roles_config = roles_yml(roles_array, area)
  
        if Bhf::Engine.config.bhf.abstract_config.any?
    
          tmp_pages = get_config_array(Bhf::Engine.config.bhf.abstract_config, '/abstract')['pages']
          abstract_platform_config = tmp_pages.each_with_object({}) do |abstract_pages, hash|
            abstract_pages.each do |abstract_page|
              abstract_page[1].each do |abstract_platform|
                hash.merge!(abstract_platform)
              end
            end
          end
    
          roles_config['pages'].each_with_index do |pages, i_1|
            pages.each_pair do |key_1, page|
              page.each_with_index do |platform, i_2|
                platform.each_pair do |key_2, value|
                  abstract_platform_key = if value.to_h['extend_abstract']
                    value.to_h['extend_abstract']
                  elsif abstract_platform_config[key_2]
                    key_2
                  end
                  next unless abstract_platform_key
                  roles_config['pages'][i_1][key_1][i_2][key_2] = abstract_platform_config[abstract_platform_key].deep_merge(value.to_h)
                end
              end
            end
          end
        end
  
        return Bhf::Settings.new(roles_config)
      end


      def get_config_array(array, dir)
        array.each_with_object({'pages' => []}) do |r, account_roles|
          pages = load_yml("#{dir}/#{r}")['pages']
          account_roles['pages'] += pages if pages
        end
      end

      def roles_yml(roles = nil, area = nil)
        area_dir = "/#{area}" if area.present?
        if roles.is_a?(String)
          load_yml("#{area_dir}/#{roles}")
        elsif roles.is_a?(Array)
          files = get_config_array(roles, area_dir)

          # find the same pages and merge them
          merged_files = {'pages' => []}
          files['pages'].each do |pages|
            merged = false
            pages.each_pair do |key, page|
              merged_files['pages'].each do |m_page|
                if m_page.include?(key)
                  merged = true
                  m_page[key] = m_page[key] + page
                end
              end
            end
            if !merged
              merged_files['pages'] << pages
            end
          end
          merged_files
        else
          load_yml("/#{area}/bhf" if area.present?)
        end
      end

      def load_yml(suffix = nil)
        YAML::load(IO.read("config/bhf#{suffix}.yml"))
      end
    
    end

  end
end