import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mnnit/firebase/user_manager.dart';
import 'package:mnnit/pages/splash.dart';
import 'package:mnnit/widgets/circular_progress.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData() async {
    return await firestore.collection('users').doc(UserManager.userId).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: getUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CenterIndicator();
                  }
                  if (snapshot.hasError) {
                    return ListTile(
                      title: Text('Error: ${snapshot.error}'),
                    );
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return ListTile(
                      title: Text('No user data found.'),
                    );
                  }

                  final userData = snapshot.data!.data() as Map<String, dynamic>;

                  return Card(
                    child: ListTile(
                      title: Column(
                        children: [
                          Text('Name: ${userData['name']}'),
                          Text('Email: ${userData['email']}'),
                          Text('Gender: ${userData['gender']}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Card(child: ListTile(title: Text('Edit Profile'))),
              Card(
                child: ListTile(
                  title: Text('Change Password'),
                  onTap: () {
                    confirmResetPassword(context);
                  },
                ),
              ),
              Card(
                child: ListTile(
                  title: Text('SignOut'),
                  onTap: () {
                    confirmSignout(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void confirmSignout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign-Out?'),
        content: Text('Do you want to Sign-out?'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel', style: TextStyle(color: Colors.green)),
          ),
          ElevatedButton(
            onPressed: () async {
              await auth.signOut();
              UserManager.signOut();
              showDialog(
                context: context,
                builder: (context) => CenterIndicator(),
              );
              await Future.delayed(Duration(seconds: 2));
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => SplashScreen(),
                ),
                (route) => false,
              );
            },
            child: Text(
              'Sign-out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void confirmResetPassword(BuildContext context) {
    print(UserManager.userId);
    print(UserManager.emailId);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Password'),
        content: Text(
            'You will receive a password reset email to your registered email-id'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel', style: TextStyle(color: Colors.green)),
          ),
          ElevatedButton(
            onPressed: () async {
              await auth.sendPasswordResetEmail(email: UserManager.emailId!);
              Navigator.pop(context);
            },
            child: Text(
              'Send email',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void temp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign-Out?'),
        content: Text('Do you want to Sign-out?'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel', style: TextStyle(color: Colors.green)),
          ),
          ElevatedButton(
            onPressed: () {
              auth.signOut();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SplashScreen(),
                  ),
                  (route) => false);
            },
            child: Text(
              'Sign-out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void showAlertDialog(
      {required BuildContext context,
      required String title,
      required String content,
      required String firstAction,
      required String seconAction,
      required void function1(),
      required void function2()}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            ElevatedButton(
              onPressed: function1,
              child: Text('Cancel', style: TextStyle(color: Colors.green)),
            ),
            ElevatedButton(
              onPressed: () {
                auth.signOut();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => SplashScreen()),
                    (route) => false);
              },
              child: Text('Sign-out', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
