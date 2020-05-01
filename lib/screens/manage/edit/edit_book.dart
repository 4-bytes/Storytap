// Packages
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:storytap/screens/authenticate/authenticate.dart';
import 'package:storytap/screens/manage/edit/edit_page.dart';
// Services
import 'package:storytap/services/database.dart';
import 'package:storytap/shared/loading.dart';
//Shared
import 'package:storytap/shared/provider.dart';
import 'package:zefyr/zefyr.dart';
//
import 'package:storytap/screens/manage/add/add_page.dart';
// Models
import 'package:storytap/models/book.dart';
import 'package:storytap/models/page.dart';
import 'package:storytap/models/branch.dart';
// ***
// Allows the user to view information about the selected book, edit and create new pages too.

class EditBook extends StatefulWidget {
  final String bookid;
  final Book book;

  EditBook({Key key, this.book, this.bookid}) : super(key: key);

  @override
  _EditBookState createState() => _EditBookState();
}

class _EditBookState extends State<EditBook> {
  String _selected = "None";
  bool _checkboxSelected;
  void choiceAction(String _selected) {}

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryThemeColor,
        title: Text("Manage Book"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              final List<Branch> branches = [
                // Init 3 branches that are used in creating pages
                Branch(null, null, null),
                Branch(null, null, null),
                Branch(null, null, null),
              ];
              final newPage = new Page(
                  book: null,
                  choices: null,
                  initial: false,
                  lastUpdated: null,
                  text: null,
                  title: null); // Init new page needed for the AddPage screen
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddPage(
                            createdBook: widget.book,
                            createdPage: newPage,
                            createdBranch: branches,
                          )));
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: FutureBuilder(
              future: getBookInfo(context, widget.bookid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                } else {
                  return SingleChildScrollView(
                    child: new Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 12, top: 6, bottom: 0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Book Title: ",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              )),
                        ),
                        Divider(
                          color: secondaryThemeColor,
                          thickness: 2,
                        ),
                        InkWell(
                          child: ListTile(
                            subtitle: Text("Click here to edit"),
                            title: Text(snapshot.data['bookTitle']),
                            leading: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.edit),
                            ),
                          ),
                          onTap: () {
                            print("Pressed");
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 12, top: 6, bottom: 0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Book Description: ",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              )),
                        ),
                        Divider(
                          color: secondaryThemeColor,
                          thickness: 2,
                        ),
                        InkWell(
                          child: ListTile(
                            title: Text(snapshot.data['bookDescription']),
                            subtitle: Text("Click here to edit"),
                            leading: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.edit),
                            ),
                          ),
                          onTap: () {
                            print("Pressed");
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 12, top: 6, bottom: 0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Book Genre:",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              )),
                        ),
                        Divider(
                          color: secondaryThemeColor,
                          thickness: 2,
                        ),
                        InkWell(
                          child: ListTile(
                            title: Text(snapshot.data['bookGenre']),
                            subtitle: Text("Click here to edit"),
                            leading: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.edit),
                            ),
                          ),
                          onTap: () {
                            print("Pressed");
                          },
                        ),
                        StreamBuilder(
                          stream: getInitialPage(context, widget.bookid),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const CircularProgressIndicator();
                            } else {
                              return ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: snapshot.data.documents.length,
                                  itemBuilder: (context, int index) {
                                    return buildInitialPage(context,
                                        snapshot.data.documents[index]);
                                  });
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 12, top: 6, bottom: 0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Other pages:",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              )),
                        ),
                        Divider(
                          color: secondaryThemeColor,
                          thickness: 2,
                        ),
                        StreamBuilder(
                          stream: getOtherPages(context, widget.bookid),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const CircularProgressIndicator();
                            } else {
                              return ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(), // Disable StreamBuilder's built in ScrollableScrollPhysics 
                                  shrinkWrap: true,
                                  itemCount: snapshot.data.documents.length,
                                  itemBuilder: (context, int index) {
                                    return buildOtherPages(context,
                                        snapshot.data.documents[index]);
                                  });
                            }
                          },
                        )
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Gets a future documentsnapshot of the book's details
  Future<DocumentSnapshot> getBookInfo(
      BuildContext context, String bookid) async {
    final uid = await Provider.of(context).auth.getUID();
    DatabaseService database = DatabaseService(uid: uid);
    DocumentReference docRef = database.usersCollection
        .document(uid)
        .collection("books")
        .document(bookid);
    Future<DocumentSnapshot> snapshot = docRef.get();
    return snapshot;
  }

  // Returns the initial page of the book
  Stream<QuerySnapshot> getInitialPage(
      BuildContext context, String bookid) async* {
    final uid = await Provider.of(context).auth.getUID();
    DatabaseService database = DatabaseService(uid: uid);

    yield* database.usersCollection
        .document(uid)
        .collection("books")
        .document(bookid)
        .collection("pages")
        .where('initial', isEqualTo: true)
        .snapshots();
  }

  // Returns all other pages of the book
  Stream<QuerySnapshot> getOtherPages(
      BuildContext context, String bookid) async* {
    final uid = await Provider.of(context).auth.getUID();
    DatabaseService database = DatabaseService(uid: uid);

    yield* database.usersCollection
        .document(uid)
        .collection("books")
        .document(bookid)
        .collection("pages")
        .where("initial", isEqualTo: false)
        .snapshots();
  }

  Widget buildInitialPage(BuildContext context, DocumentSnapshot page) {
    return Column(
      children: <Widget>[
        Container(
          child: ListTile(
            title: Text("List of pages: "),
          ),
          color: Colors.grey,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12, top: 6, bottom: 0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Initial Page: ",
                style: TextStyle(
                  fontSize: 16,
                ),
              )),
        ),
        Divider(
          color: secondaryThemeColor,
          thickness: 2,
        ),
        InkWell(
          child: ListTile(
            title: Text(page['pageTitle']),
            subtitle: Text(
                "Last updated: " + page['pageLastUpdated'].toDate().toString()),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.edit),
            ),
          ),
          onTap: () async {
            // print("Pressed");
            final uid = await Provider.of(context).auth.getUID();
            DatabaseService database = DatabaseService(uid: uid);
            // Get a snapshot of the branches related to the page
            QuerySnapshot branchDocuments = await database.usersCollection
                .document(uid)
                .collection("books")
                .document(widget.bookid)
                .collection("pages")
                .document(page.documentID)
                .collection("branches")
                .getDocuments();
            // var branchList = branchDocuments.documents;
            if (branchDocuments.documents.length == 0) {
              print("This page has no branches");
            }

            final List<Branch> branches = [
              // Init 3 branches that are used in editing pages
              Branch(null, null, null),
              Branch(null, null, null),
              Branch(null, null, null),
            ];

            for (int i = 0; i < branchDocuments.documents.length; i++) {
              branches[i].id = branchDocuments.documents[i].documentID;
              branches[i].number = branchDocuments.documents[i]["branchNumber"];
              branches[i].text = branchDocuments.documents[i]["branchText"];
              branches[i].pageID = branchDocuments.documents[i]["branchPageReference"];
            }

            final newPage = new Page(
                book: widget.book,
                choices: branches,
                initial: page["initial"],
                lastUpdated: page["pageLastUpdated"].toDate(),
                text: page["pageText"],
                title: page["pageTitle"]); // Init new page needed for the EditPage screen


            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditPage(
                          editedBook: widget.book,
                          editedPage: newPage,
                          editedBranch: branches,
                          branchesLength: branchDocuments.documents.length,
                        )));
          },
        ),
      ],
    );
  }

  Widget buildOtherPages(BuildContext context, DocumentSnapshot page) {
    return InkWell(
      child: ListTile(
        title: Text(page['pageTitle']),
        subtitle: Text(
            "Last updated: " + page['pageLastUpdated'].toDate().toString()),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.edit),
        ),
      ),
      onTap: () async {
        final uid = await Provider.of(context).auth.getUID();
        DatabaseService database = DatabaseService(uid: uid);
        // Get a snapshot of the branches related to the page
        QuerySnapshot branchDocuments = await database.usersCollection
            .document(uid)
            .collection("books")
            .document(widget.bookid)
            .collection("pages")
            .document(page.documentID)
            .collection("branches")
            .getDocuments();
        if (branchDocuments.documents.length == 0) {
          print("This page has no branches");
        }
            final List<Branch> branches = [
              // Init 3 branches that are used in editing pages
              Branch(null, null, null),
              Branch(null, null, null),
              Branch(null, null, null),
            ];

            for (int i = 0; i < branchDocuments.documents.length; i++) {
              branches[i].id = branchDocuments.documents[i].documentID;
              branches[i].number = branchDocuments.documents[i]["branchNumber"];
              branches[i].text = branchDocuments.documents[i]["branchText"];
              branches[i].pageID = branchDocuments.documents[i]["branchPageReference"];
              branches[i].pageTitle = branchDocuments.documents[i]['branchPageTitle'];
            }

            final newPage = new Page(
                book: widget.book,
                choices: branches,
                initial: page["initial"],
                lastUpdated: page["pageLastUpdated"].toDate(),
                text: page["pageText"],
                title: page["pageTitle"]); // Init new page needed for the EditPage screen


            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditPage(
                          editedBook: widget.book,
                          editedPage: newPage,
                          editedBranch: branches,
                          branchesLength: branchDocuments.documents.length,
                        )));
      },
    );
  }

  // Returns all pages of the particular book
  Stream<QuerySnapshot> getPages() async* {}

  Widget buildBookDetails(BuildContext context, DocumentSnapshot book) {
    return new Container(
      child: Card(
          child: Column(
        children: <Widget>[
          Text(book['bookTitle']),
          Text(book['bookDescription']),
          Text(book['bookCreationDate'].toDate()),
          Text(book['bookTitle']),
        ],
      )),
    );
  }

  Stream<DocumentSnapshot> getBookDetails(
      BuildContext context, String bookid) async* {
    final uid = await Provider.of(context).auth.getUID();
    DatabaseService database = DatabaseService(uid: uid);
    yield* database.usersCollection
        .document(uid)
        .collection("books")
        .document(bookid)
        .snapshots();
  }
}

/*
Flexible(
            child: StreamBuilder(
              stream: getBookDetails(context, widget.bookid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                } else {
                  Future.delayed(const Duration(milliseconds: 100), () {
                    // Delay to ensure widget is built after streambuilder
                    if (mounted) {
                      // Avoids setState being called when widget is not mounted
                      setState(() {
                        _empty = false;
                      });
                    }
                  });
                  return SingleChildScrollView(
                                      child: new Column(
                      children: <Widget>[
                        InkWell(
                          child: Text(
                              "dsa"), // child: Text(snapshot.data['bookTitle']),
                          onTap: () {
                            print("Pressed");
                          },
                        ),
                        InkWell(
                          child: Text(snapshot.data['bookDescription']),
                          onTap: () {
                            print("Pressed");
                          },
                        ),
                        InkWell(
                          child: Text(snapshot.data['bookGenre']),
                          onTap: () {
                            print("Pressed");
                          },
                        ),
                        InkWell(
                          child: Checkbox(
                            value: snapshot.data['isComplete'],
                            onChanged: (bool val) {
                              snapshot.data['isComplete'] = val;
                            },
                          ),
                          onTap: () {
                            print("Pressed");
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ), */
