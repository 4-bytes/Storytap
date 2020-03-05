
import 'package:flutter/material.dart';
// Services
import 'services/auth.dart';
// Shared
import 'shared/provider.dart';
import 'package:storytap/shared/loading.dart';
// Screens
import 'screens/welcome/welcome.dart';
import 'screens/home/home.dart';
import 'screens/authenticate/authenticate.dart';
import 'package:storytap/screens/navbar.dart';



void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
      auth: Auth(),
      child: MaterialApp(
        title: 'Storytap',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: NavigationBar(),
        routes: <String, WidgetBuilder>{
          '/register': (BuildContext context) => Authenticate(
                authFormType: AuthFormType.register,
              ),
          '/signIn': (BuildContext context) => Authenticate(
                authFormType: AuthFormType.signIn,
              ),
          '/anonSignIn': (BuildContext context) => Authenticate(
                authFormType: AuthFormType.anonymous,
              ),
          '/home': (BuildContext context) => HomeController(),
        },
      ),
    );
  }
}

// Controls whether to display home or launcher screen
class HomeController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Auth auth = Provider.of(context).auth;
    return StreamBuilder(
      stream: auth.onAuthStateChanged,
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final bool signedIn = snapshot.hasData;
          return signedIn ? Home() : Welcome();
        }
        return Loading();
      },
    );
  }
}

// Alerts all child widgets that auth state changes
