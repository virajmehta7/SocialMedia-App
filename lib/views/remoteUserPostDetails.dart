import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'remoteUserProfile.dart';
import 'tabsPage/profileTabPage.dart';
import 'tag.dart';

class RemoteUserPostDetail extends StatefulWidget {
  final photo, time, tag, caption, doc, username, uid;
  const RemoteUserPostDetail({Key key,
    this.photo, this.time, this.tag, this.caption, this.doc, this.username, this.uid
  }) : super(key: key);

  @override
  _RemoteUserPostDetailState createState() => _RemoteUserPostDetailState();
}

class _RemoteUserPostDetailState extends State<RemoteUserPostDetail> {

  var profilePhoto;
  getData() async {
    DocumentSnapshot ds = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get();
    setState(() {
      profilePhoto = ds.get('profilePhoto');
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {

    DateTime dt = widget.time.toDate();
    var date = DateFormat('dd/MM/yyyy').format(dt);

    return Scaffold(
      appBar: AppBar(
        title: Text('Post',
          style: TextStyle(
              color: Colors.black,
              fontSize: 22
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: (){
                widget.username == FirebaseAuth.instance.currentUser.displayName ?
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileTabPage())) :
                Navigator.push(context, MaterialPageRoute(builder: (context) => RemoteUserProfile(
                  username: widget.username,
                  uid: widget.uid,
                )));
              },
              behavior: HitTestBehavior.translucent,
              child: Row(
                children: [
                  profilePhoto != null ?
                  Padding(
                    padding: EdgeInsets.fromLTRB(20,15,5,0),
                    child: CachedNetworkImage(
                      imageUrl: profilePhoto,
                      imageBuilder: (context, imageProvider) =>
                          CircleAvatar(
                            radius: 22,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                      errorWidget: (context, url, error) => Icon(Icons.error_outline),
                    )
                    // CircleAvatar(
                    //   radius: 22,
                    //   backgroundImage: NetworkImage(
                    //       profilePhoto
                    //   ),
                    // ),
                  ) :
                  Padding(
                    padding: EdgeInsets.fromLTRB(20,15,5,0),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundImage: AssetImage("assets/images/profile.png"),
                      backgroundColor: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(5,15,5,0),
                      child: Text(widget.username,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Divider(
                thickness: 1.5,
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(20,1,20,8),
              // decoration: BoxDecoration(
              //     boxShadow: [
              //       BoxShadow(
              //           offset: Offset(6,4),
              //           blurRadius: 5,
              //           color: Colors.grey
              //       )
              //     ]
              // ),
              child: CachedNetworkImage(
                imageUrl: widget.photo,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(
                      value: downloadProgress.progress,
                      color: Color(0xffb1325f),
                    ),
                errorWidget: (context, url, error) => Icon(Icons.error_outline),
              )
              // Image(
              //   image: NetworkImage(widget.photo),
              // ),
            ),
            Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.fromLTRB(15,1,20,5),
              child: Text(date,
                style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w300
                ),
              ),
            ),
            widget.tag.toString().isNotEmpty ?
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.fromLTRB(15,1,15,5),
              child: Wrap(
                direction: Axis.horizontal,
                spacing: 10,
                runSpacing: -5,
                children: List.from(widget.tag).map((val) {
                  return GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Tag(
                        tag: val.toString().substring(1),
                      )));
                    },
                    behavior: HitTestBehavior.translucent,
                    child: Chip(
                      label: Text(val),
                      labelStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                      backgroundColor: Color(0xffb1325f),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ) :
            Container(),
            widget.caption.toString().isNotEmpty ?
            Padding(
              padding: EdgeInsets.fromLTRB(20,0,20,30),
              child: Text(widget.caption,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ) :
            Container(),
          ],
        ),
      ),
    );
  }
}