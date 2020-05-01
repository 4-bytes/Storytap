// Packages
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:storytap/shared/provider.dart';
import 'package:zefyr/zefyr.dart';
import 'package:quill_delta/quill_delta.dart';
// Screens
import 'package:storytap/screens/authenticate/authenticate.dart';
// Models
import 'package:storytap/models/book.dart';
import 'package:storytap/models/page.dart';
// Services
import 'package:storytap/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Shared
import 'package:storytap/shared/validator.dart';
// *** 
// Creates an initial page along with the created book and writes this newly added data to cloud firestore.

class CreateNewPage extends StatefulWidget {
  final Book createdBook;
  final Page createdPage;

  CreateNewPage({Key key, @required this.createdBook, @required this.createdPage})
      : super(key: key);
  @override
  _CreateNewPageState createState() => _CreateNewPageState();
}

class _CreateNewPageState extends State<CreateNewPage> {
  TextEditingController _pageTitleController = new TextEditingController();
  ZefyrController _pageTextController;
  FocusNode _focusNode;

  String _titleErrorMessage; // Displays error text below page title field
  String _zefyrErrorMessage; // Displays error text below page text

  void initState() {
    super.initState();
    final document = _loadDocument();
    _pageTextController = ZefyrController(document);
    _focusNode = FocusNode();
  }

  // Validates the zefyrField, ensuring that the document limit is not reached
  bool zefyrFieldValidator(ZefyrController controller){
    if (controller.document.toPlainText().isEmpty){
      setState(() {
        _zefyrErrorMessage = "The page text cannot be left empty.";
      });
      return false;
    }
    else if (controller.document.length > 20){ // Length of the page
      setState(() {
          
        _zefyrErrorMessage = "You have exceeded the max length for this document.";
      });
      return false;
    }
    else {
      return true;
    }
  }

  // Validates the pageTitle, ensuring that the field is not empty and limited
  bool pageTitleValidator(TextEditingController controller){
    if (controller.text.isEmpty){
      setState(() {
        _titleErrorMessage = "The page identifier cannot be left empty.";
      });
      return false;
    }
    else if (controller.text.length < 3 || controller.text.length > 20){
      setState(() {
        _titleErrorMessage = "The page identifier must be 3 to 20 characters long";
      });
      return false;
    }
    else {
      return true;
    }
  }

  // Discards pageTextController after usage
  void dispose(){
    _pageTextController.dispose();
    super.dispose();
  }

  NotusDocument _loadDocument() {
    final Delta delta = Delta()
      ..insert("Tap here to begin writing your first page...\n");
    return NotusDocument.fromDelta(delta);
  }

  void _clearDocument(ZefyrController controller) {
    try {
      controller.replaceText(0, controller.document.length - 1,
          'Tap here to begin writing your first page...\n');
    } catch (error) {
      print(error);
    }
  }

  void _clearTitle(TextEditingController pageTitle){
    pageTitle.text = "";
  }

  @override
  Widget build(BuildContext context) {
    _pageTitleController.text = widget.createdPage.title;
    double _height = MediaQuery.of(context).size.height;
    double _editorHeight = _height * 0.65;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.restore_page),
            onPressed: () {
              _clearTitle(_pageTitleController);
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
                      hintText: "This is a page identifier that only you can see."),
                  maxLength: 15,
                  controller: _pageTitleController,
                  autofocus: true,
                ),
                
                ZefyrField(
                  decoration: InputDecoration(errorText: _zefyrErrorMessage),
                  autofocus: false,
                  height: _editorHeight,
                  physics: ClampingScrollPhysics(),
                  controller: _pageTextController,
                  focusNode: _focusNode,
                ),
                FlatButton(
                  padding: const EdgeInsets.only(
                      top: 10, bottom: 10, left: 30, right: 30),
                  color: secondaryThemeColor,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  child: Text("Create"),
                  onPressed: () async {
                    if (zefyrFieldValidator(_pageTextController) && pageTitleValidator(_pageTitleController)){
                    print("Testsda");
                    final uid = await Provider.of(context).auth.getUID();
                    final username = await Provider.of(context).auth.getUsername();
                    final database = DatabaseService(uid: uid);
                    print("test");
                    // Updating createdBook properties
                    widget.createdBook.lastUpdated = DateTime.now();
                    widget.createdBook.author = username;
                    // Updating createdPage properties
                    widget.createdPage.title = _pageTitleController.text;
                    widget.createdPage.text = jsonEncode(_pageTextController.document); // Converts values into JSON string
                    widget.createdPage.lastUpdated = DateTime.now();
                    widget.createdPage.initial = true;
                    // Creates a subcollection under the "users" and creates a new collection "books" too
                    await database.createBookDocument(widget.createdBook, widget.createdPage).then( (_){
                      print("Updated Firestore with new data");
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    });
                    }
                    else {
                      print("Max length");
                    }
                    
                    //database.createBookDocument(
                    //    widget.createdBook.title,
                    //    widget.createdBook.description,
                    //    widget.createdBook.genre,
                    //    widget.createdBook.cover,
                    //    widget.createdBook.isComplete,
                    //    widget.createdBook.creationDate,
                    //    widget.createdBook.lastUpdated);



                    // await Firestore.instance.collection("test").add({
                    //  'pageText': widget.createdPage.text,
                    //  'pageUpdated': widget.createdPage.lastUpdated,
                    //}).then((_) {
                    

                    // print("JSON: ");
                    // print(_pageTextController.document.toJson());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
