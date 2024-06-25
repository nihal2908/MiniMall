import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mnnit/pages/account_page.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage()));
                },
                child: Card(
                  child: ListTile(
                      title: Text('Account Settings')
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
