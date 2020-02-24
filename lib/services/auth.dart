import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


// Holds all firebase calls using authentication

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();


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

  // Password reset
  Future sendResetPassword(String email) async {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // Anonymous user sign in
  Future signInAnon(){
    return _firebaseAuth.signInAnonymously();
  }

  // Sign in with Google
  Future<String> signInWithGoogle() async { // Uses Google API to get access token, uses the token to create new user in Firebase
    final GoogleSignInAccount userAccount = await _googleSignIn.signIn();
    final GoogleSignInAuthentication _googleAuth = await userAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(idToken: _googleAuth.idToken, accessToken: _googleAuth.accessToken);
    return (await _firebaseAuth.signInWithCredential(credential)).user.uid;
  }
}