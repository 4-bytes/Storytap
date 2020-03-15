// Packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Services
import 'package:storytap/services/auth.dart';
import 'package:storytap/services/database.dart';
// Shared
import 'package:storytap/shared/provider.dart';
import 'package:storytap/shared/loading.dart';
// Screens
import 'package:storytap/screens/authenticate/authenticate.dart';
// Models
import 'package:storytap/models/book.dart';

// *** 
// Displays books from the "books" collection stored in firestore.

class Browse extends StatefulWidget {
  @override
  _BrowseState createState() => _BrowseState();
}

class _BrowseState extends State<Browse> {

  List booksList = [];

  @override
  void initState() {
    super.initState();
    getAllBooks(context);
  }

  @override
 Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    // final uid = Provider.of(context).auth.getUID();
    return Container(
      margin: EdgeInsets.only(top: _height * 0.025),
      height: _height,
      width: _width,
      child:new ListView.builder(
                itemCount: booksList.length,
                itemBuilder: (BuildContext context, int index) =>
                    buildBookCards(context, index)
                    ),
    );
    
  }

  createBooksList(QuerySnapshot snapshot) async {
      var docs = snapshot.documents;
      for (var doc in docs){
        booksList.add(Book.fromFirestore(doc));
      }
    }


  getAllBooks(BuildContext context) async* {
    final uid = await Provider.of(context).auth.getUID();
    DatabaseService database = DatabaseService(uid: uid);
    List usersList = await database.usersCollection
        .getDocuments()
        .then((val) => val.documents);
    // usersList.elementAt(i).documentID.toString().collection("books"));

    for (int i = 0; i < usersList.length; i++) {
      database.usersCollection.document(usersList[i].documentID.toString()).collection("books").snapshots().listen(createBooksList);
      print(usersList[i].documentID);
    }
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
  
  Widget buildBookCards(BuildContext context, int index) {
    return new Container(
      padding: EdgeInsets.all(16.0),
      child: Card(
        color: Colors.blueGrey[300],
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
                          booksList[index].title.toString(),
                          style: TextStyle(fontSize: 24),
                        ),
                        Spacer(),
                        isCompleteIcon(booksList[index].isComplete), 
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Row(
                      children: <Widget>[
                        Text("Created: " +
                            "${DateFormat('dd/MM/yyyy').format(booksList[index].creationDate).toString()}"),
                        Spacer(),
                        Text("Genre: " + booksList[index].genre),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: Text(
                          booksList[index].description,
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
      ),
    );
  }
}

