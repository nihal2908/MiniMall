import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mnnit/pages/account_page.dart';
import 'package:mnnit/pages/recently_viewed_page.dart';
import 'package:mnnit/pages/wishlist_page.dart';

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
              Card(
                child: ListTile(
                    title: Text('Account Settings'),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage()));
                  },
                ),
              ),
              Card(
                child: ListTile(
                  title: Text('My Wishlist'),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>WishlistPage()));
                  },
                ),
              ),
              Card(
                child: ListTile(
                  title: Text('Recently viewed'),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>RecentlyViewedPage()));
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
