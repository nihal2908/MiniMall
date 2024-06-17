import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  //instance
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //get current user
  User? getCurentUser() {
    return auth.currentUser;
  }

  //signout
  Future<void> signOut() async {
    return await auth.signOut();
  }

  //doctor login
  Future<UserCredential> login(String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      // print('credentials sahi hain');
      // currentUserId = await  userCredential.user!.uid;
      // currentUserEmail = await userCredential.user!.email!;
      // print(currentUserId);
      // print(currentUserId.runtimeType);
      // print(currentUserEmail);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //doctor signup
  Future<UserCredential> register({
    required String email,
    required String password,
    required String name,
    required String gender,
  }) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      //add it to the list of users
      firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': name,
        'gender': gender,
        'accountDate': FieldValue.serverTimestamp()
      });
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
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