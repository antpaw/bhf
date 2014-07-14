module Bhf::Settings

  class YAMLParser

    attr_accessor :settings_hash

    def initialize(roles_array, area = nil)
      roles_settings = roles_yml(roles_array, area)

      if Bhf.configuration.abstract_settings.any?
        tmp_pages = get_settings_array(Bhf.configuration.abstract_settings)['pages']
        abstract_platform_settings = tmp_pages.each_with_object({}) do |abstract_pages, hash|
          abstract_pages.each do |abstract_page|
            abstract_page[1].each do |abstract_platform|
              hash.merge!(abstract_platform)
            end
          end
        end

        roles_settings['pages'].each_with_index do |pages, i_1|
          pages.each_pair do |key_1, page|
            page.each_with_index do |platform, i_2|
              platform.each_pair do |key_2, v|
                value = v.is_a?(Hash) ? v : {}
                abstract_platform_key = if value['extend_abstract']
                  value['extend_abstract']
                elsif abstract_platform_settings[key_2]
                  key_2
                end
                next unless abstract_platform_key
                roles_settings['pages'][i_1][key_1][i_2][key_2] = abstract_platform_settings[abstract_platform_key].deep_merge(value)
              end
            end
          end
        end
      end

      @settings_hash = roles_settings
    end

    def get_settings_array(array, dir = nil)
      array.each_with_object({'pages' => []}) do |file_name, tmp_settings_hash|
        absolut_path = false
        file_path = if dir
          "#{dir}/#{file_name}"
        else
          if file_name[0,1] == '/'
            absolut_path = true
            file_name
          else
            "/#{file_name}"
          end
        end
        pages = load_yml(file_path, absolut_path)['pages']
        tmp_settings_hash['pages'] += pages if pages
      end
    end

    def roles_yml(roles = nil, area = nil)
      area_dir = "/#{area}" if area.present?
      if roles.is_a?(Array)
        files = get_settings_array(roles, area_dir)

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
          unless merged
            merged_files['pages'] << pages
          end
        end
        merged_files
      else
        load_yml(area.present? ? "/#{area}/bhf" : nil)
      end
    end

    def load_yml(suffix = nil, absolut_path = false)
      file_path = if absolut_path
        "#{suffix}.yml"
      else
        "config/bhf#{suffix}.yml"
      end
      YAML::load(IO.read(file_path))
    end

  end

end