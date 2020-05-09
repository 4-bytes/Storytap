// Packages
import 'package:flutter/material.dart';
import 'package:storytap/screens/authenticate/authenticate.dart';
import 'package:zefyr/zefyr.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
// Models
import 'package:storytap/models/book.dart';
import 'package:storytap/models/branch.dart';
import 'package:storytap/models/page.dart';
// Services
import 'package:storytap/services/database.dart';

class Reader extends StatefulWidget {
  final Book currentBook;
  final Page currentPage;
  final List<Branch> currentBranch;
  final int branchesLength;
  final uid;

  Reader(
      {Key key,
      this.currentBook,
      this.currentPage,
      this.currentBranch,
      this.branchesLength,
      this.uid})
      : super(key: key);

  @override
  _ReaderState createState() => _ReaderState();
}

// This screen displays the reading viewer for the book that is currently being read. It is called multiple times and updates to the current page that is being viewed.

class _ReaderState extends State<Reader> {
  void initState() {
    super.initState();
    final document = _loadDocument();
  }

  NotusDocument _loadDocument() {
    // Parse the string and return the Json object from the widget that is holding the page's text
    NotusDocument pageText =
        NotusDocument.fromJson(jsonDecode(widget.currentPage.text));
    return pageText;
  }

  // Loads a page after a branch has been pressed
  Future loadPage(int val) async {
    final database = DatabaseService(uid: widget.uid);
    final pageSnapshot = database
        .usersCollection // First retrieve the page snapshot using the reference in currentBranch
        .document(widget.uid)
        .collection("books")
        .document(widget.currentBook.id)
        .collection("pages")
        .document(widget.currentBranch[val].pageID);

    final page = await pageSnapshot.get(); // This is the document

    // Assign the new page's data into the currentPage's values
    widget.currentPage.text = page.data['pageText'];
    widget.currentPage.id = page.documentID;
    widget.currentPage.lastUpdated = page.data['pageLastUpdated'].toDate();

    // Next retrieve all the branches from that page
    final branches = await pageSnapshot.collection("branches").getDocuments();
    int newBranchLength = 0; // Set the newBranch length as 0
    


    for (int i = 0; i < branches.documents.length; i++) {
      print("CHANGED VALUES");
      newBranchLength = newBranchLength + 1; // Add branch details and increment each time
      widget.currentBranch[i].text = branches.documents[i]['branchText'];
      widget.currentBranch[i].pageID = branches.documents[i]['branchPageReference'];
      print(widget.currentBranch[i].text);
      print(widget.currentBranch[i].pageID);
    }

    
    Navigator.pushReplacement( // Replace the current screen with a new one passing all new values to it
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => Reader(
                  currentBook: widget.currentBook,
                  currentPage: widget.currentPage,
                  currentBranch: widget.currentBranch,
                  branchesLength: newBranchLength,
                  uid: widget.uid,
                )));
  }

  Widget branchButton1() {
    return FlatButton(
      color: secondaryThemeColor,
      textColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      child: Text(widget.currentBranch[0].text),
      onPressed: () async {
        loadPage(0);
      },
    );
  }

  Widget branchButton2() {
    return FlatButton(
      color: secondaryThemeColor,
      textColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      child: Text(widget.currentBranch[1].text),
      onPressed: () async {
        loadPage(1);
      },
    );
  }

  Widget branchButton3() {
    return FlatButton(
      color: secondaryThemeColor,
      textColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      child: Text(widget.currentBranch[2].text),
      onPressed: () async {
        loadPage(2);
      },
    );
  }

  Widget displayBranchButtons() {
    if (widget.branchesLength == 1) {
      return Column(
        children: <Widget>[
          branchButton1(),
        ],
      );
      // Display 1 button branch
    } else if (widget.branchesLength == 2) {
      return Column(
        children: <Widget>[
          branchButton1(),
          branchButton2(),
        ],
      );
      // Display 2
    } else if (widget.branchesLength == 3) {
      return Column(
        children: <Widget>[
          branchButton1(),
          branchButton2(),
          branchButton3(),
        ],
      ); // Display all 3
    } else {
      return completedBook();
    }
  }

  // A widget that is displayed to show the end of a book, when there are no branches present
  Widget completedBook() {
    return Column(
      children: <Widget>[
        Text("You have reached the end of this book."),
        FlatButton(
          color: secondaryThemeColor,
          textColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          child: Text("Close Book"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryThemeColor,
        title: Text(widget.currentBook.title),
      ),
      body: ZefyrScaffold(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ZefyrView(
                  document: _loadDocument(),
                ),
                displayBranchButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
