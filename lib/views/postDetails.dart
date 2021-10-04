import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'tag.dart';

class PostDetails extends StatefulWidget {
  final profilePhoto, doc;
  const PostDetails({Key key, this.profilePhoto, this.doc}) : super(key: key);

  @override
  _PostDetailsState createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {

  bool loading = false;

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
            color: Color(0xffb1325f),
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
                      //       widget.profilePhoto
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
                        child: Text(FirebaseAuth.instance.currentUser.displayName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 20,
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
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Divider(
                    thickness: 1.5,
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(20,1,20,8),
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(6,4),
                            blurRadius: 5,
                            color: Colors.grey
                        )
                      ]
                  ),
                  child: CachedNetworkImage(
                    imageUrl: snapshot.data['photo'],
                    progressIndicatorBuilder: (context, url, downloadProgress) =>
                        CircularProgressIndicator(
                          value: downloadProgress.progress,
                          color: Color(0xffb1325f),
                        ),
                    errorWidget: (context, url, error) => Icon(Icons.error_outline),
                  )
                  // Image(
                  //   image: NetworkImage(
                  //       snapshot.data['photo']
                  //   ),
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
                snapshot.data['tags'].toString().isNotEmpty ?
                Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.fromLTRB(15,1,15,5),
                  child: Wrap(
                    direction: Axis.horizontal,
                    spacing: 10,
                    runSpacing: -5,
                    children: List.from(snapshot.data['tags']).map((val) {
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
                snapshot.data['caption'].toString().isNotEmpty ?
                Padding(
                  padding: EdgeInsets.fromLTRB(20,0,20,30),
                  child: Text(snapshot.data['caption'],
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
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