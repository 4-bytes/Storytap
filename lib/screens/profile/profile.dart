// Packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
// Services
import 'package:storytap/services/auth.dart';
import 'package:storytap/services/storage.dart';
// Shared
import 'package:storytap/shared/provider.dart';
// Screens
import 'package:storytap/screens/authenticate/authenticate.dart';

// ***
// Profile page for registered users. It displays the user's information such as registered date, last online, and profile image.

class Profile extends StatefulWidget {
  String profileImageID = "";

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Container(
        height: _height,
        width: _width,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Text(
                  "Profile",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                FutureBuilder(
                  // Displays user profile information based on user's authentication status
                  future: Provider.of(context).auth.getUser(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      // If the connection to snapshot is completed, then display the profile screen
                      return displayProfileScreen(context, snapshot);
                    } else {
                      // Otherwise display a loading indicator
                      return CircularProgressIndicator();
                    }
                  },
                )
              ],
            )),
      ),
    );
  }

  Widget displayProfileScreen(BuildContext context, AsyncSnapshot snapshot) {
    final user = snapshot.data;
    if (user.isAnonymous == true) {
      return Column(
        children: <Widget>[
          Image.network("https://firebasestorage.googleapis.com/v0/b/storytap-3c055.appspot.com/o/locked.png?alt=media&token=3a015a79-c9fe-4907-8bf3-72ed4480280a"),
          Divider(),
          Text("You are currently not signed in."),
          Text("Sign In or Register to view your own profile."),
          FlatButton(child: Text("Sign In"), onPressed: (){},),
          Divider(),
        ],
      );
    } else {
      // Format the times to readable format
      String joinDate =
          DateFormat('dd/MM/yyyy').format(user.metadata.creationTime);
      String lastSeen =
          DateFormat('dd/MM/yyyy').format(user.metadata.lastSignInTime);
      return Column(
        children: <Widget>[
          FutureBuilder(
            // Displays user profile image
            future: _getProfileImage(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: snapshot.data,
                  ),
                );
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
          Divider(),
          Text(
            user.displayName,
            style: TextStyle(fontSize: 32),
          ),
          // DateFormat('dd/MM/yyyy').format(book['bookCreationDate'].toDate()).toString()
          Text(
            "Join Date: " + joinDate,
            style: TextStyle(fontSize: 20),
          ),
          Text(
            "Last Seen: " + lastSeen,
            style: TextStyle(fontSize: 20),
          ),
          Divider(),
        ],
      );
    }
  }

  // Fetches the user's profile image from firebase storage
  Future<Widget> _getProfileImage(BuildContext context) async {
    Image profileImage;
    final uid = await Provider.of(context).auth.getUID();
    // StorageService storage = StorageService(id: uid);
    // final pr = await Provider.of(context).auth.getUserPhotoURL();
    print("Photo above");
    await StorageService.loadProfileImage(context, uid).then((downloadUrl) {
      print(downloadUrl.toString());
      profileImage = Image.network(
        downloadUrl.toString(),
        fit: BoxFit.cover,
      );
    });

    return profileImage;
  }
}
