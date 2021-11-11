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
  bool pressed = false;
  TextEditingController captionTextEditingController = TextEditingController();
  String url;
  String username = FirebaseAuth.instance.currentUser.displayName;
  String uid = FirebaseAuth.instance.currentUser.uid;
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.video)
    ..addListener(() => setState(() {}))
    ..setLooping(true)
    ..initialize()
        .then((_) => _controller.play());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                  .child(uid)
                  .child(uid+'-${DateTime.now().toString()}');
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
            Container(
              margin: EdgeInsets.all(30),
              child: GestureDetector(
                onTap: (){
                  setState(() {
                    pressed = true;
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                    } else {
                      _controller.play();
                    }
                    Future.delayed(Duration(seconds: 1)).then((value) => {
                      if(mounted)
                        setState(() {
                          pressed = false;
                        })
                    });
                  });
                },
                behavior: HitTestBehavior.translucent,
                child: _controller.value.isInitialized ?
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Stack(
                    children: [
                      VideoPlayer(_controller),
                      pressed ?
                      Align(
                        alignment: Alignment.center,
                        child: _controller.value.isPlaying ?
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Color(0xffb1325f),
                          child: Icon(Icons.pause),
                        ) :
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Color(0xffb1325f),
                          child: Icon(Icons.play_arrow),
                        ),
                      ) :
                      Container(),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          padding: EdgeInsets.all(10),
                          colors: VideoProgressColors(
                            playedColor: Color(0xffb1325f),
                          ),
                        ),
                      ),
                    ],
                  ),
                ) :
                Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
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