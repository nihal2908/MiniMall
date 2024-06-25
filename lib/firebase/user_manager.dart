import 'package:firebase_auth/firebase_auth.dart';

class UserManager {
  static String? _userId;

  static Future<void> initializeUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
    } else {
      // Handle the case where there is no logged-in user
      _userId = null;
    }
  }

  static String? get userId => _userId;
}
