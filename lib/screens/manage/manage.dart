// Packages
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Services
import 'package:storytap/services/auth.dart';
import 'package:storytap/services/database.dart';
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
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    final uid = Provider.of(context).auth.getUID();
    return Column(
      children: <Widget>[
        Text(""),
        Text("A list of books that have been created by you."),
        Flexible(
          child: StreamBuilder(
            stream: getUserBooks(context),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              } else {
                return new ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (BuildContext context, int index) =>
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
    DatabaseService database = DatabaseService(uid: uid);
    yield* database.usersCollection
        .document(uid)
        .collection("books")
        .orderBy('bookLastUpdated', descending: true)
        .snapshots();
  }

  Icon isCompleteIcon(bool isComplete) {
    if (isComplete == true) {
      return Icon(
        Icons.check_circle_outline,
        color: Colors.green,
      );
    } else {
      return Icon(
        Icons.highlight_off,
        color: Colors.red,
      );
    }
  }

  Widget buildBookCard(BuildContext context, DocumentSnapshot book) {
    return new Container(
      padding: EdgeInsets.all(16.0),
      child: Card(
        color: Colors.blueGrey[300],
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      child: Image.network(
                        "https://d1csarkz8obe9u.cloudfront.net/posterpreviews/vintage-book-cover-template-design-fe1040a9952994208fcae6066ab78f2b_screen.jpg?ts=1561553736",
                        height: 300,
                        width: 150,
                      ),
                    )
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
                            book['bookTitle'],
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => EditBook(bookid: book.documentID)));
          },
        ),
      ),
    );
  }
}
