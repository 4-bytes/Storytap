// Models
import 'book.dart';
import 'branch.dart';

// A book can have pages, these of are of two types: initial page and other pages.

class Page {
  Book book;
  String id;
  String title;
  String text;
  bool initial;
  DateTime lastUpdated;
  List<Branch> choices;

  Page({this.book, this.id, this.title, this.text, this.initial, this.lastUpdated, this.choices});
}




