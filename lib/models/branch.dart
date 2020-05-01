// Models
import 'page.dart';

// A page has the option of having branches. 

class Branch{ 
  String id; // The branch's unique ID
  int number; // The branch's number (for ordering)
  String pageTitle; // The title of the page that the branch belongs to
  String text; // The branch's text
  String pageID; // Reference of the page (Page ID)
  

  Branch(this.number, this.text, this.pageID);
}
