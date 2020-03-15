// Packages
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
// Shared
import 'package:storytap/shared/provider.dart';

// ***
// A home screen displayed to users that are authenticated.

class Home extends StatelessWidget {


    // Sets a custom message based on current time
    String timeOfDay() {
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


  Widget displayHomeGreeting(context, snapshot){
    final user = snapshot.data;
    String message = timeOfDay();
    return Column(children: <Widget>[
      ListTile(title: AutoSizeText(message +" ${user.displayName ?? ''}"),)
    ],) ;

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
              future: Provider.of(context).auth.getUser(), builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done){
                  return displayHomeGreeting(context, snapshot);
                }
                else {
                  return const CircularProgressIndicator();
                }
              })),
    );
  }
}
