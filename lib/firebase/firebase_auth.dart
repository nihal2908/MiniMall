import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mnnit/widgets/circular_progress.dart';

class Auth {
  //instance
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //get current user
  // User? getCurentUser() {
  //   return auth.currentUser;
  // }

  //signout
  Future<void> signOut() async {
    return await auth.signOut();
  }

  // login
  Future<UserCredential?> login({required BuildContext context, required String email, required String password}) async {
    try {
      _showLoadingDialog(context);
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      Navigator.of(context).pop();
      if(!userCredential.user!.emailVerified) {
        _showEmailVerify(context);
        return null;
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      _showErrorDialog(context, e.message!);
      throw Exception(e.code);
    }
  }

  Future<UserCredential> register({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
    required String gender,
  }) async {
    try {
      _showLoadingDialog(context);
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': name,
        'gender': gender,
        'accountDate': FieldValue.serverTimestamp()
      });
      Navigator.of(context).pop();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      _showErrorDialog(context, e.message!);
      throw Exception(e.code);
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CenterIndicator();
      },
    );
  }

  void _showEmailVerify(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Email not verified'),
          content: Text('A verification link is sent to your email. Please verify it\'s you.'),
          actions: [
            ElevatedButton(onPressed: (){
              Navigator.pop(context);
            }, child: Text('Retry')),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> editDocRecord({
    required String name,
    required String phone,
    required String bio,
    required String address,
    required String category,
    required int age,
    required String gender,
  }) async {
    await firestore.collection('Doctor').doc().update({
      'name': name,
      'phone': phone,
      'age': age,
      'gender': gender,
      'bio': bio,
      'address': address,
      'category': category,
    });
  }
}

// String currentUserId = '';
// String currentUserEmail = '';