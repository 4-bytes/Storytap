import 'package:flutter/material.dart';
import 'screens/launcher/welcome.dart';
import 'screens/home/home.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Launcher(),
      routes: <String, WidgetBuilder>{
        '/register': (BuildContext context) => Home(),
        '/home' : (BuildContext context) => Home(),
      },
    );
  }
}
