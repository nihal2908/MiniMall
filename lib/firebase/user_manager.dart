import 'package:firebase_auth/firebase_auth.dart';

class UserManager {
  static String? _userId;
  static String? _emailId;

  static Future<void> initializeUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      _emailId = user.email;
    } else {
      // Handle the case where there is no logged-in user
      _userId = null;
      _emailId = null;
    }
  }

  static String? get userId => _userId;
  static String? get emailId => _emailId;

  // call this function during signout
  static void signOut() {
    _userId = null;
    _emailId = null;
  }
}
