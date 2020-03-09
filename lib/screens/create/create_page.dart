import 'package:flutter/material.dart';
import 'package:zefyr/zefyr.dart';

import 'package:quill_delta/quill_delta.dart';

// Screens
import 'package:storytap/screens/authenticate/authenticate.dart';

// Models
import 'package:storytap/models/book.dart';
import 'package:storytap/models/page.dart';
// Screens

class CreatePage extends StatefulWidget {
  // final Book book;
  // final Page page;

  //CreatePage({Key key, @required this.book, @required this.page})
  // : super(key: key);
  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  TextEditingController _pageTitleController;
  ZefyrController _pageTextController;
  FocusNode _focusNode;

  void initState() {
    super.initState();

    final document = _loadDocument();
    _pageTextController = ZefyrController(document);
    _focusNode = FocusNode();
  }

  NotusDocument _loadDocument() {
    final Delta delta = Delta()
      ..insert("Tap here to begin writing your first page...\n");
    return NotusDocument.fromDelta(delta);
  }

  void _clearDocument(ZefyrController controller) {
    try {
      controller.replaceText(0, controller.document.length - 1, 'Tap here to begin writing your first page...\n');
    }
    catch (error){
      print (error);
    }
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _editorHeight = _height * 0.65;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.restore_page),
            onPressed: () {
              _clearDocument(_pageTextController);
            },
          )
        ],
        backgroundColor: primaryThemeColor,
        title: Text("Create Page"),
      ),
      body: ZefyrScaffold(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                    labelText: "Enter Page Title",
                    hintText: "This is an identifier that only you can see."
                  ),
                  maxLength: 15,
                  controller: _pageTitleController,
                  autofocus: true,
                ),
                ZefyrField(
                  autofocus: false,
                  height: _editorHeight,
                  physics: ClampingScrollPhysics(),
                  controller: _pageTextController,
                  focusNode: _focusNode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
