class Bhf::Base < ActiveRecord::Base
  
  class << self
    def make
      "widget made"
    end
  end
  
end