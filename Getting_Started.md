### Skip blank fields on create/update

You are able to skip blank fields (like password, and password_confirmation) for form settings
on update or create action:

    form:
      display: [name, password, password_confirmation]
      skip_blank: [password, password_confirmation]

The feature can be useful when user admin wish not to change a password of a user record, but
the user model validates that password must be not null.
