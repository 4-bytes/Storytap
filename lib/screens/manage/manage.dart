// Packages
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:storytap/models/book.dart';
// Services
import 'package:storytap/services/auth.dart';
import 'package:storytap/services/database.dart';
import 'package:storytap/services/storage.dart';
// Shared
import 'package:storytap/shared/provider.dart';
// Screens
import 'package:storytap/screens/authenticate/authenticate.dart';
import 'package:storytap/screens/manage/edit/edit_book.dart';

// ***
// Displays the user's created books collection and contains buttons to other navigation functionalities.

class Manage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(""),
        Text("Books created by you will be displayed here."),
        Flexible(
          child: StreamBuilder(
            stream: getUserBooks(context), // Streams the list of created books
            builder: (context, snapshot) {
              if (!snapshot.hasData) { // Checks if the snapshot is not null
                return const CircularProgressIndicator(); // Display loading indicator until data is retrieved
              } else {
                return new ListView.builder( // Build a book card that displays details of a created book
                    itemCount: snapshot.data.documents.length, // Length of documents in the snapshot
                    itemBuilder: (BuildContext context, int index) => // Builds book card based on length
                        buildBookCard(context, snapshot.data.documents[index]));
              }
            },
          ),
        ),
      ],
    );
  }

  // Returns a stream of all books for the particular user ordered by last updated date
  Stream<QuerySnapshot> getUserBooks(BuildContext context) async* {
    final uid = await Provider.of(context).auth.getUID();
    DatabaseService database = DatabaseService(uid: uid); // Init database and retrieve a stream of snapshots from books, oredered by update
    yield* database.usersCollection
        .document(uid)
        .collection("books")
        .orderBy('bookLastUpdated', descending: true)
        .snapshots();
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

  // A delete prompt that is displayed to confirm if user wants to delete the selected book
  void deletePrompt(BuildContext context, String bookid) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Delete Book?"),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Text(
                      "All data including each page and its branches will be deleted."),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                color: primaryThemeColor,
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
                color: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: Text(
                  "Delete",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  final uid = await Provider.of(context).auth.getUID();
                  final database = DatabaseService(uid: uid);
                  database.deleteCreatedBook(uid, bookid);
                  print("Deleted");
                  Navigator.pop(context); // Dismisses the alert dialogue
                },
              ),
            ],
          );
        });
  }

  // Builds a widget that displays a card which contains information about a created book
  Widget buildBookCard(BuildContext context, DocumentSnapshot book) {
    final createdBook = new Book.fromSnapshot(book);
    return new Container(
      padding: EdgeInsets.all(16.0),
      child: Card(
        color: Colors.blueGrey[300],
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Row(children: <Widget>[
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.delete, size: 36,),
                    onPressed: () {
                      deletePrompt(context, createdBook.id);
                    },
                    alignment: Alignment.topRight,
                  ),
                ]),
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
                          // Image(image: NetworkImage("https://designshack.net/wp-content/uploads/placeholder-image.png"), width: 70, height: 300,),
                          Text(
                            createdBook.title,
                            style: TextStyle(fontSize: 24),
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
                          Text("Created: " +
                              "${DateFormat('dd/MM/yyyy').format(book['bookCreationDate'].toDate()).toString()}"),
                          Spacer(),
                          Text("Genre: " + book['bookGenre']),
                        ],
                      ),
                    ),
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
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        EditBook(book: createdBook, bookid: book.documentID)));
          },
        ),
      ),
    );
  }
}
