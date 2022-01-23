import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coolname/utils/colors.dart';
import 'package:coolname/views/remoteUserProfile.dart';
import 'package:coolname/views/tabsPage/profileTabPage.dart';
import 'package:coolname/views/tag.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PostDetails extends StatefulWidget {
  final snapshot;
  const PostDetails({Key key, this.snapshot}) : super(key: key);

  @override
  _PostDetailsState createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {

  bool loading = false;

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

  @override
  Widget build(BuildContext context) {
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
        child: loading ?
        Container(
          padding: EdgeInsets.only(top: 50),
          alignment: Alignment.center,
          child: CircularProgressIndicator(
            color: mlight,
          ),
        ) : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      widget.snapshot['uid'] == FirebaseAuth.instance.currentUser.uid ?
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileTabPage())) :
                      Navigator.push(context, MaterialPageRoute(builder: (context) => RemoteUserProfile(
                        username: widget.snapshot['username'],
                        uid: widget.snapshot['uid'],
                      )));
                    },
                    behavior: HitTestBehavior.translucent,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20,15,5,0),
                      child: Text(widget.snapshot['username'],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                  ),
                ),
                widget.snapshot['uid'] == FirebaseAuth.instance.currentUser.uid ?
                IconButton(
                  padding: EdgeInsets.fromLTRB(5,15,20,0),
                  onPressed: () async {
                    setState(() {
                      loading = true;
                    });
                    try{
                      Navigator.pop(context);

                      await FirebaseFirestore.instance
                          .collection('AllPosts')
                          .doc(widget.snapshot['doc'])
                          .delete();

                      if(widget.snapshot['tags'].toString().isNotEmpty){
                        widget.snapshot['tags'].forEach((e) async {
                          await FirebaseFirestore.instance
                              .collection('AllTags')
                              .doc(e.toString().substring(1))
                              .collection(e.toString().substring(1))
                              .doc(widget.snapshot['doc'])
                              .delete();
                        });
                      }
                    } catch(e) {
                      setState(() {
                        loading = false;
                      });
                    }
                  },
                  icon: Icon(Icons.delete),
                ) : Container(),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Divider(
                thickness: 0.8,
              ),
            ),
            Container(
                margin: EdgeInsets.fromLTRB(20,1,20,8),
                child: CachedNetworkImage(
                  imageUrl: widget.snapshot['photo'],
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
              child: Text(DateFormat('dd/MM/yyyy').format(widget.snapshot['postedAt'].toDate()),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            widget.snapshot['caption'].toString().isNotEmpty ?
            Padding(
                padding: EdgeInsets.fromLTRB(20,0,20,30),
                child: convertHashtag(widget.snapshot['caption'])
            ) :
            Container(),
          ],
        ),
      ),
    );
  }
}