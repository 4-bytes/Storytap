// Packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Services
import 'package:storytap/services/auth.dart';
import 'package:storytap/services/database.dart';
import 'package:storytap/services/storage.dart';
// Shared
import 'package:storytap/shared/provider.dart';
import 'package:storytap/shared/loading.dart';
// Screens
import 'package:storytap/screens/authenticate/authenticate.dart';
import 'package:storytap/screens/reader/reader.dart';
// Models
import 'package:storytap/models/book.dart';
import 'package:storytap/models/page.dart';
import 'package:storytap/models/branch.dart';

// ***
// Displays books from the "books" collection stored in firestore.

class Browse extends StatefulWidget {
  @override
  _BrowseState createState() => _BrowseState();
}

class _BrowseState extends State<Browse> {
  List _genreList = [
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

  List _sorting = [
    "Newest First",
    "Oldest First",
    "Book Title (A to Z)",
    "Book Title (Z to A)"
  ];

  String _selectedGenre = "Classic";
  String _selectedSorting = "Newest First";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    // final uid = Provider.of(context).auth.getUID();
    return Container(
      child: Column(
        children: <Widget>[
          Text(""),
          Text(
            "Books created by writers will be displayed here.",
            style: TextStyle(fontSize: 16),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Spacer(),
              Text(
                "Genre:",
                style: TextStyle(fontSize: 16),
              ),
              DropdownButton(
                items: _genreList
                    .map((value) => DropdownMenuItem(
                          child: Text(
                            value,
                          ),
                          value: value,
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    _selectedGenre = val;
                  });
                },
                value: _selectedGenre,
                isExpanded: false,
              ),
              Spacer(),
              Text(
                "Sort By: ",
                style: TextStyle(fontSize: 16),
              ),
              DropdownButton(
                items: _sorting
                    .map((value) => DropdownMenuItem(
                          child: Text(
                            value,
                          ),
                          value: value,
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    _selectedSorting = val;
                  });
                },
                value: _selectedSorting,
                isExpanded: false,
              ),
              Spacer(),
            ],
          ),
          Row(
            children: <Widget>[],
          ),
          Flexible(
            child: StreamBuilder(
              stream: getBooks(context), // Streams the list of created books
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  // Checks if the snapshot is not null
                  return const CircularProgressIndicator(); // Display loading indicator until data is retrieved
                } else {
                  return new ListView.builder(
                      // Build a book card that displays details of a created book
                      itemCount: snapshot.data.documents
                          .length, // Length of documents in the snapshot
                      itemBuilder: (BuildContext context,
                              int index) => // Builds book card based on length
                          buildBookCard(
                              context, snapshot.data.documents[index]));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Streams snapshot of books based on the values set in dropdowns
  Stream<QuerySnapshot> getBooks(BuildContext context) async* {
    final uid = await Provider.of(context).auth.getUID();
    DatabaseService database = DatabaseService(
        uid:
            uid); // Init database and retrieve a stream of snapshots from books, oredered by update

    if (_selectedSorting == "Newest First") {
      yield* database.booksCollection
          .where('bookGenre', isEqualTo: _selectedGenre)
          .orderBy('bookLastUpdated', descending: true)
          .snapshots();
    } else if (_selectedSorting == "Oldest First") {
      yield* database.booksCollection
          .where('bookGenre', isEqualTo: _selectedGenre)
          .orderBy('bookLastUpdated', descending: false)
          .snapshots();
    } else if (_selectedSorting == "Book Title (A to Z)") {
      yield* database.booksCollection
          .where('bookGenre', isEqualTo: _selectedGenre)
          .orderBy('bookTitle', descending: true)
          .snapshots();
    } else {
      yield* database.booksCollection
          .where('bookGenre', isEqualTo: _selectedGenre)
          .orderBy('bookLastUpdated', descending: false)
          .snapshots();
    }
  }

  // Displays the icon if the book is completed or not
  Row isCompleteIcon(bool isComplete) {
    if (isComplete == true) {
      return Row(
        children: <Widget>[
          Text("Complete",
              style: TextStyle(
                  color: Colors.green[900], fontWeight: FontWeight.bold)),
          Icon(
            Icons.check_circle_outline,
            color: Colors.green[900],
          ),
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          Text(
            "Incomplete",
            style:
                TextStyle(color: Colors.red[900], fontWeight: FontWeight.bold),
          ),
          Icon(
            Icons.highlight_off,
            color: Colors.red[900],
          ),
        ],
      );
    }
  }

  // Gets the book cover from storage
  Future<Widget> _getBookCover(BuildContext context, String bookCover) async {
    Image image;
    // StorageService storage = StorageService(id: uid);
    // final pr = await Provider.of(context).auth.getUserPhotoURL();
    // print("Photo above");
    await StorageService.loadBookCover(context, bookCover).then((downloadUrl) {
      // print(downloadUrl.toString());
      image = Image.network(
        downloadUrl.toString(),
        height: 300,
        width: 150,
      );
    });
    return image;
  }

  Widget buildBookCard(BuildContext context, DocumentSnapshot book) {
    final createdBook = new Book.fromSnapshot(book);
    return new Container(
      padding: EdgeInsets.all(16.0),
      child: Card(
        color: Colors.blueGrey[100],
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Row(children: <Widget>[]),
                Column(
                  children: <Widget>[
                    FutureBuilder(
                      // Displays book cover
                      future: _getBookCover(context, createdBook.cover),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData) {
                            return SizedBox(
                              // Retrieves the snapshot.data of the bookCover from firebase storage
                              height: 150,
                              width: 200,
                              child: snapshot.data,
                            );
                          } else {
                            return SizedBox(
                              //Displays if there's an error or fails to load
                              height: 150,
                              width: 200,
                              child: CircularProgressIndicator(),
                            );
                          }
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Row(
                        children: <Widget>[
                          Text(
                            createdBook.title,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Spacer(),
                          isCompleteIcon(book['isComplete']),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Row(
                        children: <Widget>[
                          Text("By: "),
                          Text(
                            "${book['username']}",
                            style: TextStyle(
                                color: Colors.blue[900],
                                fontWeight: FontWeight.bold),
                          ),
                          Spacer(),
                          Text("Created: " +
                              "${DateFormat('dd/MM/yyyy').format(book['bookCreationDate'].toDate()).toString()}"),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Row(
                        children: <Widget>[
                          Text("Last Updated: " +
                              "${DateFormat('dd/MM/yyyy').format(book['bookLastUpdated'].toDate()).toString()}"),
                          Spacer(),
                          Text("Genre: " + book['bookGenre']),
                        ],
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: Text(
                            book['bookDescription'],
                            maxLines: 5,
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          onTap: () {
            print(book['bookTitle']);
            print(book.documentID);
            print(book['author']);
            // Navigator.push(context,MaterialPageRoute(builder: (context) => Reader(book: createdBook, bookid: book.documentID)));
            displayPrompt(
                context, book['bookTitle'], book.documentID, book['author']);
          },
        ),
      ),
    );
  }

  // Displays a prompt asking if the user wants to read the selected book
  void displayPrompt(
      BuildContext context, String title, String bookid, String uid) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Read Book"),
            content: Text("Do you want to read " + title + "?"),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancel"),
                color: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                color: primaryThemeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: Text("Read"),
                onPressed: () async {
                  DatabaseService database = DatabaseService(uid: uid);
                  final page = await database.usersCollection
                      .document(uid)
                      .collection("books")
                      .document(bookid)
                      .collection("pages")
                      .where('initial', isEqualTo: true)
                      .getDocuments();
                  
                  final currentBook = new Book( // To track what book the user is currently reading
                    title: null,
                    author: null,
                    cover: null,
                    creationDate: null,
                    description: null,
                    genre: null,
                    id: null,
                    isComplete: null,
                    lastUpdated: null,
                  );

                  currentBook.id = bookid;
                  currentBook.title = title;

                  final initialPage = new Page(
                      // To create the initial page that will be first displayed when book is loaded
                      book: null,
                      choices: null,
                      initial: false,
                      lastUpdated: null,
                      text: null,
                      title: null);

                  final List<Branch> branches = [
                    // Init branches used to display transition from page to page
                    Branch(null, null, null),
                    Branch(null, null, null),
                    Branch(null, null, null),
                  ];

                  initialPage.book = currentBook;
                  initialPage.text = page.documents[0]['pageText'];
                  initialPage.lastUpdated =
                      page.documents[0]['pageLastUpdated'].toDate();
                  initialPage.id = page.documents[0].documentID;

                  final initialBranches = await database.usersCollection
                      .document(uid)
                      .collection("books")
                      .document(bookid)
                      .collection("pages")
                      .document(initialPage.id)
                      .collection("branches")
                      .getDocuments();

                  for (int i = 0; i < initialBranches.documents.length; i++) {
                    branches[i].text =
                        initialBranches.documents[i]['branchText'];
                    branches[i].pageID =
                        initialBranches.documents[i]['branchPageReference'];
                        
                  }
                  print("THE UID is " + uid);
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Reader(
                                currentBook: currentBook,
                                currentPage: initialPage,
                                currentBranch: branches,
                                branchesLength: initialBranches.documents.length,
                                uid: uid,
                              )));
                },
              ),
            ],
          );
        });
  }
}
