// Models
import 'book.dart';
import 'branch.dart';

class Page {
  Book book;
  String title;
  String text;
  bool initial;
  DateTime lastUpdated;
  List<Branch> choices;

  Page({this.book, this.title, this.text, this.initial, this.lastUpdated, this.choices});
}




