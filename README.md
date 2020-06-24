# Storytap

An online platform made for reading and writing interactive books on mobile devices. 
This application was built using Flutter, and uses Firebase Cloud Firestore, Authentication and Storage.
A rich text editor was also integrated to achieve the text formatting that can be used to customize the pages.

## Functionality

### Writing

A new book can be created on the platform by entering basic details such as the book title, description and genre. They also need to enter information about the starting page of the book. Once a book has been created, it can be found in the created books tab. From here, you can manage the books that you have created. New pages can be added as well as branches that are used to link pages together. 

### Reading 

There is a browse books tab that is used to find and search for books to read made by other users. All created books will appear on the reading section based on the genre that they were written for. While reading, if a page does not have a branch that links to another page then that page will display book end page automatically. This ensures that there are no broken links.

## Installation

Clone this repository and make sure that the version of Flutter installed is 1.12.13. <br>
Configure your own Firebase project, this includes generating the google-services.json for Android as well as GoogleServices-Info.plist file for iOS devices. <br>
Once a supported device is connected, run the app using the command <b>flutter run</b>.

## Screenshots

![Screenshot 1](https://github.com/4-bytes/Storytap/blob/master/gifs/gif1.gif) 

![Screenshot 2](https://github.com/4-bytes/Storytap/blob/master/gifs/gif2.gif)

![Screenshot 3](https://github.com/4-bytes/Storytap/blob/master/gifs/gif3.gif)

![Screenshot 4](https://github.com/4-bytes/Storytap/blob/master/gifs/gif4.gif)

![Screenshot 5](https://github.com/4-bytes/Storytap/blob/master/gifs/gif5.gif)

![Screenshot 6](https://github.com/4-bytes/Storytap/blob/master/gifs/gif6.gif)



