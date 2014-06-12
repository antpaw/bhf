module Bhf::Platform::Data
  class Column

    attr_reader :name, :field, :overwrite_display_type

    def initialize(field)
      @name = field.name
      @field = field
    end

  end
end