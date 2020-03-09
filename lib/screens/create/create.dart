// Dependencies
import 'package:flutter/material.dart';
// Services
import 'package:storytap/services/auth.dart';
// Shared
import 'package:storytap/shared/provider.dart';
// Screens
import 'package:storytap/screens/authenticate/authenticate.dart';

class Create extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return Container(
        height: _height,
        width: _width,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Create",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
              )),
        ),
    );
  }
}