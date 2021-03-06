// Packages
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:storytap/screens/authenticate/authenticate.dart';
import 'package:storytap/shared/provider.dart';
import 'package:zefyr/zefyr.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Models
import 'package:storytap/models/book.dart';
import 'package:storytap/models/page.dart';
import 'package:storytap/models/branch.dart';
// Services
import 'package:storytap/services/database.dart';

// ***
// An edit form that is for pages, where branches can be added or existing ones can be removed.

class EditPage extends StatefulWidget {
  final Book editedBook;
  final Page editedPage;
  final List<Branch> editedBranch;
  final int branchesLength;

  EditPage(
      {Key key,
      this.editedBook,
      this.editedPage,
      this.editedBranch,
      this.branchesLength})
      : super(key: key); // Init constructor with values

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  int _branchIndex;
  TextEditingController _pageTitleController = new TextEditingController();
  ZefyrController _pageTextController;
  FocusNode _focusNode;

  List<TextEditingController> _branchTextController = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  // Default message
  String _errorMessage = "";

  // Each branch with the page that it is selected with
  String branch1PageSelector;
  String branch2PageSelector;
  String branch3PageSelector;

  // Tracks pageIDs which are used to link branches together
  String branch1pageID;
  String branch2pageID;
  String branch3pageID;

  String _branchErrorMessage = "";
  String _titleErrorMessage;
  String _zefyrErrorMessage;

  // Initial state when widget is inserted into tree
  void initState() {
    super.initState();
    final document = _loadDocument(); // Load the pageText
    
    setState(() {
      _branchIndex = widget.branchesLength; // Get the number of active branches
    });
    _pageTextController = ZefyrController(document);
    _pageTitleController.text =
        widget.editedPage.title; // Load the title from widget.editedTitle.title
    _focusNode = FocusNode();

    if (_branchIndex == 0) {
      setState(() {
        _errorMessage = "A branch has not yet been added to this page";
      });
    } else if (_branchIndex == 1) {
      _branchTextController[0].text = widget.editedBranch[0].text;
      setState(() {
        branch1PageSelector = widget.editedBranch[0].pageTitle;
        branch1pageID = widget.editedBranch[0].pageID;
      });
      print(_branchTextController[0].text);
      print(widget.editedBranch[0].pageTitle);
    } else if (_branchIndex == 2) {
      _branchTextController[0].text = widget.editedBranch[0].text;
      _branchTextController[1].text = widget.editedBranch[1].text;
      setState(() {
        branch1PageSelector = widget.editedBranch[0].pageTitle;
        branch2PageSelector = widget.editedBranch[1].pageTitle;
        branch1pageID = widget.editedBranch[0].pageID;
        branch2pageID = widget.editedBranch[1].pageID;
      });
    } else if (_branchIndex == 3) {
      _branchTextController[0].text = widget.editedBranch[0].text;
      _branchTextController[1].text = widget.editedBranch[1].text;
      _branchTextController[2].text = widget.editedBranch[2].text;
      setState(() {
        _errorMessage = "You have added the maximum number of branches";
        branch1PageSelector = widget.editedBranch[0].pageTitle;
        branch2PageSelector = widget.editedBranch[1].pageTitle;
        branch3PageSelector = widget.editedBranch[2].pageTitle;
        branch1pageID = widget.editedBranch[0].pageID;
        branch2pageID = widget.editedBranch[1].pageID;
        branch3pageID = widget.editedBranch[2].pageID;
      });
    }
  }

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

  // pageStream widgets display a list of pages to the corresponding branch
  Widget pageStream1(BuildContext context, bookid) {
    return StreamBuilder<QuerySnapshot>(
        stream: getPages(context, bookid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          } else {
            Page page = new Page(book: widget.editedBook, text: "", id: "");
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
            Page page = new Page(book: widget.editedBook, text: "", id: "");
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
            Page page = new Page(book: widget.editedBook, text: "", id: "");
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

  // Validates the zefyrField, ensuring that the document limit is not reached
  bool zefyrFieldValidator(ZefyrController controller) {
    if (controller.document.toPlainText().isEmpty) {
      setState(() {
        _zefyrErrorMessage = "The page text cannot be left empty.";
      });
      return false;
    } else if (controller.document.length > 400) {
      setState(() {
        _zefyrErrorMessage =
            "You have exceeded the max length for this document.";
      });
      return false;
    } else {
      return true;
    }
  }

  bool pageTitleValidator(TextEditingController controller) {
    if (controller.text.isEmpty) {
      setState(() {
        _titleErrorMessage = "The page identifier cannot be left empty.";
      });
      return false;
    } else if (controller.text.length < 3 || controller.text.length > 20) {
      setState(() {
        _titleErrorMessage =
            "The page identifier must be 3 to 20 characters long";
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
    } else if (_branchTextController[0].text.length < 3 ||
        _branchTextController[0].text.length > 15) {
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
    } else if (_branchTextController[1].text.length < 3 ||
        _branchTextController[1].text.length > 15) {
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
    } else if (_branchTextController[2].text.length < 3 ||
        _branchTextController[2].text.length > 15) {
      setState(() {
        _branchErrorMessage = "Branch Text must be 3 to 10 characters long.";
      });
      return false;
    } else {
      return true;
    }
  }

  void dispose() {
    _pageTextController.dispose();
    super.dispose();
  }

  NotusDocument _loadDocument() {
    // Parse the string and return the Json object from the widget that is holding the page's text
    NotusDocument pageText =
        NotusDocument.fromJson(jsonDecode(widget.editedPage.text));
    return pageText;
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
    setState(() {
      pageTitle.text = "";
    });
  }

  Widget createBranch(BuildContext context, String bookid) {
    if (_branchIndex == 1) {
      return Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          createBranch1(context, bookid),
          Divider(),
        ],
      );
    } else if (_branchIndex == 2) {
      return Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          createBranch1(context, bookid),
          SizedBox(
            height: 10,
          ),
          createBranch2(context, bookid),
          Divider(),
        ],
      );
    } else if (_branchIndex == 3) {
      return Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          createBranch1(context, bookid),
          SizedBox(
            height: 10,
          ),
          createBranch2(context, bookid),
          SizedBox(
            height: 10,
          ),
          createBranch3(context, bookid),
          Divider(),
        ],
      );
    } else
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

  Widget displayDeleteIcon() {
    if (widget.editedPage.initial == true) {
      return Visibility(
        child: Icon(Icons.ac_unit),
        visible: false,
      );
    } else {
      return IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          showPrompt(context, "Delete");
        },
      );
    }
  }

  void showPrompt(BuildContext context, String title) {
    // Prompt that is displayed based on what icon button is pressed
    showDialog(
        context: context,
        builder: (BuildContext context) {
          if (title == "Reset") {
            return AlertDialog(
              title: Text("Erase data?"),
              content: Text("Do you want to erase all data on this page?"),
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
                    "Confirm",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    _clearTitle(_pageTitleController);
                    _clearDocument(_pageTextController);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          } 
          else {
            return AlertDialog(
              title: Text("Delete this page?"),
              content: Text(
                  "This will delete all information including all branches."),
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
                    "Confirm",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    Navigator.pop(
                        context); // Pop twice to return back to editBook screen, safer to pop first before deleting page
                    final uid = await Provider.of(context).auth.getUID();
                    final database = DatabaseService(uid: uid);
                    await database.deleteBranch(
                        uid, widget.editedBook.id, widget.editedPage.id);
                    await database.deleteSinglePage(
                        uid, widget.editedBook.id, widget.editedPage.id);
                    await database.deleteBrokenBranches(
                        uid, widget.editedBook.id, widget.editedPage.id);
                  },
                ),
              ],
            );
          }
        });
  }



  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _editorHeight = _height * 0.65;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: <Widget>[
          // IconButton(icon: Icon(Icons.restore_page),onPressed: () { showPrompt(context, "Reset");},),
          displayDeleteIcon(),
        ],
        backgroundColor: primaryThemeColor,
        title: Text("Edit " + widget.editedPage.title),
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
                  height: _editorHeight,
                  physics: ClampingScrollPhysics(),
                  controller: _pageTextController,
                  focusNode: _focusNode,
                ),
                Divider(),
                Text(
                  "Add a branch:",
                  style: TextStyle(fontSize: 16),
                ),
                createBranch(context, widget.editedBook.id),
                Text(
                  _branchErrorMessage,
                  style: TextStyle(color: Colors.red),
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
                    "Save",
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: () async {
                    if (zefyrFieldValidator(_pageTextController) &&
                        pageTitleValidator(_pageTitleController)) {
                      final uid = await Provider.of(context).auth.getUID();
                      final username =
                          await Provider.of(context).auth.getUsername();
                      final database = DatabaseService(uid: uid);
                      // Updating createdBook properties
                      widget.editedBook.lastUpdated = DateTime.now();
                      widget.editedBook.author = username;
                      // Updating createdPage properties
                      widget.editedPage.title = _pageTitleController.text;
                      widget.editedPage.text = jsonEncode(_pageTextController
                          .document); // Converts values into JSON string
                      widget.editedPage.lastUpdated = DateTime.now();
                      // Creates a subcollection under the "users" and creates a new collection "books" too
                      // print(_branchIndex.toString() + " IS BRANCH");
                      if (_branchIndex == 0) {
                        // Delete all existing branches and don't add any branches
                        database.deleteBranch(
                            uid, widget.editedBook.id, widget.editedPage.id);

                        // Update page details
                        await database.updatePageDetails(
                            uid,
                            widget.editedBook.id,
                            widget.editedPage.id,
                            widget.editedPage);
                        
                        Navigator.pop(context);
                      } else if (_branchIndex == 1 && branchValidator1()) {
                        // Delete existing branches
                        database.deleteBranch(
                            uid, widget.editedBook.id, widget.editedPage.id);

                        // Set the editedBranch's values to the input values from fields
                        widget.editedBranch[0].text =
                            _branchTextController[0].text;
                        widget.editedBranch[0].number = 1;
                        widget.editedBranch[0].pageID = branch1pageID;
                        widget.editedBranch[0].pageTitle = branch1PageSelector;

                        // Update page details
                        await database.updatePageDetails(
                            uid,
                            widget.editedBook.id,
                            widget.editedPage.id,
                            widget.editedPage);

                        // Loop through each branch and update Firestore with new values
                        for (int i = 0; i < _branchIndex; i++) {
                          await database.createBranchDocument(
                              widget.editedBook.id,
                              widget.editedPage.id,
                              widget.editedBranch[i]);
                          print("Added 1 branch");
                        }
                        print("Updated Firestore with new page + 1 branches");
                        Navigator.pop(context);
                        // Add branch 1 to book
                      } else if (_branchIndex == 2 &&
                          branchValidator1() &&
                          branchValidator2()) {
                        // Delete existing branches
                        database.deleteBranch(
                            uid, widget.editedBook.id, widget.editedPage.id);

                        // Set the editedBranch's values to the input values from fields
                        widget.editedBranch[0].text =
                            _branchTextController[0].text;
                        widget.editedBranch[0].number = 1;
                        widget.editedBranch[0].pageID = branch1pageID;
                        widget.editedBranch[0].pageTitle = branch1PageSelector;

                        widget.editedBranch[1].text =
                            _branchTextController[1].text;
                        widget.editedBranch[1].number = 2;
                        widget.editedBranch[1].pageID = branch2pageID;
                        widget.editedBranch[1].pageTitle = branch2PageSelector;

                        // Update page details
                        await database.updatePageDetails(
                            uid,
                            widget.editedBook.id,
                            widget.editedPage.id,
                            widget.editedPage);

                        // Loop through each branch and update Firestore with new values
                        for (int i = 0; i < _branchIndex; i++) {
                          print(widget.editedBranch[i].pageTitle);
                          await database.createBranchDocument(
                              widget.editedBook.id,
                              widget.editedPage.id,
                              widget.editedBranch[i]);
                          print("Added 2 branches");
                        }

                        // Save branches to database

                        Navigator.pop(context);
                        // Add brach 2 to book
                      } else if (_branchIndex == 3 &&
                          branchValidator1() &&
                          branchValidator2() &&
                          branchValidator3()) {
                        // Delete existing branches
                        database.deleteBranch(
                            uid, widget.editedBook.id, widget.editedPage.id);

                        // Set the editedBranch's values to the input values from fields
                        widget.editedBranch[0].text =
                            _branchTextController[0].text;
                        widget.editedBranch[0].number = 1;
                        widget.editedBranch[0].pageID = branch1pageID;
                        widget.editedBranch[0].pageTitle = branch1PageSelector;

                        widget.editedBranch[1].text =
                            _branchTextController[1].text;
                        widget.editedBranch[1].number = 2;
                        widget.editedBranch[1].pageID = branch2pageID;
                        widget.editedBranch[1].pageTitle = branch2PageSelector;

                        widget.editedBranch[2].text =
                            _branchTextController[2].text;
                        widget.editedBranch[2].number = 3;
                        widget.editedBranch[2].pageID = branch3pageID;
                        widget.editedBranch[2].pageTitle = branch3PageSelector;

                        // Update page details
                        await database.updatePageDetails(
                            uid,
                            widget.editedBook.id,
                            widget.editedPage.id,
                            widget.editedPage);

                        // Loop through each branch and update Firestore with new values
                        for (int i = 0; i < _branchIndex; i++) {
                          await database.createBranchDocument(
                              widget.editedBook.id,
                              widget.editedPage.id,
                              widget.editedBranch[i]);
                          print("Added 3 branches");
                        }

                        Navigator.pop(context);
                      }
                    } else {
                      print("Max length");
                    }

                    //database.createBookDocument(
                    //    widget.createdBook.title,
                    //    widget.createdBook.description,
                    //    widget.createdBook.genre,
                    //    widget.createdBook.cover,
                    //    widget.createdBook.isComplete,
                    //    widget.createdBook.creationDate,
                    //    widget.createdBook.lastUpdated);

                    // await Firestore.instance.collection("test").add({
                    //  'pageText': widget.createdPage.text,
                    //  'pageUpdated': widget.createdPage.lastUpdated,
                    //}).then((_) {

                    // print("JSON: ");
                    // print(_pageTextController.document.toJson());
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
