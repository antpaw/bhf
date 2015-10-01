### Setup default authentication engine

You are able to set up the default authentication engine to avoid its explicit declaration in your controller.
Just assign `:devise` value to `.auth_engine` config propery, of course if you use the `Devise` gem for
authentication.

    Bhf.configure do |config|
      config.auth_engine = :devise
    end

### Setup user authentication

Along with the standard approach in authentication, instead of defining the `#login` action in the
`Admin` controller, you are able to redefine `Bhf::ApplicationController`, and its `#check_admin_account` 
method, to give to `Bhf` the knowledge about weither current user is admin or not. Do it like follows:

    class Bhf::ApplicationController < ActionController::Base
      include Bhf::Extension::ApplicationController
      protect_from_forgery

      def check_admin_account
        current_user.is_admin? # Here expression must be evaluated to `true` if user is admin.
      end
    end

