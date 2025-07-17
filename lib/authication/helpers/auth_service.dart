import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // The user canceled the sign-in
      return null;
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the Google [UserCredential]
    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
  }

  static Future<void> logout() async {
    // Clear tokens, user data, etc.
    // For example, using SharedPreferences:
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.clear();
  }

  Future<void> saveUserToFirestore(User user) async {
    final usersRef = FirebaseFirestore.instance.collection('users');
    await usersRef.doc(user.uid).set({
      'name': user.displayName ?? '', // For email login, prompt for name at sign up
      'email': user.email ?? '',
      'provider': user.providerData.isNotEmpty ? user.providerData[0].providerId : '',
      // Add more fields if needed
    }, SetOptions(merge: true));
  }
}
