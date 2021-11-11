import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coolname/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'remoteUserProfile.dart';
import 'tabsPage/profileTabPage.dart';
import 'tag.dart';

class RemoteUserPostDetail extends StatefulWidget {
  final photo, time, caption, doc, username, uid;
  const RemoteUserPostDetail({Key key,
    this.photo, this.time, this.caption, this.doc, this.username, this.uid
  }) : super(key: key);

  @override
  _RemoteUserPostDetailState createState() => _RemoteUserPostDetailState();
}

class _RemoteUserPostDetailState extends State<RemoteUserPostDetail> {

  var profilePhoto;

  RichText convertHashtag(String text) {
    List<String> split = text.split(" ");
    List<String> hashtags = split.getRange(0, split.length).fold([], (t, e) {
      var texts = e.split(" ");
      if (texts.length > 1) {
        return List.from(t)
          ..addAll(["${texts.first}", "${e.substring(texts.first.length)}"]);
      }
      return List.from(t)
        ..add("${texts.first}");
    });

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: "")
        ]
          ..addAll(
            hashtags.map((text) => text.contains("#") ?
            TextSpan(text: text + " ",
              style: TextStyle(
                color: mlight,
                fontSize: 16,
              ),
              recognizer: TapGestureRecognizer()..onTap = (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => Tag(
                  tag: text.toString().substring(1),
                )));
              },
            ) :
            TextSpan(text: text + " ",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                )
            )
            ).toList(),
          ),
      ),
    );
  }

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
                            radius: 20,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                      errorWidget: (context, url, error) => Icon(Icons.error_outline),
                    )
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
              child: CachedNetworkImage(
                imageUrl: widget.photo,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(
                      value: downloadProgress.progress,
                      color: mlight,
                    ),
                errorWidget: (context, url, error) => Icon(Icons.error_outline),
              )
            ),
            Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.fromLTRB(15,1,20,5),
              child: Text(date,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            widget.caption.toString().isNotEmpty ?
            Padding(
                padding: EdgeInsets.fromLTRB(20,0,20,30),
                child: convertHashtag(widget.caption)
            ) :
            Container(),
          ],
        ),
      ),
    );
  }
}