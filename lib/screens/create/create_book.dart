import 'package:flutter/material.dart';
import 'package:storytap/screens/authenticate/authenticate.dart';

// Models
import 'package:storytap/models/book.dart';
import 'package:storytap/models/page.dart';

// Screens
import 'create_page.dart';

class CreateBook extends StatelessWidget {
  final Book book;
  
  CreateBook({Key key, @required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Page newPage = new Page(book: book, text: "");
    TextEditingController _bookTitleController = new TextEditingController();
    TextEditingController _bookDescriptionController = new TextEditingController();
    _bookTitleController.text = book.title;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondaryThemeColor,
        title: Text("Create Book"),
        actions: <Widget>[],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              // Text("Enter book title: "),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  // style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Enter Book Title",
                  ),
                  maxLength: 15,
                  controller: _bookTitleController,
                  autofocus: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    labelText: "Enter Book Description",
                  ),
                  maxLength: 150,
                  maxLines: 5,
                  controller: _bookDescriptionController,
                ),
              ),
              FlatButton(
                padding: const EdgeInsets.only(
                    top: 10, bottom: 10, left: 30, right: 30),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                child: Text("Continue"),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePage()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
