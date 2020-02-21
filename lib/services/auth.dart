import 'package:firebase_auth/firebase_auth.dart';



// Holds all firebase calls using authentication

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  // Displays screen based on authState changes
  Stream<String> get onAuthStateChanged => _firebaseAuth.onAuthStateChanged.map( 
    (FirebaseUser user) => user?.uid
  );

  // Register new user
  Future<String> createNewUser(String email, String password, String username) async {
    final authResult = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

    await updateUserInfo(username, authResult.user);
    return authResult.user.uid;
  }

  // Update additional user info 
  Future updateUserInfo(String username, FirebaseUser currentUser) async {
    var updateUserDetails = UserUpdateInfo();
    updateUserDetails.displayName = username;
    await currentUser.updateProfile(updateUserDetails);
    await currentUser.reload();
  }

  // Existing user sign in
  Future<String> signInUser(String email, String password) async {
    return (await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password)).user.uid;
  }

  // Log out of user session
  signOut(){
    return _firebaseAuth.signOut();
  }

  
}