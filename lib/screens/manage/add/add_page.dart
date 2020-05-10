// Packages
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:storytap/shared/provider.dart';
import 'package:zefyr/zefyr.dart';
import 'package:quill_delta/quill_delta.dart';
// Screens
import 'package:storytap/screens/authenticate/authenticate.dart';
// Models
import 'package:storytap/models/book.dart';
import 'package:storytap/models/page.dart';
import 'package:storytap/models/branch.dart';
// Services
import 'package:storytap/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ***
// Creates an initial page along with the created book and adds data in cloud firestore.

class AddPage extends StatefulWidget {
  final Book createdBook;
  final Page createdPage;
  final List<Branch> createdBranch;
  AddPage(
      {Key key,
      @required this.createdBook,
      @required this.createdPage,
      @required this.createdBranch})
      : super(key: key);
  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  TextEditingController _pageTitleController = new TextEditingController();
  ZefyrController _pageTextController;
  FocusNode _focusNode;

  int _branchIndex = 0;

  // Text controllers for each branch
  List<TextEditingController> _branchTextController = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  // Default message
  String _errorMessage = "A branch has not yet been added to this page";
  String _titleErrorMessage; // Displays error text below page title field
  String _zefyrErrorMessage; // Displays error text below page text
  String _branchErrorMessage = "";
  // Each branch with the page title that it is selected with
  String branch1PageSelector;
  String branch2PageSelector;
  String branch3PageSelector;

  // Tracks pageIDs which are used to link branches together
  String branch1pageID;
  String branch2pageID;
  String branch3pageID;

  // Called when widget is inserted into tree
  void initState() {
    super.initState();
    final document = _loadDocument(); // Load the document
    _pageTextController = ZefyrController(
        document); // Assign controller to ZefyrController(document)
    _focusNode = FocusNode();
  }

  void dispose() {
    _pageTextController.dispose();
    super.dispose();
  }

  NotusDocument _loadDocument() {
    final Delta delta = Delta()..insert("Tap here to begin writing...\n");
    return NotusDocument.fromDelta(delta);
  }

  void _clearDocument(ZefyrController controller) {
    try {
      controller.replaceText(
          0, controller.document.length - 1, 'Tap here to begin writing...\n');
    } catch (error) {
      print(error);
    }
  }

  void _clearTitle(TextEditingController pageTitle) {
    pageTitle.text = "";
  }

  // A stream of all pages snapshot
  Stream<QuerySnapshot> getPages(BuildContext context, String bookid) async* {
    final uid = await Provider.of(context).auth.getUID();
    DatabaseService database = DatabaseService(uid: uid);
    yield* database.usersCollection
        .document(uid)
        .collection("books")
        .document(bookid)
        .collection("pages")
        .snapshots();
  }

  // Validates the zefyrField, ensuring that the document limit is not reached
  bool zefyrFieldValidator(ZefyrController controller) {
    if (controller.document.toPlainText().isEmpty ||
        controller.document.length < 5) {
      setState(() {
        _zefyrErrorMessage =
            "The page text cannot be left empty or less than 5 characters in length.";
      });
      return false;
    } else if (controller.document.length > 600) {
      // Length of the page
      setState(() {
        _zefyrErrorMessage =
            "You have exceeded the max length for this document.";
      });
      return false;
    } else {
      return true;
    }
  }

  // Validates the pageTitle, ensuring that the field is not empty and limited
  bool pageTitleValidator(TextEditingController controller) {
    if (controller.text.isEmpty) {
      setState(() {
        _titleErrorMessage = "The page identifier cannot be left empty.";
      });
      return false;
    } else if (controller.text.length < 3 || controller.text.length > 15) {
      setState(() {
        _titleErrorMessage =
            "The page identifier must be 3 to 15 characters long.";
      });
      return false;
    } else {
      return true;
    }
  }

  // Validates first branch
  bool branchValidator1() {
    if (branch1PageSelector == null ||
        branch1pageID == null ||
        _branchTextController[0].text == "") {
      setState(() {
        _branchErrorMessage = "Branches cannot be left empty.";
      });
      return false;
    } else if (_branchTextController[0].text.length < 3 || _branchTextController[0].text.length > 15) {
      setState(() {
        _branchErrorMessage = "Branch Text must be 3 to 10 characters long.";
      });
      return false;
    } else {
      return true;
    }
  }

  // Validates second branch
  bool branchValidator2() {
    if (branch2PageSelector == null ||
        branch2PageSelector == null ||
        _branchTextController[1].text == "") {
      setState(() {
        _branchErrorMessage = "Branches cannot be left empty.";
      });
      return false;
    } else if (_branchTextController[1].text.length < 3 || _branchTextController[1].text.length > 15) {
      setState(() {
        _branchErrorMessage = "Branch Text must be 3 to 10 characters long.";
      });
      return false;
    } else {
      return true;
    }
  }

  // Validates third branch
  bool branchValidator3() {
    if (branch3PageSelector == null ||
        branch3PageSelector == null ||
        _branchTextController[2].text == "") {
      setState(() {
        _branchErrorMessage = "Branches cannot be left empty.";
      });
      return false;
    } else if (_branchTextController[2].text.length < 3 || _branchTextController[2].text.length > 15) {
      setState(() {
        _branchErrorMessage = "Branch Text must be 3 to 10 characters long.";
      });
      return false;
    } else {
      return true;
    }
  }
  // Create a branch based on the current branchIndex
  Widget createBranch1(BuildContext context, String bookid) {
    return Row(
      children: <Widget>[
        Flexible(
          child: TextField(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              labelText: "Branch Text:",
            ),
            controller: _branchTextController[0],
          ),
        ),
        Text(
          "AA",
          style: TextStyle(color: Colors.white),
        ),
        pageStream1(context, bookid),
      ],
    );
  }

  Widget createBranch2(BuildContext context, String bookid) {
    return Row(
      children: <Widget>[
        Flexible(
          child: TextField(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              labelText: "Branch Text:",
            ),
            controller: _branchTextController[1],
          ),
        ),
        Text(
          "AA",
          style: TextStyle(color: Colors.white),
        ),
        pageStream2(context, bookid)
      ],
    );
  }

  Widget createBranch3(BuildContext context, String bookid) {
    return Row(
      children: <Widget>[
        Flexible(
          child: TextField(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              labelText: "Branch Text:",
            ),
            controller: _branchTextController[2],
          ),
        ),
        Text(
          "AA",
          style: TextStyle(color: Colors.white),
        ),
        pageStream3(context, bookid),
      ],
    );
  }

  // pageStream widgets display a list of pages to the corresponding branch
  Widget pageStream1(BuildContext context, bookid) {
    return StreamBuilder<QuerySnapshot>(
        stream: getPages(context, bookid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          } else {
            Page page = new Page(book: widget.createdBook, text: "", id: "");
            List<String> pageID = [];
            List<String> pageTitle = [];
            List<DropdownMenuItem> pageList = [];
            for (int i = 0; i < snapshot.data.documents.length; i++) {
              pageID.add(snapshot.data.documents[i].documentID);
              pageTitle.add(snapshot.data.documents[i]['pageTitle']);
              pageList.add(DropdownMenuItem(
                child: Text(snapshot.data.documents[i]['pageTitle']),
                value: snapshot.data.documents[i]['pageTitle'],
              ));
            }
            return DropdownButton(
              hint: Text("Choose a Page"),
              items: pageList,
              onChanged: (value) {
                setState(() {
                  branch1PageSelector = value;
                });
                for (int i = 0; i < pageTitle.length; i++) {
                  if (branch1PageSelector == pageTitle[i]) {
                    print("Branch 1: " + pageID[i] + " is the page ID");
                    setState(() {
                      branch1pageID = pageID[i];
                    });
                  }
                }
              },
              value: branch1PageSelector,
            );
          }
        });
  }

  Widget pageStream2(BuildContext context, bookid) {
    return StreamBuilder<QuerySnapshot>(
        stream: getPages(context, bookid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          } else {
            Page page = new Page(book: widget.createdBook, text: "", id: "");
            List<String> pageID = [];
            List<String> pageTitle = [];
            List<DropdownMenuItem> pageList = [];
            for (int i = 0; i < snapshot.data.documents.length; i++) {
              pageID.add(snapshot.data.documents[i].documentID);
              pageTitle.add(snapshot.data.documents[i]['pageTitle']);
              pageList.add(DropdownMenuItem(
                child: Text(snapshot.data.documents[i]['pageTitle']),
                value: snapshot.data.documents[i]['pageTitle'],
              ));
            }
            return DropdownButton(
              hint: Text("Choose a Page"),
              items: pageList,
              onChanged: (value) {
                setState(() {
                  branch2PageSelector = value;
                });
                for (int i = 0; i < pageTitle.length; i++) {
                  if (branch2PageSelector == pageTitle[i]) {
                    print("Branch 2: " + pageID[i] + " is the page ID");
                    setState(() {
                      branch2pageID = pageID[i];
                    });
                  }
                }
              },
              value: branch2PageSelector,
            );
          }
        });
  }

  Widget pageStream3(BuildContext context, bookid) {
    return StreamBuilder<QuerySnapshot>(
        stream: getPages(context, bookid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          } else {
            Page page = new Page(book: widget.createdBook, text: "", id: "");
            List<String> pageID =
                []; // Keeps track of the pageID assigned to each page
            List<String> pageTitle = [];
            List<DropdownMenuItem> pageList =
                []; // The page title for each page is added to this list
            for (int i = 0; i < snapshot.data.documents.length; i++) {
              pageID.add(snapshot.data.documents[i].documentID);
              pageTitle.add(snapshot.data.documents[i]['pageTitle']);
              pageList.add(DropdownMenuItem(
                child: Text(snapshot.data.documents[i]['pageTitle']),
                value: snapshot.data.documents[i]['pageTitle'],
              ));
            }
            return DropdownButton(
              hint: Text("Choose a Page"),
              items: pageList,
              onChanged: (value) {
                setState(() {
                  branch3PageSelector = value;
                });
                for (int i = 0; i < pageTitle.length; i++) {
                  if (branch3PageSelector == pageTitle[i]) {
                    print("Branch 3: " + pageID[i] + " is the page ID");
                    setState(() {
                      branch3pageID = pageID[i];
                    });
                  }
                }
              },
              value: branch3PageSelector,
            );
          }
        });
  }

  // A widget that creates branches based on the current index
  Widget createBranch(BuildContext context, String bookid) {
    if (_branchIndex == 1) {
      return Column(
        // Displays a column with 1 branch
        children: <Widget>[
          SizedBox(height: 10,),
          createBranch1(context, bookid),
          Divider(),
        ],
      );
    } else if (_branchIndex == 2) {
      return Column(
        // Displays a column with 2 branches
        children: <Widget>[
          SizedBox(height: 10,),
          createBranch1(context, bookid),
          SizedBox(height: 10,),
          createBranch2(context, bookid),
          Divider(),
        ],
      );
    } else if (_branchIndex == 3) {
      return Column(
        // Displays a column with 3 branches
        children: <Widget>[
          SizedBox(height: 10,),
          createBranch1(context, bookid),
          SizedBox(height: 10,),
          createBranch2(context, bookid),
          SizedBox(height: 10,),
          createBranch3(context, bookid),
          Divider(),
        ],
      );
    } else
      // If no branches then display an empty widget
      return SizedBox.shrink();
  }

  Widget displayBtn() {
    return Column(
      children: <Widget>[
        Column(
          children: <Widget>[
            Text(_errorMessage),
            SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.add_circle,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: AutoSizeText(
                          "Add",
                          style: TextStyle(),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    if (_branchIndex < 3)
                      setState(() {
                        _errorMessage = "";
                        _branchIndex = _branchIndex + 1;
                        _branchErrorMessage = "";
                      });
                    else if (_branchIndex == 3) {
                      setState(() {
                        _errorMessage =
                            "You have added the maximum number of branches";
                      });
                    }
                  },
                ),
                Spacer(),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.remove_circle,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: AutoSizeText(
                          "Remove",
                          style: TextStyle(),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    if (_branchIndex > 0) {
                      setState(() {
                        _errorMessage = "";
                        _branchIndex = _branchIndex - 1;
                        _branchErrorMessage = "";
                      });
                    }
                    if (_branchIndex == 0) {
                      setState(() {
                        _errorMessage =
                            "A branch has not yet been added to this page";
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
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
                      errorText: _titleErrorMessage,
                      labelText: "Page Title:",
                      hintText:
                          "This is a page identifier that only you can see."),
                  maxLength: 15,
                  controller: _pageTitleController,
                  autofocus: true,
                ),
                ZefyrField(
                  decoration: InputDecoration(errorText: _zefyrErrorMessage),
                  autofocus: false,
                  height: _editorHeight * 0.75,
                  physics: ClampingScrollPhysics(),
                  controller: _pageTextController,
                  focusNode: _focusNode,
                ),
                Divider(),
                Text(
                  "Add a branch:",
                  style: TextStyle(fontSize: 16),
                ),
                createBranch(context, widget.createdBook.id),
                Text(
                  _branchErrorMessage,
                  style: TextStyle(color: Colors.red,),
                ),
                displayBtn(),
                FlatButton(
                  padding: const EdgeInsets.only(
                      top: 10, bottom: 10, left: 30, right: 30),
                  color: primaryThemeColor,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  child: Text(
                    "Add Page",
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: () async {
                    if (zefyrFieldValidator(_pageTextController) &&
                        pageTitleValidator(_pageTitleController)) {
                      print("Passed validation 1");
                      final uid = await Provider.of(context).auth.getUID();
                      final username =
                          await Provider.of(context).auth.getUsername();
                      final database = DatabaseService(uid: uid);
                      // Updating createdBook properties
                      widget.createdBook.lastUpdated = DateTime.now();
                      // Updating createdPage properties
                      widget.createdPage.title = _pageTitleController.text;
                      widget.createdPage.text = jsonEncode(_pageTextController
                          .document); // Converts values into JSON string
                      widget.createdPage.lastUpdated = DateTime.now();
                      widget.createdPage.initial = false;
                      // Setting up branches to the newly created page if it contains any and updating firestore database
                      if (_branchIndex == 0) {
                        // Create a new page without any branching
                        await database
                            .createPageDocument(widget.createdBook.id,
                                widget.createdBook, widget.createdPage)
                            .then((_) {
                          print(
                              "Updated Firestore with new page + no branches");
                          Navigator.pop(context);
                        });
                      } else if (_branchIndex == 1 && branchValidator1()) {
                        print("Passed validation 2");
                        // Create a new page with 1 branch
                        widget.createdBranch[0].text =
                            _branchTextController[0].text;
                        widget.createdBranch[0].number = 1;
                        widget.createdBranch[0].pageID = branch1pageID;
                        widget.createdBranch[0].pageTitle = branch1PageSelector;
                        // Create a new page and use the reference to create a new branch for that newly created page
                        DocumentReference createdPage =
                            await database.createPageDocument(
                                widget.createdBook.id,
                                widget.createdBook,
                                widget.createdPage);
                        widget.createdPage.id = createdPage
                            .documentID; // Assign documentID to the createdPage
                        // Create branches for the newly created page
                        for (int i = 0; i < _branchIndex; i++) {
                          // Loop through each branch and update Firestore
                          await database.createBranchDocument(
                              widget.createdBook.id,
                              widget.createdPage.id,
                              widget.createdBranch[i]);
                        }
                        print("Updated Firestore with new page + 1 branches");
                        Navigator.pop(context);
                        /*await database
                          .createBranchDocument(
                              widget.createdBook.id,
                              widget.createdPage.id,
                              widget.createdBook,
                              widget.createdPage,
                              widget.createdBranch)
                          .then((_) {
                        print("Updated Firestore with new page + 1 branch");
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      }); */
                      } else if (_branchIndex == 2 &&
                          branchValidator1() &&
                          branchValidator2()) {
                        // Create a new page with 2 branches
                        widget.createdBranch[0].text =
                            _branchTextController[0].text;
                        widget.createdBranch[0].number = 1;
                        widget.createdBranch[0].pageID = branch1pageID;
                        widget.createdBranch[0].pageTitle = branch1PageSelector;
                        widget.createdBranch[1].text =
                            _branchTextController[1].text;
                        widget.createdBranch[1].number = 2;
                        widget.createdBranch[1].pageID = branch2pageID;
                        widget.createdBranch[1].pageTitle = branch2PageSelector;
                        // Create a new page and use the reference to create a new branch for that newly created page
                        DocumentReference createdPage =
                            await database.createPageDocument(
                                widget.createdBook.id,
                                widget.createdBook,
                                widget.createdPage);
                        widget.createdPage.id = createdPage
                            .documentID; // Assign documentID to the createdPage
                        for (int i = 0; i < _branchIndex; i++) {
                          // Loop through each branch and update Firestore
                          await database.createBranchDocument(
                              widget.createdBook.id,
                              widget.createdPage.id,
                              widget.createdBranch[i]);
                        }
                        print("Updated Firestore with new page + 2 branches");
                        Navigator.pop(context);
                      } else if (_branchIndex == 3 &&
                          branchValidator1() &&
                          branchValidator2() &&
                          branchValidator3()) {
                        // Create a new page with 3 branches
                        widget.createdBranch[0].text =
                            _branchTextController[0].text;
                        widget.createdBranch[0].number = 1;
                        widget.createdBranch[0].pageID = branch1pageID;
                        widget.createdBranch[0].pageTitle = branch1PageSelector;
                        widget.createdBranch[1].text =
                            _branchTextController[1].text;
                        widget.createdBranch[1].number = 2;
                        widget.createdBranch[1].pageID = branch2pageID;
                        widget.createdBranch[1].pageTitle = branch2PageSelector;
                        widget.createdBranch[2].text =
                            _branchTextController[2].text;
                        widget.createdBranch[2].number = 3;
                        widget.createdBranch[2].pageID = branch3pageID;
                        widget.createdBranch[2].pageTitle = branch3PageSelector;
                        // Create a new page and use the reference to create a new branch for that newly created page
                        DocumentReference createdPage =
                            await database.createPageDocument(
                                widget.createdBook.id,
                                widget.createdBook,
                                widget.createdPage);
                        widget.createdPage.id = createdPage
                            .documentID; // Assign documentID to the createdPage

                        for (int i = 0; i < _branchIndex; i++) {
                          // Loop through each branch and update Firestore
                          await database.createBranchDocument(
                              widget.createdBook.id,
                              widget.createdPage.id,
                              widget.createdBranch[i]);
                        }
                        print("Updated Firestore with new page + 3 branches");
                        Navigator.pop(context);
                      }
                    } else {}
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
