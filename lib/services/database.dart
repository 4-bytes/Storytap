// Packages
import 'package:cloud_firestore/cloud_firestore.dart';
// Models
import 'package:storytap/models/book.dart';
import 'package:storytap/models/page.dart';

// *** 
// Manages cloud firestore functionalities using DatabaseService.

class DatabaseService {
  
  String uid;

  DatabaseService({this.uid});


  // A collection reference to the "users" collection
  final CollectionReference usersCollection = Firestore.instance.collection("users");
  // A collection reference to the "books" collection
  final CollectionReference booksCollection = Firestore.instance.collection("books");

  Future createBookDocument(
    // Creates a new book document in the usersCollection and also creates a new collection "books" separately
    Book book, Page page
  ) async {
    DocumentReference bookid = await usersCollection.document(uid).collection("books").add({
      'bookTitle': book.title,
      'bookDescription': book.description,
      'bookGenre': book.genre,
      'bookCover': book.cover,
      'bookCreationDate': book.creationDate,
      'bookLastUpdated': book.lastUpdated,
      'isComplete': false,
    });
    await createPageDocument(bookid.documentID, book, page);
    await createBookCollection(book, bookid.documentID, uid);
    // createPageDocument(bookid, pageTitle, pageText, lastUpdated)
  }

  // Creates a bookCollection which references the user that created that book and allows faster querying
  Future createBookCollection(Book book, String bookid, String uid) async {
    await booksCollection.document(bookid).setData({ 
      'bookTitle': book.title,
      'bookDescription': book.description,
      'bookGenre': book.genre,
      'bookCover': book.cover,
      'bookCreationDate': book.creationDate,
      'bookLastUpdated': book.lastUpdated,
      'isComplete': false,
      'author' : uid,});
  }

  // Creates a page document for a particular book
  Future createPageDocument(String bookid, Book book, Page page) async {
        return await usersCollection.document(uid).collection("books").document(bookid).collection("pages").add({
          // 'book' : book,
          'pageTitle' : page.title,
          'pageText' : page.text,
          'pageLastUpdated' : page.lastUpdated,
          'initial' : page.initial,
        });
      }

  Stream<QuerySnapshot> getUserBookStreamSnapshots() async* {
    yield* usersCollection.document(uid).collection("books").snapshots();
    // Returns a snapshot of the current user's book collection
  }

  // Returns a snapshot from the booksCollection
  Stream<QuerySnapshot> getBooksCollectionSnapshots(String bookid) async* {
    yield* booksCollection.snapshots();
  }

  Future getUserID() async{
    return uid;
  }

}
