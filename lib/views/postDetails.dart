import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coolname/utils/colors.dart';
import 'package:coolname/views/tag.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PostDetails extends StatefulWidget {
  final profilePhoto, doc;
  const PostDetails({Key key, this.profilePhoto, this.doc}) : super(key: key);

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
        ) :
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser.uid)
              .collection('posts')
              .doc(widget.doc)
              .snapshots(),
          builder: (context, snapshot){
            if(!snapshot.hasData)
              return Container();

            DateTime dt = snapshot.data['postedAt'].toDate();
            var date = DateFormat('dd/MM/yyyy').format(dt);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    widget.profilePhoto != null ?
                    Padding(
                      padding: EdgeInsets.fromLTRB(20,15,5,0),
                      child: CachedNetworkImage(
                        imageUrl: widget.profilePhoto,
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
                        radius: 20,
                        backgroundImage: AssetImage("assets/images/profile.png"),
                        backgroundColor: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(5,15,5,0),
                        child: Text(FirebaseAuth.instance.currentUser.displayName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.fromLTRB(5,15,20,0),
                      onPressed: () async {
                        setState(() {
                          loading = true;
                        });
                        try{
                          Navigator.pop(context);
                          await FirebaseFirestore.instance.runTransaction((Transaction myTransaction) async {
                            myTransaction.delete(snapshot.data.reference);
                          });
                          if(snapshot.data['tags'].toString().isNotEmpty){
                            snapshot.data['tags'].forEach((e) async {
                              await FirebaseFirestore.instance
                                  .collection('AllTags')
                                  .doc(e.toString().substring(1))
                                  .collection(e.toString().substring(1))
                                  .doc(widget.doc)
                                  .delete();
                            });
                          }
                          await FirebaseFirestore.instance
                              .collection('AllPosts')
                              .doc(widget.doc)
                              .delete();
                        } catch(e) {
                          setState(() {
                            loading = false;
                          });
                        }
                      },
                      icon: Icon(Icons.delete),
                    ),
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
                    imageUrl: snapshot.data['photo'],
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
                snapshot.data['caption'].toString().isNotEmpty ?
                Padding(
                  padding: EdgeInsets.fromLTRB(20,0,20,30),
                  child: convertHashtag(snapshot.data['caption'])
                ) :
                Container(),
              ],
            );
          },
        )
      ),
    );
  }
}