module Bhf::Settings

  class Platform

    attr_reader :name, :data, :page_name, :hash, :settings_base

    def initialize(settings_hash, page_name, settings_base)
      if settings_hash.is_a?(String)
        settings_hash = {settings_hash => nil}
      end
      @name = settings_hash.keys[0]
      @hash = settings_hash.values[0] || {}

      @settings_base = settings_base
      @page_name = page_name
    end

  end

end
