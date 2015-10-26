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


### Addtional field types

Additional two fields `file`, and `type` was added for form view. `File` field can be applied,
when user have to select, and attach a file, which should be sent to server. The file can be
image, etc. If the file is an image, a preview image appeared, when user select input image
for `file` field, or when user edits a record with `file` field and the file is an image.
`Type` field can be applied, when user the `type` named field should be shewn, and selected in
the form. The descendants of the base class is begin enumerated in the select.

Additional three fields `image`, `carrierwave`, and `type` was added for table view. `Image`
field can be applied, when the record has image properties. `Carrierwave` is the same as the `image`
but gets the image from `#midem` action for carrierwave uploader. PDF files also can be shewn
up as a thumbnail. When user moves a cursor over an image or PDF thumbnail, a preview image
is being pop up in table view. `Type` field defines that the spcific records class descendant
type name should be shewn for the column. The name is reduced by the base class name itself.

### Skip blank fields on create/update

You are able to skip blank fields (like password, and password_confirmation) for form settings on update or create action:

    form:
      display: [name, password, password_confirmation]
      skip_blank: [password, password_confirmation]

