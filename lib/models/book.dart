

import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  String title;
  String description;
  String author;
  String genre;
  String cover;
  bool isComplete;
  DateTime lastUpdated;
  DateTime creationDate;

  Book(
      {this.title,
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

  factory Book.fromFirestore(DocumentSnapshot document){
    Map data = document.data;

    return Book(
      title: data['bookTitle'],
      description: data['bookDescription'],
      author: data['bookAuthor'],
      genre: data['bookGenre'],
      cover: data['bookCover'],
      creationDate: data['bookCreationDate'],
      lastUpdated: data['lastUpdated'],
      isComplete: data['isComplete'],
    );

  }
}
