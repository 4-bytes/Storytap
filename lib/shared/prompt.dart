// Packages
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

// *** 
// A reusable widget for prompt messages and dialogs.

class Prompt extends StatelessWidget {
  final String title;
  final String description;
  final String primaryBtnText;
  final String primaryBtnRoute;
  final String secondaryBtnText;
  final String secondaryBtnRoute;
  final bool pushNamed; // Determines what type of navigator to use
  final primaryThemeColor = Color(0xFF0C3241);
  final secondaryThemeColor = Color(0xFF707070);

  Prompt({
    @required this.title,
    @required this.description,
    @required this.primaryBtnText,
    @required this.primaryBtnRoute,
    this.pushNamed,
    this.secondaryBtnText,
    this.secondaryBtnRoute,
  });

  static const double padding = 20.0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(padding),
      ),
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(padding),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize
                  .min, // Makes popup as small as possible based on screen size
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                AutoSizeText(
                  title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primaryThemeColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                AutoSizeText(
                  description,
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: secondaryThemeColor,
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                RaisedButton(
                  color: primaryThemeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  child: AutoSizeText(
                    primaryBtnText,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    if (pushNamed == true) {
                      // Pushes a new route without disposing original
                      Navigator.of(context).pushNamed(primaryBtnRoute);
                    } else {
                      // Navigates and disposes original route path
                      Navigator.of(context).pop();
                      Navigator.of(context)
                          .pushReplacementNamed(primaryBtnRoute);
                    }
                  },
                ),
                SizedBox(height: 10.0),
                buildSecondaryBtn(context)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSecondaryBtn(BuildContext context) {
    if (secondaryBtnRoute != null && secondaryBtnText != null) {
      return FlatButton(
        color: primaryThemeColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
        child: AutoSizeText(
          secondaryBtnText,
          maxLines: 1,
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        onPressed: () {
          if (pushNamed == true) {
            Navigator.of(context).pushNamed(secondaryBtnRoute);
          } else {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed(secondaryBtnRoute);
          }
        },
      );
    } else {
      return SizedBox(
        height: 10.0,
      );
    }
  }
}
