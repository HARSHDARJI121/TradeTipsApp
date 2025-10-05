import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("User cancelled Google sign-in.");
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        await _saveUserToFirestore(user);
      }

      return user;
    } catch (e) {
      print('Google sign-in error: $e');
      return null;
    }
  }

  /// Email/Password Sign-In
  Future<User?> signInWithEmail(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = result.user;
    if (user != null) {
      await saveDeviceTokenOnLogin(user);
    }
    return user;
  }

  Future<void> saveDeviceTokenOnLogin(User user) async {
    final token = await FirebaseMessaging.instance.getToken();
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'deviceToken': token,
    }, SetOptions(merge: true));
  }

  /// Email/Password Registration
  Future<User?> registerWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(name);
        await _saveUserToFirestore(user, name: name);
      }

      return user;
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  /// Save or update user in Firestore
  Future<void> _saveUserToFirestore(User user, {String? name}) async {
    await _firestore.collection('users').doc(user.uid).set({
      'name': name ?? user.displayName ?? '',
      'email': user.email ?? '',
      'photoURL': user.photoURL ?? '',
      'provider': 'google',
      'lastLogin': DateTime.now(),
    }, SetOptions(merge: true));
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Google sign out error: $e');
    }
    await _auth.signOut();
  }

  /// Check Device Token
  // Future<void> checkDeviceToken(User user, BuildContext context) async {
  //   final token = await FirebaseMessaging.instance.getToken();
  //   final doc = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(user.uid)
  //       .get();
  //   final savedToken = doc.data()?['deviceToken'];
  //   if (savedToken != null && savedToken != token) {
  //     await FirebaseAuth.instance.signOut();
  //     showDialog(
  //       context: context,
  //       builder: (_) => AlertDialog(
  //         title: Text('Logged out'),
  //         content: Text('Your account was logged in on another device.'),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: Text('OK'),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }
}
