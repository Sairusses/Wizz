import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wizz/role_selection/select_role_screen.dart';

import '../login_signup/login_screen.dart';
import '../main_screens/home_screen.dart';

class AuthService {
  final FirebaseAuth _auth  = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //sign up method
  Future<void> signup ({
    required String username,
    required String email,
    required String password,
    required BuildContext context
  }) async{
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      showToast("Fields cannot be empty");
      return;
    }
    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}").hasMatch(email)) {
      showToast("Invalid email format");
      return;
    }
    try{
      showLoadingDialog(context);
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection("users").doc(user.uid).set({
          "username": username,
          "email": email,
          "role": "",
          "createdAt": FieldValue.serverTimestamp(),
        });
      }
      Navigator.pop(context);
      _navigateTo(context, SelectRole());
    } on FirebaseAuthException catch(e) {
      showToast(_getFirebaseErrorMessage(e.code), backgroundColor: Colors.red);
    }
  }

  //log in method
  Future<void> login ({
    required String email,
    required String password,
    required BuildContext context
  }) async{
    if (email.isEmpty || password.isEmpty) {
      showToast("Email or password cannot be empty");
      return;
    }
    try {
      showLoadingDialog(context);
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(
            'users').doc(user.uid).get();
        String role = userDoc['role'];
        Navigator.pop(context);
        role == "" ? _navigateTo(context, SelectRole()) : _navigateTo(context, HomeScreen());
      }
    } on FirebaseAuthException catch (e) {
      showToast(_getFirebaseErrorMessage(e.code));
      Navigator.pop(context);
    }
  }

  //log out method
  Future<void> logout(BuildContext context) async {
    showLoadingDialog(context);
    await _auth.signOut();
    Navigator.pop(context);
    _navigateTo(context, LoginScreen());
  }

  //helper methods
  Future<void> showToast(String message, {Color backgroundColor = Colors.grey}) async {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: backgroundColor,
      textColor: Colors.black,
      fontSize: 14,
      gravity: ToastGravity.SNACKBAR,
    );
  }
  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.black54)),
    );
  }
  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'The password is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'user-not-found':
        return 'Invalid email.';
      case 'invalid-credential':
        return 'wrong email or password.';
      case 'wrong-password':
        return 'Incorrect password.';
      default:
        return 'Unexpected error: $errorCode';
    }
  }
  void _navigateTo(BuildContext context, Widget page) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => page,
      ),
      (Route<dynamic> route) => false,
    );
  }
}