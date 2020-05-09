// Packages
import 'package:cloud_firestore/cloud_firestore.dart';
// Models
import 'package:storytap/models/book.dart';
import 'package:storytap/models/page.dart';
import 'package:storytap/models/branch.dart';
// ***
// Manages cloud firestore functionalities using DatabaseService.

class DatabaseService {
  String uid;

  DatabaseService({this.uid});

  // A collection reference to the "users" collection
  final CollectionReference usersCollection =
      Firestore.instance.collection("users");
  // A collection reference to the "books" collection
  final CollectionReference booksCollection =
      Firestore.instance.collection("books");




  // ** Create Functions
  // Creates a new book document in the usersCollection and also creates a new collection "books" separately
  Future createBookDocument(Book book, Page page, String username) async {
    DocumentReference bookid =
        await usersCollection.document(uid).collection("books").add({
      'bookTitle': book.title,
      'bookDescription': book.description,
      'bookGenre': book.genre,
      'bookCover': book.cover,
      'bookCreationDate': book.creationDate,
      'bookLastUpdated': book.lastUpdated,
      'isComplete': false,
    });
    await createPageDocument(bookid.documentID, book, page);
    await createBookCollection(
        book, bookid.documentID, uid, username); // Other bookCollection
    // createPageDocument(bookid, pageTitle, pageText, lastUpdated)
    return bookid.documentID;
  }

  // Creates a separate bookCollection which references the user that created that book and allows faster querying (less reads usage)
  Future createBookCollection(Book book, String bookid, String uid, String username) async {
    await booksCollection.document(bookid).setData({
      'bookTitle': book.title,
      'bookDescription': book.description,
      'bookGenre': book.genre,
      'bookCover': book.cover,
      'bookCreationDate': book.creationDate,
      'bookLastUpdated': book.lastUpdated,
      'isComplete': false,
      'author': uid,
      'username' : username,
    });
  }

  // Creates a page document for a particular book
  Future createPageDocument(String bookid, Book book, Page page) async {
    return await usersCollection
        .document(uid)
        .collection("books")
        .document(bookid)
        .collection("pages")
        .add({
      // 'book' : book,
      'pageTitle': page.title,
      'pageText': page.text,
      'pageLastUpdated': page.lastUpdated,
      'initial': page.initial,
    });
  }

  // Creates a branch document for a particular page
  Future createBranchDocument(
      String bookid, String pageid, Branch branch) async {
    return await usersCollection
        .document(uid)
        .collection("books")
        .document(bookid)
        .collection("pages")
        .document(pageid)
        .collection("branches")
        .add({
      'branchNumber': branch.number,
      'branchText': branch.text,
      'branchPageReference': branch.pageID,
      'branchPageTitle': branch.pageTitle,
    });
  }

  // ** Update Functions
  // Updates book cover in the Users collection
  Future updateBookCover(String uid, String bookid, String path) async {
    final document1 =
        usersCollection.document(uid).collection("books").document(bookid);
    final document2 = booksCollection.document(bookid);
    await document1.updateData({'bookCover': path});
    return await document2.updateData({'bookCover': path}); //
  }

  // Updates bookTitle in both collections
  Future updateBookTitle(String uid, String bookid, String title) async {
    final document1 = booksCollection.document(bookid);
    final document2 =
        usersCollection.document(uid).collection("books").document(bookid);

    await document1.updateData({'bookTitle': title});
    return await document2.updateData({'bookTitle': title});
  }

  // Updates bookDescription in both collections
  Future updateBookDescription(
      String uid, String bookid, String description) async {
    final document1 = booksCollection.document(bookid);
    final document2 =
        usersCollection.document(uid).collection("books").document(bookid);

    await document1.updateData({'bookTitle': description});
    return await document2.updateData({'bookDescription': description});
  }

  // Updates bookGenre in both collections
  Future updateBookGenre(String uid, String bookid, String genre) async {
    final document1 = booksCollection.document(bookid);
    final document2 =
        usersCollection.document(uid).collection("books").document(bookid);

    await document1.updateData({'bookGenre': genre});
    return await document2.updateData({'bookGenre': genre});
  }

  // Updates bookComplete in both collection
  Future updateBookComplete(String uid, String bookid, bool val) async {
    final document1 = booksCollection.document(bookid);
    final document2 =
        usersCollection.document(uid).collection("books").document(bookid);

    await document1.updateData({'isComplete': val});
    return await document2.updateData({'isComplete': val});
  }


  // Updates the page's details
  Future updatePageDetails(String uid, String bookid, String pageid, Page page) async {
    final document = usersCollection.document(uid).collection("books").document(bookid).collection("pages").document(pageid);
    return await document.updateData({'pageTitle' : page.title, 'pageText' : page.text, 'pageLastUpdated' : page.lastUpdated});
  }


  // ** Delete Functions
  // Deletes all branches from a page
  Future deleteBranch(String uid, String bookid, String pageid) async {
    // Get all branch documents
    final branches = usersCollection.document(uid).collection("books").document(bookid).collection("pages").document(pageid).collection("branches").getDocuments();
    branches.then((snapshot){
      for (DocumentSnapshot doc in snapshot.documents){
        doc.reference.delete(); // Deletes each one individually
      }
    });
    return;
  }

  // Deletes a single page also ensures that if it contains any branches those are deleted too
  Future deleteSinglePage(String uid, String bookid, String pageid) async {
    // Get the page document
    final page = usersCollection.document(uid).collection("books").document(bookid).collection("pages").document(pageid); 
    deleteBranch(uid, bookid, page.documentID); // Delete its branches
    return await page.delete(); // Delete the page itself
  }

  // Deletes broken branches for a single page that has been removed 
  Future deleteBrokenBranches(String uid, String bookid, String brokenPageID) async {
    final pages = usersCollection.document(uid).collection("books").document(bookid).collection("pages").getDocuments();
    pages.then((snapshot) {
      for (DocumentSnapshot page in snapshot.documents){
        final branches = usersCollection.document(uid).collection("books").document(bookid).collection("pages").document(page.documentID).collection("branches").getDocuments();
        branches.then( (snapshot2) {
          for (DocumentSnapshot branch in snapshot2.documents){
            if (branch.data['branchPageReference'] == brokenPageID){
              branch.reference.delete();
            }
          }
        }); 
      }
    });
    

  }

  // Deletes all pages only used when the book delete function is called 
  Future deleteAllPages(String uid, String bookid) async {
    final pages = usersCollection.document(uid).collection("books").document(bookid).collection("pages").getDocuments();
    pages.then((snapshot){
      for (DocumentSnapshot doc in snapshot.documents){
        deleteBranch(uid, bookid, doc.documentID); // Deletes all branches from the page
        doc.reference.delete(); // Deletes the page itself
      }
    });
  }

  // Deletes a book in both collections
  Future deleteBook(String uid, String bookid) async {
    final usersCollectionRef = usersCollection.document(uid).collection("books").document(bookid); // Get the doc ref in usersCollection
    final booksCollectionRef = booksCollection.document(bookid); // Get the doc ref in booksCollection
    await usersCollectionRef.delete(); // Delete it from usersCollection
    return await booksCollectionRef.delete(); // Delete it from booksCollection
  }

  // A function that deletes everything from a book includes pages and branches
  Future deleteCreatedBook(String uid, String bookid) async {
    await deleteAllPages(uid, bookid); // First delete all pages including branches
    return await deleteBook(uid, bookid); // Then delete the book from both collections

  }

  // ** Stream Functions
  // Gets a stream querysnapshot of a user's book collection
  Stream<QuerySnapshot> getUserBookStreamSnapshots() async* {
    yield* usersCollection.document(uid).collection("books").snapshots();
    // Returns a snapshot of the current user's book collection
  }

  // Returns a snapshot from the booksCollection
  Stream<QuerySnapshot> getBooksCollectionSnapshots(String bookid) async* {
    yield* booksCollection.snapshots();
  }

  Future getUserID() async {
    return uid;
  }
}
