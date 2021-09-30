import 'package:coolname/views/tabBarPages/accounts.dart';
import 'package:coolname/views/tabBarPages/tags.dart';
import 'package:flutter/material.dart';

class SearchTabPage extends StatefulWidget {
  const SearchTabPage({Key key}) : super(key: key);

  @override
  _SearchTabPageState createState() => _SearchTabPageState();
}

class _SearchTabPageState extends State<SearchTabPage> with SingleTickerProviderStateMixin{

  TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search',
          style: TextStyle(
              color: Colors.black,
              fontSize: 22
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          indicatorColor: Color(0xffb1325f),
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black,
          labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
          indicatorSize: TabBarIndicatorSize.label,
          controller: tabController,
          tabs: [
            Tab(text: 'Accounts',),
            Tab(text: 'Tags',)
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          SearchAccounts(),
          SearchTags()
        ],
      ),
    );
  }
}