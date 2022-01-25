import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coolname/utils/colors.dart';
import 'package:coolname/views/postDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class Saved extends StatefulWidget {
  const Saved({Key key}) : super(key: key);

  @override
  _SavedState createState() => _SavedState();
}

class _SavedState extends State<Saved> {

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
            // insetPadding: EdgeInsets.symmetric(vertical: 30, horizontal: 25),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Saved',
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
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('AllPosts')
              .where('saved', arrayContains: FirebaseAuth.instance.currentUser.uid)
              .snapshots(),
          builder: (context, snapshot){
            if(!snapshot.hasData)
              return Center(
                  child: CircularProgressIndicator(
                      color: mlight
                  )
              );
            return snapshot.data.docs.length == 0 ?
            Center(
              child: Container(
                padding: EdgeInsets.only(top: 80),
                child: Column(
                  children: [
                    Icon(
                      Icons.download,
                      color: Colors.black,
                      size: 45,
                    ),
                    SizedBox(height: 5),
                    Text('Nothing saved yet',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 24
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text('All the posts and items you\'ve saved will show up here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 18
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ) :
            StaggeredGridView.countBuilder(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 3,
              padding: EdgeInsets.fromLTRB(3, 5, 3, 80),
              itemCount: snapshot.data.docs.length,
              shrinkWrap: true,
              physics: ScrollPhysics(),
              staggeredTileBuilder: (_) => StaggeredTile.fit(1),
              itemBuilder: (context, index){
                return GestureDetector(
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
                  child: Card(
                    color: Colors.transparent,
                    elevation: 0,
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
                        Padding(
                          padding: EdgeInsets.fromLTRB(8,5,8,0),
                          child: Text(snapshot.data.docs[index]['username'],
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        snapshot.data.docs[index]['caption'].toString().isNotEmpty ?
                        Padding(
                          padding: EdgeInsets.fromLTRB(8,0,8,5),
                          child: Text(snapshot.data.docs[index]['caption'],
                            style: TextStyle(
                              color: Colors.grey.shade600,
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
        ),
      ),
    );
  }
}