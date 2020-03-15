// *** 
// List of classes used to validate form fields.

// Validates username field
class UsernameValidator{
  static String validate(String value){
    if (value.isEmpty){
      return "Username is cannot be left empty.";
    }
    else if (value.length < 3 || value.length > 20){
      return "Usernames must be 3 to 20 characters long.";
    }
    else if (value.contains(" ")){
      return "Usernames cannot contain any spacing.";
    }
    else if (!value.contains(RegExp(r'^[a-zA-Z0-9]+$'))){
      return "Usernames may only contain letters and numbers.";
    }
    return null;
  }
}

// Validates email field
class EmailValidator{
  static String validate(String value){
    if (value.isEmpty){
      return "Email address cannot be left empty.";
    }
    return null;
  }
}

// Validates password field
class PasswordValidator{
  static String validate(String value){
    if (value.isEmpty){
      return "Password is cannot be left empty.";
    }
    else if (value.length < 6){
      return "Passwords must be at least 8 characters long.";
    }
    return null;
  }
}

