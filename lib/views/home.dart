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
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 30,
        selectedIconTheme: IconThemeData(color: mlight),
        unselectedIconTheme: IconThemeData(color: Colors.grey.shade600),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      body: tabs[selectedIndex],
    );
  }
}