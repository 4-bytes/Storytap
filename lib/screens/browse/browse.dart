// Dependencies
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Services
import 'package:storytap/services/auth.dart';
// Shared
import 'package:storytap/shared/provider.dart';
// Screens
import 'package:storytap/screens/authenticate/authenticate.dart';
// Models
import 'package:storytap/models/book.dart';




class Browse extends StatelessWidget {
  final List<Book> bookList = [
    Book(title: "Lorem Ipsum", cover: "Null", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi imperdiet lacus metus, a accumsan metus commodo vel. Pellentesque eu facilisis massa, nec iaculis ligula. Aenean scelerisque, dolor at malesuada commodo, erat leo ultricies leo.", genre: "Non-Fiction", creationDate: DateTime.now(), lastUpdated: DateTime.now(), isComplete: false),
    Book(title: "Book 2", cover: "Null", description: "sdjalkdjsadwi dsaidwin dsiajdkw.q ddjisak djwiqdklsa wjidqolksakdwijdqdjiwqo djiwqjidowqd dwiqodjwq qweds agre gfew fewfe wqewpowq idjwqi dwjqi dwqjio feqnoif qio fqjpif qjiwqp eoi", genre: "Fiction", creationDate: DateTime.now(), lastUpdated: DateTime.now(), isComplete: true),
    Book(title: "Book 3", cover: "Null", description: "sdjalkdjsadwi dsaidwin dsiajdkw.q ddjisak djwiqdklsa wjidqolksakdwijdqdjiwqo djiwqjidowqd dwiqodjwq qweds agre gfew fewfe wqewpowq idjwqi dwjqi dwqjio feqnoif qio fqjpif qjiwqp eoi", genre: "Fiction", creationDate: DateTime.now(), lastUpdated: DateTime.now(), isComplete: false),
  ];

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.only(top: _height * 0.025),
      height: _height,
      width: _width,
      child: new ListView.builder(
          itemCount: bookList.length,
          itemBuilder: (BuildContext context, int index) => buildBookCard(context, index)
    ),
    );
  }

  Icon isCompleteIcon(bool isComplete){
    if (isComplete == true){
      return Icon(Icons.check_circle_outline, color: Colors.green,);
    }
    else {
      return Icon(Icons.highlight_off, color: Colors.red,);
    }
  }

  Widget buildBookCard(BuildContext context, int index) {
    return new Container(
      padding: EdgeInsets.all(16.0),
      child: Card(
        color: Colors.blueGrey[300],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Column(children: <Widget>[
                Container(child: Image.network("https://d1csarkz8obe9u.cloudfront.net/posterpreviews/vintage-book-cover-template-design-fe1040a9952994208fcae6066ab78f2b_screen.jpg?ts=1561553736", height: 300, width: 150,),)
              ],),

              Column(
                children: <Widget>[
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Row(children: <Widget>[
                      // Image(image: NetworkImage("https://designshack.net/wp-content/uploads/placeholder-image.png"), width: 70, height: 300,),
                      Text(bookList[index].title, style: TextStyle(fontSize: 24),),
                      Spacer(),
                      isCompleteIcon(bookList[index].isComplete),
                    ],),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Row(children: <Widget>[
                      Text("Created: " + "${DateFormat('dd/MM/yyyy').format(bookList[index].creationDate).toString()}"),
                      Spacer(),
                      Text("Genre: " + bookList[index].genre),
                    ],),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Row(children: <Widget>[
                      Expanded(child: Text(bookList[index].description, maxLines: 5,)),
                    ],),
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
