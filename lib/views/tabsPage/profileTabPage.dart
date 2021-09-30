import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coolname/views/bottomSheet/addPost.dart';
import 'package:coolname/views/bottomSheet/more.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../postDetails.dart';

class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({Key key}) : super(key: key);

  @override
  _ProfileTabPageState createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {

  OverlayEntry createPopUp(name, photo) {
    return OverlayEntry(
        builder: (context) => BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 8,
            sigmaY: 8,
          ),
          child: SimpleDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            insetPadding: EdgeInsets.symmetric(vertical: 30, horizontal: 25),
            contentPadding: EdgeInsets.zero,
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(name,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)
                ),
                child: Image.network(photo),
              ),
            ],
          ),
        )
    );
  }

  OverlayEntry popUp;
  var profilePhoto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FirebaseAuth.instance.currentUser.displayName,
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.black,
              size: 25,
            ),
            onPressed: (){
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => AddPost(),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.black,
              size: 25,
            ),
            onPressed: (){
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => More(),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot){
                if(!snapshot.hasData)
                  return Center(
                      child: CircularProgressIndicator(
                          color: Color(0xffb1325f)
                      )
                  );
                profilePhoto = snapshot.data['profilePhoto'];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        snapshot.data['profileBgPhoto'] != null ?
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 150,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(snapshot.data['profileBgPhoto']),
                                  fit: BoxFit.fitWidth
                              )
                          ),
                        ) :
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 150,
                          color: Color(0xffb1325f),
                        ),
                        snapshot.data['profilePhoto'] != null ?
                        Container(
                          margin: EdgeInsets.only(top: 80, bottom: 5),
                          child: Center(
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              backgroundImage: NetworkImage(snapshot.data['profilePhoto']),
                            ),
                          ),
                        ) :
                        Container(
                          margin: EdgeInsets.only(top: 80, bottom: 8),
                          child: Center(
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              backgroundImage: AssetImage("assets/images/profile.png"),
                            ),
                          ),
                        )
                      ],
                    ),
                    snapshot.data['name'] != "" ?
                    Center(
                      child: Text(snapshot.data['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20
                        ),
                      ),
                    ) :
                    Container(),
                    snapshot.data['bio'] != "" ?
                    Padding(
                      padding: EdgeInsets.fromLTRB(10,8,5,0),
                      child: Text(snapshot.data['bio'],
                        style: TextStyle(
                            fontSize: 18
                        ),
                      ),
                    ) :
                    Container(),
                  ],
                );
              },
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(40,10,40,5),
              child: Divider(
                thickness: 1.5,
              ),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser.uid)
                  .collection('posts')
                  .orderBy("postedAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot){
                if(!snapshot.hasData)
                  return Container();
                return snapshot.data.docs.length == 0 ?
                Container(
                  padding: EdgeInsets.only(top: 50),
                  child: Column(
                    children: [
                      Text('When you share photos,',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16
                        ),
                      ),
                      Text('they\'ll appear here.',
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16
                        ),
                      ),
                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: (){
                          showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (context) => AddPost(),
                          );
                        },
                        child: Text('Share your first photo',
                          style: TextStyle(
                            color: Color(0xffb1325f),
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  ),
                ) :
                StaggeredGridView.countBuilder(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 2,
                  padding: EdgeInsets.fromLTRB(2, 5, 2, 80),
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  staggeredTileBuilder: (_) => StaggeredTile.fit(1),
                  itemBuilder: (context, index){
                    return Card(
                      color: Colors.transparent,
                      elevation: 0,
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(
                              context, MaterialPageRoute(
                              builder: (context) => PostDetails(
                                profilePhoto: profilePhoto,
                                doc: snapshot.data.docs[index]['doc']
                              ))
                          );
                        },
                        onLongPress: (){
                          popUp = createPopUp(
                              snapshot.data.docs[index]['username'],
                              snapshot.data.docs[index]['photo']
                          );
                          Overlay.of(context).insert(popUp);
                        },
                        onLongPressEnd: (_){
                          popUp.remove();
                        },
                        behavior: HitTestBehavior.translucent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image(
                                image: NetworkImage(snapshot.data.docs[index]['photo']),
                              ),
                            ),
                            snapshot.data.docs[index]['caption'].toString().isNotEmpty ?
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: Text(snapshot.data.docs[index]['caption'],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ) : Container(),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}