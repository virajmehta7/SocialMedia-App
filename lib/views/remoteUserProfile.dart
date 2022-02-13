import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coolname/services/database.dart';
import 'package:coolname/utils/colors.dart';
import 'package:coolname/views/chat.dart';
import 'package:coolname/views/postDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class RemoteUserProfile extends StatefulWidget {
  final username, uid;
  const RemoteUserProfile({Key key, this.username, this.uid}) : super(key: key);

  @override
  _RemoteUserProfileState createState() => _RemoteUserProfileState();
}

class _RemoteUserProfileState extends State<RemoteUserProfile> {

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
                child: CachedNetworkImage(
                  imageUrl: photo,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                        value: downloadProgress.progress,
                        color: mlight,
                      ),
                  errorWidget: (context, url, error) => Icon(Icons.error_outline),
                ),
              ),
            ],
          ),
        )
    );
  }

  OverlayEntry popUp;
  DatabaseMethods databaseMethods = new DatabaseMethods();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.username,
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.uid)
                  .snapshots(),
              builder: (context, snapshot){
                if(!snapshot.hasData)
                  return Center(
                      child: CircularProgressIndicator(
                          color: mlight
                      )
                  );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    snapshot.data['profilePhoto'] != null ?
                    Container(
                        margin: EdgeInsets.only(top: 20, bottom: 5),
                        child: CachedNetworkImage(
                          imageUrl: snapshot.data['profilePhoto'],
                          imageBuilder: (context, imageProvider) =>
                              Center(
                                child: CircleAvatar(
                                  radius: 60,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                    ),
                                  ),
                                ),
                              ),
                          errorWidget: (context, url, error) => Icon(Icons.error_outline),
                        )
                    ) :
                    Container(
                      margin: EdgeInsets.only(top: 20, bottom: 8),
                      child: Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage("assets/images/profile.png"),
                        ),
                      ),
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
                    Center(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10,20,10,8),
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () async {

                            final a = await databaseMethods
                                .roomIdCheck(FirebaseAuth.instance.currentUser.uid+'-'+snapshot.data['uid']);

                            final b = await databaseMethods
                                .roomIdCheck(snapshot.data['uid']+'-'+FirebaseAuth.instance.currentUser.uid);

                            if(a==true && b==false){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Chat(
                                snapshot: snapshot.data,
                                roomId: FirebaseAuth.instance.currentUser.uid+'-'+snapshot.data['uid'],
                              )));
                            }

                            else if(a==false && b==true){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Chat(
                                snapshot: snapshot.data,
                                roomId: snapshot.data['uid']+'-'+FirebaseAuth.instance.currentUser.uid,
                              )));
                            }

                            else{
                              await FirebaseFirestore.instance
                                  .collection('messages')
                                  .doc(FirebaseAuth.instance.currentUser.uid+'-'+snapshot.data['uid'])
                                  .set({
                                'roomId': FirebaseAuth.instance.currentUser.uid+'-'+snapshot.data['uid'],
                                'users': [FirebaseAuth.instance.currentUser.uid, snapshot.data['uid']],
                                if(a==false && b==false)
                                  'messages': []
                              }, SetOptions(merge: true))
                                  .then((value) => {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => Chat(
                                  snapshot: snapshot.data,
                                  roomId: FirebaseAuth.instance.currentUser.uid+'-'+snapshot.data['uid'],
                                ))),
                              });
                            }

                          },
                          child: Container(
                            height: MediaQuery.of(context).size.width * 0.1,
                            width: MediaQuery.of(context).size.width * 0.8,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey)
                            ),
                            child: Center(
                              child: Text('Message',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
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
                  .collection('AllPosts')
                  .where('uid', isEqualTo: widget.uid)
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
                      Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.black,
                        size: 45,
                      ),
                      SizedBox(height: 8),
                      Text('No Posts Yet',
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 22
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
                          Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetails(
                            snapshot: snapshot.data.docs[index],
                          )));
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
                              child: CachedNetworkImage(
                                imageUrl: snapshot.data.docs[index]['photo'],
                                progressIndicatorBuilder: (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                      value: downloadProgress.progress,
                                      color: mlight,
                                    ),
                                errorWidget: (context, url, error) => Icon(Icons.error_outline),
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