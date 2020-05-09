// Packages
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

// *** 
// Manages firebase storage calls using StorageService.

class StorageService {


  // Loads the user's profile image
  static Future<dynamic> loadProfileImage(BuildContext context, String id) async {
    return await FirebaseStorage.instance.ref().child(id+".png").getDownloadURL();
  }

  // Loads the book cover image
  static Future<dynamic> loadBookCover(BuildContext context, String id) async {
    return await FirebaseStorage.instance.ref().child(id).getDownloadURL();
  }

  // Upload book cover to storage
  static Future uploadBookCover(BuildContext context, String path, File file) async {
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(path); // Get the path of the file
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(file); // Ensures that the file is added with its path
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete; // Check if upload is completed
  }

  // Upload profile image to storage
  static Future uploadProfileImage(BuildContext context, String path, File file) async {
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(path);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(file);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    print("Uploaded");
  }

  // Deletes book cover when the created book is deleted
  static Future deleteBookCover(String id) async {
    return await FirebaseStorage.instance.ref().child(id+'.png').delete();
  }


}