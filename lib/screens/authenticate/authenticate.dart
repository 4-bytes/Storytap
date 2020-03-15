// Packages
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:storytap/shared/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
// Shared
import 'package:storytap/shared/validator.dart';
import 'package:storytap/shared/loading.dart';

// *** 
// Authenticate screen that consists of signIn, register, resetPassword forms, 
// as well as allowing users to sign in anon and convert to registered users.

final primaryThemeColor = Color(0xFF0C3241); // Color(0xFF0C3241) old
final secondaryThemeColor = Color(0xFF08212b); // Color(0xFF08212b)
final tertiaryThemeColor = Colors.blueGrey;

enum AuthFormType {
  signIn,
  register,
  resetPassword,
  signInAnon,
  convertAnon
} // Determines signed in or not, changes the state of the forms

class Authenticate extends StatefulWidget {
  final AuthFormType authFormType;

  Authenticate({
    Key key,
    @required this.authFormType,
  }) : super(key: key);

  @override
  _AuthenticateState createState() =>
      _AuthenticateState(authFormType: this.authFormType);
}

class _AuthenticateState extends State<Authenticate> {
  AuthFormType authFormType;

  _AuthenticateState({this.authFormType});
  bool _loadingScreen = false;
  final _formKey = GlobalKey<FormState>();
  String _username;
  String _email;
  String _password;
  String _infoMessage;

  // Switches from sign in to register states
  void switchForm(String state) {
    _formKey.currentState.reset();
    if (state == "register") {
      setState(() {
        authFormType = AuthFormType.register;
      });
    } else if (state == "home") {
      Navigator.of(context).pop();
    } else {
      setState(() {
        authFormType = AuthFormType.signIn;
      });
    }
  }

  bool validateFields() {
    final form = _formKey.currentState;
    form.save();
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  // Submits all forms after validation
  void submit() async {
    if (validateFields() == true) {
      try {
        final auth = Provider.of(context).auth;

        switch (authFormType) {
          case AuthFormType.signIn:
            setState(() {
              _loadingScreen = true;
            });
            String uid = await auth.signInUser(_email, _password);
            print("Signed in using $uid");
            await Future.delayed(const Duration(milliseconds: 2000), () {
              print("Waited 3 seconds");
            });
            if (uid == null) {
              setState(() {
                _loadingScreen = false;
              });
            }
            Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false);
            break;
          case AuthFormType.register:
            // TODO: Handle this case.
            break;
          case AuthFormType.resetPassword:
            // Reset password form
            await auth.sendResetPassword(_email);
            _infoMessage = "A password reset link has been sent to $_email";
            setState(() {
              authFormType = AuthFormType.signIn;
            });
            break;
          case AuthFormType.signInAnon:
            // TODO: Handle this case.
            break;
          case AuthFormType.convertAnon:
            await auth.convertAnonWithEmail(_email, _password, _username);
            Navigator.of(context).pop();
            break;
        }

        if (authFormType == AuthFormType.signIn) {
          // Sign in form

        } else if (authFormType == AuthFormType.resetPassword) {
        } else {
          // Register form
          setState(() {
            _loadingScreen = true;
          });
          String uid = await auth.createNewUser(_email, _password, _username);
          print("Registered using $uid");
          if (uid == null) {
            setState(() {
              _loadingScreen = false;
            });
          }
          // Navigator.of(context).pushNamedAndRemoveUntil("/home", ModalRoute.withName("/"));
          Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false);
        }
      } catch (error) {
        await Future.delayed(const Duration(milliseconds: 2000), () {
          print("Waited 3 seconds");
        });
        setState(() {
          _loadingScreen = false;
          _infoMessage = error.message;
        });
        print(_infoMessage);
      }
    }
  }

  Future submitAnon() async {
    // Sign in user anonymously
    try {
      setState(() {
        _loadingScreen = true;
      });
      final auth = Provider.of(context).auth;
      await auth.signInAnon();
      Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false);
    } catch (error) {
      await Future.delayed(const Duration(milliseconds: 2000), () {
        print("Waited 3 seconds");
      });
      setState(() {
        _loadingScreen = false;
        _infoMessage = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    if (authFormType == AuthFormType.signInAnon) {
      submitAnon();
    }
    return _loadingScreen
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: secondaryThemeColor,
              bottomOpacity: 0,
            ),
            body: SingleChildScrollView(
              child: Container(
                  color: primaryThemeColor,
                  height: _height,
                  width: _width,
                  child: SafeArea(
                    child: Column(
                      children: <Widget>[
                        showAlert(),
                        SizedBox(
                          height: _height * 0.025,
                        ),
                        buildHeaderText(),
                        buildSubHeaderText(),
                        SizedBox(
                          height: _height * 0.025,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: buildFields() + buildBtns(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
          );
  }

  Widget showAlert() {
    if (_infoMessage != null) {
      return Container(
        color: secondaryThemeColor,
        width: double.infinity,
        padding: EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.error,
                color: Colors.amber,
              ),
            ),
            Expanded(
              child: AutoSizeText(
                _infoMessage,
                maxLines: 3,
                style: TextStyle(color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                color: Colors.red,
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _infoMessage = null;
                  });
                },
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      height: 0,
    );
  }

  AutoSizeText buildHeaderText() {
    // Header text is built based on form states
    String _headerText;
    if (authFormType == AuthFormType.signIn) {
      _headerText = "Welcome Back";
    } else if (authFormType == AuthFormType.resetPassword) {
      _headerText = "Reset Password";
    } else {
      _headerText = "Register Account";
    }
    return AutoSizeText(
      _headerText,
      maxLines: 1,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 36,
        color: Colors.grey,
      ),
    );
  }

  AutoSizeText buildSubHeaderText() {
    // SubHeader text is built based on form states
    String _subHeaderText;
    if (authFormType == AuthFormType.signIn) {
      _subHeaderText = "We're happy to see you again!";
    } else if (authFormType == AuthFormType.resetPassword) {
      _subHeaderText = "Enter an email to request a password reset.";
    } else {
      _subHeaderText = "Thank you for joining us!";
    }
    return AutoSizeText(
      _subHeaderText,
      maxLines: 1,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 18,
        color: Colors.grey,
      ),
    );
  }

  List<Widget> buildFields() {
    // Creates fields based on the form state that is active
    List<Widget> textFields = [];

    if (authFormType == AuthFormType.resetPassword) {
      textFields.add(
        TextFormField(
          style: TextStyle(
            fontSize: 18,
          ),
          decoration: buildInputDecoration("Email: "),
          onSaved: (val) {
            _email = val;
          },
          validator: EmailValidator.validate,
        ),
      );
      textFields.add(SizedBox(
        height: 25,
      ));
      return textFields;
    }

    // If in register state then add username, email and password fields
    if ([AuthFormType.register, AuthFormType.convertAnon]
        .contains(AuthFormType)) {
      textFields.add(
        TextFormField(
          style: TextStyle(
            fontSize: 18,
          ),
          decoration: buildInputDecoration("Username: "),
          onSaved: (val) {
            _username = val;
          },
          validator: UsernameValidator.validate,
        ),
      );
      textFields.add(SizedBox(
        height: 25,
      ));
    }
    textFields.add(
      TextFormField(
        style: TextStyle(
          fontSize: 18,
        ),
        decoration: buildInputDecoration("Email: "),
        onSaved: (val) {
          _email = val;
        },
        validator: EmailValidator.validate,
      ),
    );
    textFields.add(
      SizedBox(
        height: 25,
      ),
    );
    textFields.add(
      TextFormField(
        style: TextStyle(
          fontSize: 18,
        ),
        decoration: buildInputDecoration("Password: "),
        obscureText: true,
        onSaved: (val) {
          _password = val;
        },
        validator: PasswordValidator.validate,
      ),
    );
    textFields.add(SizedBox(
      height: 25,
    ));
    return textFields;
  }

  InputDecoration buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      focusColor: Colors.grey,
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 0)),
      contentPadding:
          const EdgeInsets.only(left: 14, bottom: 10, top: 10, right: 14),
    );
  }

  List<Widget> buildBtns() {
    // Creates btns for based on form
    String _switchBtn;
    String _newFormState;
    String _submitBtn;
    bool _showForgotPass = false;
    bool _showSocialBtns = true;

    if (authFormType == AuthFormType.signIn) {
      _switchBtn = "New user? Create an account";
      _newFormState = "register";
      _submitBtn = "Sign In";
      _showForgotPass = true;
      _showSocialBtns = true;
      print("Changed state -> " + _newFormState);
    } else if (authFormType == AuthFormType.resetPassword) {
      _switchBtn = "Back to Sign In";
      _newFormState = "signIn";
      _submitBtn = "Submit email";
      _showSocialBtns = false;
    } else if (authFormType == AuthFormType.convertAnon) {
      _switchBtn = "Back to Home";
      _newFormState = "home";
      _submitBtn = "Register";
    } else {
      _switchBtn = "Already have an account? Sign In";
      _newFormState = "SignIn";
      _submitBtn = "Register";
      print("Changed state -> " + _newFormState);
    }

    return [
      Container(
        width: MediaQuery.of(context).size.width * 0.5,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          color: Colors.white,
          textColor: primaryThemeColor,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              _submitBtn,
              style: TextStyle(fontSize: 20),
            ),
          ),
          onPressed: submit,
        ),
      ),
      showForgotPass(_showForgotPass),
      FlatButton(
        child: Text(
          _switchBtn,
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
        onPressed: () {
          switchForm(_newFormState);
        },
      ),
      buildSocialBtns(_showSocialBtns),
    ];
  }

  Widget showForgotPass(bool value) {
    return Visibility(
      child: FlatButton(
        child: Text(
          "Forgot password?",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
        onPressed: () {
          setState(() {
            authFormType = AuthFormType.resetPassword;
          });
        },
      ),
      visible: value,
    );
  }

  Widget buildSocialBtns(bool value) {
    final _auth = Provider.of(context).auth;
    return Visibility(
      child: Column(
        children: <Widget>[
          Divider(
            color: Colors.grey,
          ),
          SizedBox(
            height: 0.05,
          ),
          GoogleSignInButton(
            onPressed: () async {
              try {
                if (authFormType == AuthFormType.convertAnon) {
                  await _auth.convertAnonWithGoogle(
                      _email, _password, _username);
                  await Future.delayed(const Duration(milliseconds: 2000), () {
                    print("Waited 3 seconds");
                  });
                  Navigator.pushNamedAndRemoveUntil(
                      context, "/home", (r) => false);
                } else {
                  setState(() {
                    _loadingScreen = true;
                  });
                  await _auth.signInWithGoogle();
                  await Future.delayed(const Duration(milliseconds: 2000), () {
                    print("Waited 3 seconds");
                  });
                  Navigator.pushNamedAndRemoveUntil(
                      context, "/home", (r) => false);
                }
              } catch (error) {
                setState(() {
                  _loadingScreen = false;
                });
                _infoMessage = error;
              }
            },
          ),
          FacebookSignInButton(
            onPressed: () {},
          ),
        ],
      ),
      visible: value,
    );
  }
}
