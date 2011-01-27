module Bhf
  module BhfHelper

    def node(f, column, &block)
      render :partial => 'bhf/helper/node', :locals => {:f => f, :column => column, :input => with_output_buffer(&block)}
    end

  end
end