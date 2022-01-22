import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coolname/utils/colors.dart';
import 'package:coolname/views/tabsPage/profileTabPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../remoteUserProfile.dart';

class SearchAccounts extends StatefulWidget {
  const SearchAccounts({Key key}) : super(key: key);

  @override
  _SearchAccountsState createState() => _SearchAccountsState();
}

class _SearchAccountsState extends State<SearchAccounts> {

  TextEditingController search = TextEditingController();
  QuerySnapshot querySnapshot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 8),
              child: TextField(
                controller: search,
                decoration: InputDecoration(
                  hintText: 'Search accounts',
                  hintStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w300,
                  ),
                  suffixIcon: IconButton(
                    onPressed: (){
                      if(search.text.isNotEmpty){
                        FocusScope.of(context).unfocus();
                        FirebaseFirestore.instance
                            .collection('users')
                            .where('username', isGreaterThanOrEqualTo: search.text.trim().toLowerCase())
                            .where('username', isLessThan: search.text.trim().toLowerCase() + 'z')
                            .get()
                            .then((value) {
                          setState(() {
                            querySnapshot = value;
                          });
                        });
                      }
                    },
                    icon: Icon(
                      Icons.search,
                      color: mlight,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Colors.black
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Colors.black
                    ),
                  ),
                ),
              ),
            ),
            if(querySnapshot != null)
              if(querySnapshot.docs.length == 0)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Text('No results found for \n "${search.text.trim()}"',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w300
                    ),
                  )
                ),
            querySnapshot != null ? ListView.builder(
              shrinkWrap: true,
              itemCount: querySnapshot.docs.length,
              physics: ScrollPhysics(),
              itemBuilder: (context, index){
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        querySnapshot.docs[index].get("profilePhoto") != null ?
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(querySnapshot.docs[index].get("profilePhoto")),
                        ) :
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage("assets/images/profile.png"),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(querySnapshot.docs[index].get("username"),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              querySnapshot.docs[index].get("name") != null ?
                              Text(querySnapshot.docs[index].get("name"),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.black, fontSize: 14),
                              ) :
                              Container(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: (){
                    querySnapshot.docs[index].get("username") == FirebaseAuth.instance.currentUser.displayName ?
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileTabPage())) :
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RemoteUserProfile(
                      username: querySnapshot.docs[index].get("username"),
                      uid: querySnapshot.docs[index].get("uid"),
                    )));
                  },
                );
              },
            ) : Container(),
          ],
        ),
      ),
    );
  }
}