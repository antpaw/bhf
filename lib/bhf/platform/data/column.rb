module Bhf::Platform::Data
  class Column

    attr_reader :name, :field, :reflection, :db_name, :reorderble, :title

    def initialize(field, model)
      @name = field.name
      @field = field
      @reflection = (field.reflection if field.respond_to?(:reflection))
      @db_name = @reflection ? @reflection.foreign_key : @name
      @reorderble = model.bhf_attribute_method?(@db_name)
      @title = model.human_attribute_name(@name)
    end

  end
end