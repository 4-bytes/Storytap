import 'book.dart';
import 'branch.dart';

class Page {
  Book book;
  String title;
  String text;
  DateTime lastUpdated;
  List<Branch> choices;

  Page({this.book, this.title, this.text, this.lastUpdated, this.choices});
}




