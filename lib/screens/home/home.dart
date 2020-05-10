// Packages
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
// Shared
import 'package:storytap/shared/provider.dart';

// ***
// A home screen displayed to users that are authenticated and users that are not authenticated.

class Home extends StatelessWidget {
  // Sets a custom message based on current time
  String timeOfDayMessage() {
    String message = "Hi";
    DateTime now = DateTime.now();
    var timeNow = int.parse(DateFormat('kk').format(now));
    if (timeNow <= 12) {
      return message = "Good morning";
    } else if ((timeNow > 12) && (timeNow <= 16)) {
      return message = "Good afternoon";
    } else if ((timeNow > 16) && (timeNow <= 24)) {
      return message = "Good evening";
    } else {
      return message; // Use default greeting message if time cannot be parsed
    }
  }

  // Sets an icon to be displayed based on current time
  Widget timeOfDayIcon() {
    DateTime now = DateTime.now();
    var timeNow = int.parse(DateFormat('kk').format(now));
    if (timeNow <= 12) {
      return Icon(
        Icons.brightness_7,
        size: 72,
      );
    } else if ((timeNow > 12) && (timeNow <= 16)) {
      return Icon(
        Icons.brightness_6,
        size: 72,
      );
    } else if ((timeNow > 16) && (timeNow <= 24)) {
      return Icon(
        Icons.brightness_2,
        size: 72,
      );
    } else {
      return Icon(Icons.border_color);
    }
  }

  // Displays a personalised greeting widget to the user
  Widget displayHomeGreeting(context, snapshot) {
    final user = snapshot.data;
    String message = timeOfDayMessage();
    Widget icon = timeOfDayIcon();
    return Column(
      children: <Widget>[
        Text(""),
        Text(""),
        icon,
        Text(""),
        ListTile(
          title: Text(
            message + " ${user.displayName ?? ''}",
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ),
        Text(""),
        ListTile(
          title: Text(
            "What would you like to do?",
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ),
        Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Container(
      height: _height,
      width: _width,
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder(
              future: Provider.of(context).auth.getUser(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return displayHomeGreeting(context, snapshot);
                } else {
                  return const CircularProgressIndicator();
                }
              })),
    );
  }
}
