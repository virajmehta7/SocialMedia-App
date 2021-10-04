import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../remoteUserPostDetails.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({Key key}) : super(key: key);

  @override
  _HomeTabPageState createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {

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
                        color: Color(0xffb1325f),
                      ),
                  errorWidget: (context, url, error) => Icon(Icons.error_outline),
                ),
              ),
              // ClipRRect(
              //   borderRadius: BorderRadius.only(
              //     bottomLeft: Radius.circular(20),
              //     bottomRight: Radius.circular(20)
              //   ),
              //   child: Image.network(photo),
              // ),
            ],
          ),
        )
    );
  }

  OverlayEntry popUp;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, bool isScrolled) {
            return [
              SliverAppBar(
                title: Text('Posts',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 22
                  ),
                ),
                centerTitle: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
            ];
          },
          body: SingleChildScrollView(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('AllPosts')
                  .orderBy("postedAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot){
                if(!snapshot.hasData)
                  return Center(
                      child: CircularProgressIndicator(
                          color: Color(0xffb1325f)
                      )
                  );
                return StaggeredGridView.countBuilder(
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
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RemoteUserPostDetail(
                          photo: snapshot.data.docs[index]['photo'],
                          time: snapshot.data.docs[index]['postedAt'],
                          caption: snapshot.data.docs[index]['caption'],
                          tag: snapshot.data.docs[index]['tags'],
                          doc: snapshot.data.docs[index]['doc'],
                          username: snapshot.data.docs[index]['username'],
                          uid: snapshot.data.docs[index]['uid'],
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
                            // ClipRRect(
                            //   borderRadius: BorderRadius.circular(20),
                            //   child: Image(
                            //     image: NetworkImage(snapshot.data.docs[index]['photo']),
                            //   ),
                            // ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: CachedNetworkImage(
                                imageUrl: snapshot.data.docs[index]['photo'],
                                progressIndicatorBuilder: (context, url, downloadProgress) =>
                                  CircularProgressIndicator(
                                    value: downloadProgress.progress,
                                    color: Color(0xffb1325f),
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
        ),
      ),
    );
  }
}