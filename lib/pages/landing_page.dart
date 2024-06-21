import 'package:flutter/material.dart';
import 'package:mnnit/pages/home_page.dart';
import 'package:mnnit/pages/imageTest.dart';
import 'package:mnnit/pages/profile_page.dart';
import 'package:mnnit/pages/sell_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

List<Widget> Tabs = [HomePage(), ImageUploadPage(), SellPage()];

class _LandingPageState extends State<LandingPage> {
  int currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Tabs[currentTabIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentTabIndex = index;
          });
        },
        indicatorColor: Colors.deepPurple.shade200,
        selectedIndex: currentTabIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.outbox),
            icon: Icon(Icons.outbox_outlined),
            label: 'Sell',
          ),
          // NavigationDestination(
          //   //selectedIcon: Icon(),
          //   icon: Icon(Icons.settings),
          //   label: 'Settings',
          // ),
        ],
      ),
    );
  }
}
