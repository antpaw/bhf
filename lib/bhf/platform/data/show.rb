module Bhf::Platform::Data
  class Show

    attr_reader :name, :field
    
    def initialize(field)
      @name = field.name
      @field = field
    end
    
  end
end