// Dependencies
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_fonts/google_fonts.dart';

// Shared
import 'package:storytap/shared/prompt.dart';

// Welcome screen

class Welcome extends StatelessWidget {
  final primaryThemeColor = Color(0xFF0C3241);
  final secondaryThemeColor = Color(0xFF08212b);
  
  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: _width,
        height: _height,
        color: primaryThemeColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: _height * 0.15,
                ),
                Text(
                  "Storytap",
                  style: GoogleFonts.pacifico(
                    fontSize: 44,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(
                  height: _height * 0.15,
                ),
                AutoSizeText(
                  "Welcome to Storytap.",
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(
                  height: _height * 0.15,
                ),
                RaisedButton(
                  padding: const EdgeInsets.only(
                      top: 10, bottom: 10, left: 30, right: 30),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  child: Text(
                    "Let's get started",
                    style: TextStyle(
                      fontSize: 24,
                      color: primaryThemeColor,
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => Prompt(
                        title: "Create a free account",
                        description:
                            "An account will allow your data to be securely backed up, and accessible from multiple devices.",
                        primaryBtnText: "Register",
                        primaryBtnRoute: "/register",
                        secondaryBtnText: "Skip",
                        secondaryBtnRoute: "/anonSignIn",
                        pushNamed: true,
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: _height * 0.04,
                ),
                RaisedButton(
                  padding: const EdgeInsets.only(
                      top: 10, bottom: 10, left: 30, right: 30),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  child: Text(
                    "Sign In",
                    style: TextStyle(
                      color: primaryThemeColor,
                      fontSize: 24,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/signIn');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
