// Packages
import 'package:cloud_firestore/cloud_firestore.dart';

// A book class that contains the properties of a book.

class Book {
  String id;
  String title;
  String description;
  String author;
  String genre;
  String cover;
  bool isComplete;
  DateTime lastUpdated;
  DateTime creationDate;

  Book(
      {
      this.id,  
      this.title,
      this.description,
      this.author,
      this.genre,
      this.cover,
      this.isComplete,
      this.lastUpdated,
      this.creationDate});


  Map<String, dynamic> toJson() => { 
        'bookTitle': title,
        'bookDescription': description,
        'bookAuthor': author,
        'bookGenre': genre,
        'bookCover': cover,
        'bookCreationDate': creationDate,
        'bookLastUpdated': lastUpdated,
        'isComplete': false,
      };


  // creates a Book object using snapshot from firestore
  Book.fromSnapshot(DocumentSnapshot snapshot) :
      id = snapshot.documentID,
      title = snapshot['bookTitle'],
      description = snapshot['bookDescription'],
      author = snapshot['bookAuthor'],
      genre = snapshot['bookGenre'],
      cover = snapshot['bookCover'],
      creationDate = snapshot['bookCreationDate'].toDate(),
      lastUpdated = snapshot['bookLastUpdated'].toDate(),
      isComplete = snapshot['isComplete'];



}
