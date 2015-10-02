class Bhf::ApplicationController < ActionController::Base
  include Bhf::Extension::ApplicationController
  protect_from_forgery
end
