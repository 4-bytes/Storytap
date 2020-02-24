import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  final primaryThemeColor = Color(0xFF0C3241);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryThemeColor,
      body: Center(child: SpinKitFoldingCube(
        color: Colors.grey,
        size: 60,
      )),
    );
  }
}