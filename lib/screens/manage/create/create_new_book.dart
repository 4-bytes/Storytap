// Packages
import 'package:flutter/material.dart';
// Screens
import 'package:storytap/screens/authenticate/authenticate.dart';
import 'package:storytap/screens/manage/create/create_new_page.dart';
// Models
import 'package:storytap/models/book.dart';
import 'package:storytap/models/page.dart';

// ***
// A form that creates a new book and navigates to create_new_page screen where additional page details are entered.

class CreateNewBook extends StatefulWidget {
  final Book book;

  CreateNewBook({Key key, @required this.book}) : super(key: key);

  @override
  _CreateNewBookState createState() => _CreateNewBookState();
}

class _CreateNewBookState extends State<CreateNewBook> {
  List<String> _genreSelect = <String>["Fiction", "Non-Fiction"];
  var _genreSelected = "Fiction";

  List<String> _subGenres1 = <String>[
    "Classic",
    "Detective",
    "Fantasy",
    "Historical",
    "Mystery",
    "Thriller",
    "Western"
  ];
  List<String> _subGenres2 = <String>[
    "Biography",
    "Essay",
    "Journalism",
    "History",
    "Reference",
    "Speech",
    "Textbook"
  ];
  var _subGenreSelected1 = "Classic";
  var _subGenreSelected2 = "Biography";
  var _finalSelected = "Classic";

  TextEditingController _bookTitleController = new TextEditingController();
  TextEditingController _bookDescriptionController =
      new TextEditingController();

  String _bookTitleErrorMessage;
  String _bookDescriptionErrorMessage;

  bool validateBookTitle(TextEditingController controller) {
    if (controller.text.isEmpty) {
      setState(() {
        _bookTitleErrorMessage = "Book title cannot be left empty";
      });
      return false;
    } else {
      return true;
    }
  }

  bool validateBookDescription(TextEditingController controller) {
    if (controller.text.isEmpty) {
      setState(() {
        _bookDescriptionErrorMessage = "Book description cannot be left empty";
      });
      return false;
    } else {
      return true;
    }
  }

  @override
  void initState() {
    _bookTitleController.text = widget.book.title;
    _bookDescriptionController.text = widget.book.description;
    super.initState();
  }

  // Returns if Fiction is selected
  Widget subGenres1List() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          "Select a sub-genre: ",
          style: TextStyle(fontSize: 16),
        ),
        DropdownButton(
          items: _subGenres1
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
              _subGenreSelected1 = selectedGenre;
              _finalSelected = selectedGenre;
            });
          },
          value: _subGenreSelected1,
          isExpanded: false,
        )
      ],
    );
  }

  // Returns if Non-Fiction is selected
  Widget subGenres2List() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          "Select a sub-genre: ",
          style: TextStyle(fontSize: 16),
        ),
        DropdownButton(
          items: _subGenres2
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
              _subGenreSelected2 = selectedGenre;
              _finalSelected = selectedGenre;
            });
          },
          value: _subGenreSelected2,
          isExpanded: false,
        )
      ],
    );
  }

  Widget checkSelected() {
    if (_genreSelected == "Fiction") {
      return subGenres1List();
    } else {
      return subGenres2List();
    }
  }

  @override
  Widget build(BuildContext context) {
    Page page = new Page(book: widget.book, text: "");
    print(_finalSelected);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondaryThemeColor,
        title: Text("Create Book"),
        actions: <Widget>[],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              // Text("Enter book title: "),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  // style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    errorText: _bookTitleErrorMessage,
                    labelText: "Enter Book Title",
                  ),
                  maxLength: 15,
                  controller: _bookTitleController,
                  autofocus: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  autofocus: false,
                  decoration: InputDecoration(
                    errorText: _bookDescriptionErrorMessage,
                    alignLabelWithHint: true,
                    labelText: "Enter Book Description",
                  ),
                  maxLength: 150,
                  maxLines: 5,
                  controller: _bookDescriptionController,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Select a genre: ",
                    style: TextStyle(fontSize: 16),
                  ),
                  DropdownButton(
                    items: _genreSelect
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
                        if (_genreSelected == "Fiction") {
                          _subGenreSelected1 = "Classic";
                          _finalSelected = "Classic";
                        } else {
                          _subGenreSelected2 = "Biography";
                          _finalSelected = "Biography";
                        }
                      });
                    },
                    value: _genreSelected,
                    isExpanded: false,
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              checkSelected(),
              SizedBox(
                height: 20,
              ),
              FlatButton(
                padding: const EdgeInsets.only(
                    top: 10, bottom: 10, left: 30, right: 30),
                color: secondaryThemeColor,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                child: Text("Continue"),
                onPressed: () {
                  if (validateBookTitle(_bookTitleController) && validateBookDescription(_bookDescriptionController)){
                  widget.book.title = _bookTitleController.text;
                  widget.book.description = _bookDescriptionController.text;
                  widget.book.genre = _finalSelected;
                  widget.book.creationDate = DateTime.now();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreateNewPage(
                                createdBook: widget.book,
                                createdPage: page,
                              )));
                  }
                  else {
                    print("Error");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
