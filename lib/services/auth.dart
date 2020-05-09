// Packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// *** 
// Holds all firebase auth calls using AuthService.

class AuthService {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();


  // Get current user's ID
  Future<String> getUID() async {
    return (await _firebaseAuth.currentUser()).uid;
  }

  // Get current user's
  Future<String> getUsername() async {
    return (await _firebaseAuth.currentUser()).displayName;
  }

  // Get current user
  Future getUserPhotoURL() async {
    return (await _firebaseAuth.currentUser()).photoUrl;
  }

  // Get current user
  Future getUser() async {
    return await _firebaseAuth.currentUser();
  }

  // Checks if user is anonymous
  Future<bool> isAnon() async {
    bool result = (await _firebaseAuth.currentUser()).isAnonymous;
    return result;
  }

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

  // Deletes user
  Future deleteUser() async{
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.delete();
  }

  // Anonymous user sign in
  Future signInAnon(){
    return _firebaseAuth.signInAnonymously();
  }

  // Converts anon user using email credentials
  Future convertAnonWithEmail(String email, String password, String username) async {
    final user = await _firebaseAuth.currentUser();

    // Links anon user with email and password
    final credentials = EmailAuthProvider.getCredential(email: email, password: password);
    await user.linkWithCredential(credentials);
    await updateUserInfo(username, user);
  }

  // Convert anon user with Google
  Future convertAnonWithGoogle(String email, String password, String username) async {
    final user = await _firebaseAuth.currentUser();
    final GoogleSignInAccount userAccount = await _googleSignIn.signIn();
    final GoogleSignInAuthentication _googleAuth = await userAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(idToken: _googleAuth.idToken, accessToken: _googleAuth.accessToken);
    await user.linkWithCredential(credential);
    await updateUserInfo(_googleSignIn.currentUser.displayName, user);
  }

  // Sign in with Google
  Future<String> signInWithGoogle() async { // Uses Google API to get access token, uses the token to create new user in Firebase
    final GoogleSignInAccount userAccount = await _googleSignIn.signIn();
    final GoogleSignInAuthentication _googleAuth = await userAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(idToken: _googleAuth.idToken, accessToken: _googleAuth.accessToken);
    return (await _firebaseAuth.signInWithCredential(credential)).user.uid;
  }
}