import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text('Name'),
          ],
        ),
      ),
    );
  }
}
