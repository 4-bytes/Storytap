// Packages
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:storytap/screens/authenticate/authenticate.dart';
import 'package:storytap/screens/manage/edit/edit_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
// Services
import 'package:storytap/services/database.dart';
import 'package:storytap/shared/loading.dart';
import 'package:storytap/services/storage.dart';
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
  TextEditingController editController =
      new TextEditingController(); // For user input in fields

  File
      _bookCoverHolder; // Holds the bookCover's data while it is being preprocessed
  File _bookCover; // Displays the bookCover on the widget
  // For checking whether a book is completed or not
  bool _checkboxSelected;

  // For selecting a genre from a list of options
  String _genreSelected = "Classic";
  List<String> _genresList = <String>[
    "Classic",
    "Fantasy",
    "Historical",
    "Mystery",
    "Thriller",
    "Western",
    "Biography",
    "Essay",
    "Journalism",
    "History",
    "Reference",
    "Speech",
    "Textbook"
  ];

  @override
  void dispose() {
    super.dispose();
  }

  // Uploads book cover from the user's device
  Future uploadBookCover(String bookid) async {
    try {
      var image = await ImagePicker.pickImage(
          source: ImageSource.gallery,
          maxHeight: 300,
          maxWidth: 150); // Use the gallery to pick an image from
      setState(() {
        _bookCoverHolder = image;
        print('Image path : $_bookCoverHolder');
      });
      // print('Original path: ${_bookCoverHolder.path}');

      String dir = path.dirname(
          _bookCoverHolder.path); // Gets the path before the last separator
      print(dir);
      String newPath =
          path.join(dir, "$bookid.png"); // Add the book ID as path.
      print("New path: " + newPath);
      //print(newPath);
      _bookCoverHolder = await moveFile(_bookCoverHolder, newPath);

      print("PATH is now $_bookCoverHolder");
    } catch (error) {
      print(error);
    }
  }

  // Function that renames file path safely
  Future<File> moveFile(File sourceFile, String newPath) async {
    try {
      // Using rename as it is probably faster
      return await sourceFile.rename(newPath);
    } on FileSystemException catch (error) {
      print(error);
      // if rename fails, copy the source file and then delete it
      final newFile = await sourceFile.copy(newPath);
      await sourceFile.delete();
      return newFile;
    }
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
            child: StreamBuilder(
              stream: getBookDetails(context, widget.bookid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                } else {
                  return SingleChildScrollView(
                    child: new Column(
                      children: <Widget>[
                        Container(
                          child: ListTile(
                            leading: Icon(
                              Icons.settings_applications,
                              color: Colors.white,
                            ),
                            title: Text(
                              "Book Details: ",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          color: primaryThemeColor,
                        ),
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
                            displayEditPrompt(context, "Book Title",
                                snapshot.data['bookTitle']);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 12, top: 6, bottom: 0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Book Cover: ",
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
                          child: Column(
                            children: <Widget>[
                              FutureBuilder(
                                // Displays book cover
                                future: _getBookCover(
                                    context, snapshot.data['bookCover']),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    if (snapshot.hasData) {
                                      return SizedBox(
                                        // Retrieves the snapshot.data of the bookCover from firebase storage
                                        height: 150,
                                        width: 200,
                                        child: snapshot.data,
                                      );
                                    } else {
                                      return SizedBox(
                                        // Alternative way of displaying the current uploaded image without rebuilding entire widget
                                        height: 150,
                                        width: 200,
                                        child: Image.file(_bookCover),
                                      );
                                    }
                                  } else {
                                    return CircularProgressIndicator();
                                  }
                                },
                              ),
                              FlatButton(
                                child: Text(
                                  "Change",
                                  style: TextStyle(color: Colors.white),
                                ),
                                color: primaryThemeColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40.0),
                                ),
                                onPressed: () {
                                  print("Pressed");

                                  displayEditPrompt(
                                      context, "Book Cover", null);
                                },
                              )
                            ],
                          ),
                          onTap: () {
                            print("Pressed");
                            displayEditPrompt(context, "Book Title",
                                snapshot.data['bookTitle']);
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
                            displayEditPrompt(context, "Book Description",
                                snapshot.data['bookDescription']);
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
                            setState(() {
                              _genreSelected = snapshot.data['bookGenre'];
                            });
                            displayEditPrompt(context, "Book Genre",
                                snapshot.data['bookGenre']);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 12, top: 6, bottom: 0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Book Completed:",
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
                            title: Text(snapshot.data['isComplete']
                                ? "Completed"
                                : "Not Completed"),
                            subtitle: Text("Click here to edit"),
                            leading: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.edit),
                            ),
                          ),
                          onTap: () {
                            print("Pressed");
                            setState(() {
                              _checkboxSelected = snapshot.data['isComplete'];
                            });
                            displayEditPrompt(context, "Book Completed",
                                _checkboxSelected.toString());
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
                                "Additional pages:",
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
                                  physics:
                                      const NeverScrollableScrollPhysics(), // Disable StreamBuilder's built in ScrollableScrollPhysics
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

  // Streams the book's details
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

  // Fetches the user's book image from firebase storage
  Future<Widget> _getBookCover(BuildContext context, String bookCover) async {
    Image image;
    // StorageService storage = StorageService(id: uid);
    // final pr = await Provider.of(context).auth.getUserPhotoURL();
    // print("Photo above");
    await StorageService.loadBookCover(context, bookCover).then((downloadUrl) {
      // Load the image from storage
      // print(downloadUrl.toString());
      image = Image.network(
        downloadUrl.toString(),
        height: 300,
        width: 150,
      );
    });

    return image;
  }

  Widget buildInitialPage(BuildContext context, DocumentSnapshot page) {
    return Column(
      children: <Widget>[
        Container(
          child: ListTile(
            leading: Icon(
              Icons.library_books,
              color: Colors.white,
            ),
            title: Text(
              "List of pages: ",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          color: primaryThemeColor,
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
            if (branchDocuments.documents.length == 0) {}

            final List<Branch> branches = [
              // Init 3 branches that are used in editing pages
              Branch(null, null, null),
              Branch(null, null, null),
              Branch(null, null, null),
            ];

            // Loops through the page's branch documents and retrieve them 
            for (int i = 0; i < branchDocuments.documents.length; i++) {
              branches[i].id = branchDocuments.documents[i].documentID;
              branches[i].number = branchDocuments.documents[i]["branchNumber"];
              branches[i].text = branchDocuments.documents[i]["branchText"];
              branches[i].pageID =
                  branchDocuments.documents[i]["branchPageReference"];
              branches[i].pageTitle =
                  branchDocuments.documents[i]['branchPageTitle'];
            }

            final newPage = new Page(
                id: page.documentID,
                book: widget.book,
                choices: branches,
                initial: page["initial"],
                lastUpdated: page["pageLastUpdated"].toDate(),
                text: page["pageText"],
                title: page[
                    "pageTitle"]); // Init new page needed for the EditPage screen

            // Navigate to the EditPage
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
        if (branchDocuments.documents.length == 0) {}
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
          branches[i].pageID =
              branchDocuments.documents[i]["branchPageReference"];
          branches[i].pageTitle =
              branchDocuments.documents[i]['branchPageTitle'];
        }

        final newPage = new Page(
            id: page.documentID,
            book: widget.book,
            choices: branches,
            initial: page["initial"],
            lastUpdated: page["pageLastUpdated"].toDate(),
            text: page["pageText"],
            title: page[
                "pageTitle"]); // Init new page needed for the EditPage screen

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

  // Displays the corresponding prompt based on the selected field
  void displayEditPrompt(BuildContext context, String title, String data) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            // Using StatefulBuilder to keep states
            if (title == "Book Title") {
              // Checks what value was pressed
              editController.text = data;
              return AlertDialog(
                title: Text("Edit " + title),
                content: TextField(
                  autofocus: true,
                  controller: editController,
                  maxLength: 15,
                ),
                actions: <Widget>[
                  FlatButton(
                    color: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  FlatButton(
                    color: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      final uid = await Provider.of(context).auth.getUID();
                      final database = DatabaseService(uid: uid);
                      data = editController.text;
                      await database.updateBookTitle(uid, widget.bookid, data);
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            } else if (title == "Book Description") {
              editController.text = data;
              return AlertDialog(
                title: Text("Edit " + title),
                content: TextField(
                  autofocus: true,
                  controller: editController,
                  maxLength: 150,
                  maxLines: 5,
                ),
                actions: <Widget>[
                  FlatButton(
                    color: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Dismisses the alert dialogue
                    },
                  ),
                  FlatButton(
                    color: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      final uid = await Provider.of(context).auth.getUID();
                      final database = DatabaseService(uid: uid);
                      data = editController.text;
                      database.updateBookDescription(uid, widget.bookid, data);
                    },
                  ),
                ],
              );
            } else if (title == "Book Genre") {
              return AlertDialog(
                title: Text("Edit " + title),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Genre list: "),
                    DropdownButton(
                      items: _genresList
                          .map((value) => DropdownMenuItem(
                                child: Text(
                                  value,
                                ),
                                value: value,
                              ))
                          .toList(),
                      onChanged: (selectedGenre) {
                        setState(() {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          _genreSelected = selectedGenre;
                        });
                      },
                      value: _genreSelected,
                      isExpanded: false,
                    ),
                  ],
                ),
                actions: <Widget>[
                  FlatButton(
                    color: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Dismisses the alert dialogue
                    },
                  ),
                  FlatButton(
                    color: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      final uid = await Provider.of(context).auth.getUID();
                      final database = DatabaseService(uid: uid);
                      data = _genreSelected;
                      database.updateBookGenre(uid, widget.bookid, data);
                      Navigator.pop(context); // Dismisses the alert dialogue
                    },
                  ),
                ],
              );
            } else if (title == "Book Completed") {
              return AlertDialog(
                title: Text("Edit " + title),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Is the book completed?"),
                    Checkbox(
                      value: _checkboxSelected,
                      onChanged: (val) {
                        setState(() {
                          _checkboxSelected = val;
                        });
                      },
                    ),
                  ],
                ),
                actions: <Widget>[
                  FlatButton(
                    color: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Dismisses the alert dialogue
                    },
                  ),
                  FlatButton(
                    color: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      final uid = await Provider.of(context).auth.getUID();
                      final database = DatabaseService(uid: uid);
                      print(_checkboxSelected);
                      database.updateBookComplete(
                          uid, widget.bookid, _checkboxSelected);
                      Navigator.pop(context); // Dismisses the alert dialogue
                    },
                  ),
                ],
              );
            } else if (title == "Book Cover") {
              return AlertDialog(
                title: Text("Edit " + title),
                content: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                          child: _bookCoverHolder != null
                              ? Image.file(_bookCover)
                              : null),
                      FlatButton(
                        color: primaryThemeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        child: Text(
                          "Upload an image",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          await uploadBookCover(widget.bookid);
                          setState(() {
                            _bookCover = _bookCoverHolder;
                          });
                          // Dismisses the alert dialogue
                        },
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    color: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Dismisses the alert dialogue
                    },
                  ),
                  FlatButton(
                    color: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      String fileName = path.basename(_bookCover
                          .path); // Shortern the path to only the bookid
                      final uid = await Provider.of(context)
                          .auth
                          .getUID(); // Get the current user's uid
                      final database = DatabaseService(uid: uid);
                      database.updateBookCover(uid, widget.bookid,
                          fileName); // Update the book cover in database with new file
                      await StorageService.uploadBookCover(context, fileName,
                          _bookCover); // Upload cover to storage

                      Navigator.pop(context); // Dismisses the alert dialogue
                    },
                  ),
                ],
              );
            }
            return Container();
          });
        });
  }

  // Returns all pages of the particular book
  Stream<QuerySnapshot> getPages() async* {}

  // Unused
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
