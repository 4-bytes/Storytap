// Dependencies
import 'package:flutter/material.dart';
// Services
import 'package:storytap/services/auth.dart';
// Shared
import 'package:storytap/shared/provider.dart';
// Screens
import 'package:storytap/screens/authenticate/authenticate.dart';

// ***
// Displays settings screen.

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return Container(
      height: _height,
      width: _width,
      child: FutureBuilder(
        // Displays user profile information based on user's authentication status
        future: Provider.of(context).auth.getUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the connection to snapshot is completed, then display the profile screen
            return checkIsAnon(context, snapshot);
          } else {
            // Otherwise display a loading indicator
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  void showPrompt(BuildContext context, String title) {
    // Prompt that is displayed based on what icon button is pressed
    showDialog(
        context: context,
        builder: (BuildContext context) {
          if (title == "Help") {
            return AlertDialog(
              title: Text("Help"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                      "This is an online platform made for interactive narratives."),
                  Text("You can browse a list of created books and read them."),
                  Text(
                      "You can also create your own books and other users will be able to read them.")
                ],
              ),
              actions: <Widget>[
                FlatButton(
                  color: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  child: Text(
                    "Done",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          } else {
            return AlertDialog(
              title: Text("App Info"),
              content: Text(
                  "This application was made using Flutter."),
              actions: <Widget>[
                FlatButton(
                  color: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  child: Text(
                    "Done",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          }
        });
  }

  Widget checkIsAnon(BuildContext context, AsyncSnapshot snapshot) {
    final user = snapshot.data;
    if (user.isAnonymous == true) {
      return ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            InkWell(
              onTap: () {
                 showPrompt(context, "Help");
              },
              child: ListTile(
                leading: Icon(
                  Icons.help,
                  color: primaryThemeColor,
                ),
                title: Text(
                  'Help',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                showPrompt(context, "Info");
              },
              child: ListTile(
                leading: Icon(
                  Icons.update,
                  color: primaryThemeColor,
                ),
                title: Text(
                  'App Info',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                final auth = Provider.of(context).auth;
                if (await auth.isAnon()) {
                  // Safety to ensure that prevents signed in from getting deleted
                  print("This is anon");
                  await auth.deleteUser();
                  print("Deleted successfully.");
                } else {
                  print("Real user");
                  await auth.signOut();
                }
              },
              child: ListTile(
                leading: Icon(
                  Icons.supervised_user_circle,
                  color: primaryThemeColor,
                ),
                title: Text(
                  'Sign In',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ).toList(),
      );
    } else {
      return ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            InkWell(
              onTap: () {
        
                showPrompt(context, "Help");
              },
              child: ListTile(
                leading: Icon(
                  Icons.help,
                  color: primaryThemeColor,
                ),
                title: Text(
                  'Help',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                print("Pressed");
                showPrompt(context, "Info");
              },
              child: ListTile(
                leading: Icon(
                  Icons.update,
                  color: primaryThemeColor,
                ),
                title: Text(
                  'App Info',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                final auth = Provider.of(context).auth;
                if (await auth.isAnon()) {
                  // Safety to ensure that prevents signed in from getting deleted
                  print("This is anon");
                  await auth.deleteUser();
                  print("Deleted successfully.");
                } else {
                  print("Real user");
                  await auth.signOut();
                }
              },
              child: ListTile(
                leading: Icon(
                  Icons.exit_to_app,
                  color: primaryThemeColor,
                ),
                title: Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ).toList(),
      );
    }
  }
}
