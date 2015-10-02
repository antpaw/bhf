### Setup user authentication

Along with the standard approach in authentication, instead of defining the `#login` action in the
`Admin` controller, you are able to redefine `Bhf::ApplicationController`, and its `#check_admin_account` 
method, to give to `Bhf` the knowledge about weither current user is admin or not. Do it like follows:

    class Bhf::ApplicationController < ActionController::Base
      protect_from_forgery
      before_filter :authenticate_user! # if devise authentication is used
      include Bhf::Extension::ApplicationController

      def check_admin_account
        current_user.is_admin? # Here expression must be evaluated to `true` if user is admin.
      end
    end

