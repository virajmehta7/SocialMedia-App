import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'tabsPage/homeTabPage.dart';
import 'tabsPage/profileTabPage.dart';
import 'tabsPage/searchTabPage.dart';
import 'tabsPage/videosTabPage.dart';

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
    VideosTabPage(),
    ProfileTabPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ConvexAppBar(
        items: [
          TabItem(
            icon: Icons.home,
          ),
          TabItem(
            icon: Icons.search,
          ),
          TabItem(
            icon: Icons.video_collection,
          ),
          TabItem(
            icon: Icons.person,
          ),
        ],
        onTap: (index){
          setState(() {
            selectedIndex = index;
          });
        },
        backgroundColor: Color(0xffb1325f),
        height: 50,
        style: TabStyle.react,
      ),
      body: tabs[selectedIndex],
      // body: Stack(
      //   children: [
      //     tabs[selectedIndex],
      //     Align(
      //       alignment: Alignment.bottomCenter,
      //       child: Container(
      //         margin: EdgeInsets.symmetric(vertical: 10, horizontal: 60),
      //         decoration: BoxDecoration(
      //           borderRadius: BorderRadius.circular(50),
      //           gradient: LinearGradient(
      //               begin: Alignment.topLeft,
      //               end: Alignment.bottomRight,
      //               colors: [
      //                 Color(0xffDA4453),
      //                 Color(0xffb1325f),
      //                 Color(0xff89216B)
      //               ]
      //           ),
      //         ),
      //         child: BottomNavigationBar(
      //           onTap: (index){
      //             setState(() {
      //               selectedIndex = index;
      //             });
      //           },
      //           currentIndex: selectedIndex,
      //           iconSize: 26,
      //           showSelectedLabels: false,
      //           showUnselectedLabels: false,
      //           backgroundColor: Colors.transparent,
      //           elevation: 0,
      //           type: BottomNavigationBarType.fixed,
      //           selectedIconTheme: IconThemeData(color: Colors.white),
      //           items: [
      //             BottomNavigationBarItem(
      //               icon: Icon(Icons.home_outlined),
      //               activeIcon: Icon(Icons.home),
      //               label: 'Home',
      //             ),
      //             BottomNavigationBarItem(
      //               icon: Icon(Icons.search),
      //               label: 'Search',
      //             ),
      //             BottomNavigationBarItem(
      //               icon: Icon(Icons.video_collection_outlined),
      //               activeIcon: Icon(Icons.video_collection),
      //               label: 'Watch',
      //             ),
      //             BottomNavigationBarItem(
      //               icon: Icon(Icons.person_outline),
      //               activeIcon: Icon(Icons.person),
      //               label: 'Profile',
      //             ),
      //           ],
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
}