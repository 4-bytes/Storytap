import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// *** 
// Displays loading screen animation using flutter_spinkit.

class Loading extends StatelessWidget {

  const Loading();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0C3241),
      body: Center(child: SpinKitFoldingCube(
        color: Colors.grey,
        size: 60,
      )),
    );
  }
}