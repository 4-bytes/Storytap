
import 'package:flutter/material.dart';
// Services
import 'services/auth.dart';
// Shared
import 'shared/provider.dart';
import 'package:storytap/shared/loading.dart';
// Screens
import 'screens/welcome/welcome.dart';
import 'screens/authenticate/authenticate.dart';
import 'package:storytap/screens/navbar.dart';

// *** 
// Root of application that is executed.

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return Provider(
      auth: AuthService(),
      child: MaterialApp(
        title: 'Storytap',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Welcome(),
        routes: <String, WidgetBuilder>{
          '/home': (BuildContext context) => HomeController(),
          '/register': (BuildContext context) => Authenticate(
                authFormType: AuthFormType.register,
              ),
          '/signIn': (BuildContext context) => Authenticate(
                authFormType: AuthFormType.signIn,
              ),
          '/signInAnon': (BuildContext context) => Authenticate(
                authFormType: AuthFormType.signInAnon,
              ),
          '/convertAnon': (BuildContext context) => Authenticate(
            authFormType: AuthFormType.convertAnon,
          ),
        },
      ),
    );
  }
}

// Controls whether to display home or launcher screen
class HomeController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the current auth status from inherited widget
    final AuthService auth = Provider.of(context).auth;
    return StreamBuilder( 
      stream: auth.onAuthStateChanged, // Check if the auth state has changed
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final bool signedIn = snapshot.hasData; 
          // Displays screen depending on whether snapshot is null or not
          return signedIn ? NavigationBar() : Welcome();
        }
        return Loading();
      },
    );
  }
}

// Alerts all child widgets that auth state changes
