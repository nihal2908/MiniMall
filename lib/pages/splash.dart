import 'package:flutter/material.dart';
import 'package:mnnit/firebase/user_manager.dart';
import 'package:mnnit/pages/home_page.dart';
import 'package:mnnit/pages/landing_page.dart';
import 'package:mnnit/pages/login_page.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    // Display splash screen for at least 2 seconds
    // await Future.delayed(const Duration(seconds: 2));
    // Ensure Firebase initialization and user ID retrieval are complete
    await UserManager.initializeUserId();

    // Navigate based on login status
    if (UserManager.userId == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LandingPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Welcome to Mnnit Market',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}