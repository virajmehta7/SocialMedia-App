import 'package:coolname/utils/colors.dart';
import 'package:coolname/views/tabsPage/ChatTabPage.dart';
import 'package:flutter/material.dart';
import 'tabsPage/homeTabPage.dart';
import 'tabsPage/profileTabPage.dart';
import 'tabsPage/searchTabPage.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int selectedIndex = 0;

  final tabs = [
    HomeTabPage(),
    SearchTabPage(),
    ChatTabPage(),
    ProfileTabPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index){
          setState(() {
            selectedIndex = index;
          });
        },
        currentIndex: selectedIndex,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/home_outlined.png',
              color: Colors.grey.shade600,
              height: 26,
            ),
            activeIcon: Image.asset(
              'assets/images/home_filled.png',
              color: mlight,
              height: 26,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/search_outlined.png',
              color: Colors.grey.shade600,
              height: 26,
            ),
            activeIcon: Image.asset(
              'assets/images/search_filled.png',
              color: mlight,
              height: 26,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/chat_outlined.png',
              color: Colors.grey.shade600,
              height: 26,
            ),
            activeIcon: Image.asset(
              'assets/images/chat_filled.png',
              color: mlight,
              height: 26,
            ),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/person_outlined.png',
              color: Colors.grey.shade600,
              height: 26,
            ),
            activeIcon: Image.asset(
              'assets/images/person_filled.png',
              color: mlight,
              height: 26,
            ),
            label: 'Profile',
          ),
        ],
      ),
      body: tabs[selectedIndex],
    );
  }
}