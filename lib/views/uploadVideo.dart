import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class UploadVideo extends StatefulWidget {
  final video;
  const UploadVideo({Key key, this.video}) : super(key: key);

  @override
  _UploadVideoState createState() => _UploadVideoState();
}

class _UploadVideoState extends State<UploadVideo> {

  bool loading = false;

  TextEditingController captionTextEditingController = TextEditingController();
  TextEditingController tagsTextEditingController = TextEditingController();
  VideoPlayerController videoPlayerController;

  String url;
  String username = FirebaseAuth.instance.currentUser.displayName;
  String uid = FirebaseAuth.instance.currentUser.uid;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.file(widget.video);
    videoPlayerController.initialize().then((_) {
      setState(() {});
    });
    videoPlayerController.setLooping(true);
    videoPlayerController.play();
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Video',
          style: TextStyle(
              color: Colors.black
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: (){
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.done,
              color: Color(0xffb1325f),
            ),
            onPressed: (){
              setState(() {
                loading = true;
              });
              Reference ref = FirebaseStorage.instance
                  .ref()
                  .child('videos')
                  .child(username)
                  .child(username+'-${DateTime.now().toString()}');
              UploadTask task = ref.putFile(widget.video);
              task.whenComplete(() async {
                url = await ref.getDownloadURL();
                var doc = FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser.uid)
                    .collection('videos')
                    .doc();
                await doc.set({
                  'username': username,
                  'video': url,
                  'caption': captionTextEditingController.text.trim(),
                  'doc': doc.id,
                  'uid': uid,
                  'postedAt': Timestamp.now(),
                });
                await FirebaseFirestore.instance
                    .collection('AllVideos')
                    .doc(doc.id)
                    .set({
                  'username': username,
                  'video': url,
                  'caption': captionTextEditingController.text.trim(),
                  'doc': doc.id,
                  'uid': uid,
                  'postedAt': Timestamp.now(),
                });
                Navigator.pop(context);
                Navigator.pop(context);
              }).catchError((e){
                setState(() {
                  loading = false;
                });
              });
            },
          )
        ],
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
        Column(
          children: [
            GestureDetector(
              onTap: (){
                setState(() {
                  videoPlayerController.value.isPlaying
                      ? videoPlayerController.pause()
                      : videoPlayerController.play();
                });
              },
              behavior: HitTestBehavior.translucent,
              child: Container(
                margin: EdgeInsets.fromLTRB(30,30,30,20),
                height: MediaQuery.of(context).size.height*0.5,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    videoPlayerController.value.isInitialized ?
                    AspectRatio(
                      aspectRatio: videoPlayerController.value.aspectRatio,
                      child: VideoPlayer(videoPlayerController),
                    ) :
                    Container(),
                    videoPlayerController.value.isPlaying ?
                    Icon(Icons.pause, size: 30, color: Colors.white,) :
                    Icon(Icons.play_arrow, size: 30, color: Colors.white,),
                  ],
                ),
              ),
            ),
            Divider(
              thickness: 1,
            ),
            Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: TextField(
                  controller: captionTextEditingController,
                  style: TextStyle(fontSize: 18),
                  maxLines: null,
                  decoration: InputDecoration(
                      hintText: "Write a caption...",
                      hintStyle: TextStyle(fontSize: 16)
                  ),
                )
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}