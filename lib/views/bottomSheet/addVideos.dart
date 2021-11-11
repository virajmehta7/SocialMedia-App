import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../uploadVideo.dart';

class AddVideos extends StatefulWidget {
  const AddVideos({Key key}) : super(key: key);

  @override
  _AddVideosState createState() => _AddVideosState();
}

class _AddVideosState extends State<AddVideos> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(20, 1, 20, 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Icon(
                    Icons.drag_handle_rounded,
                    size: 30,
                    color: Colors.grey,
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.grey.shade300,
                        child: Icon(
                          Icons.video_collection,
                          size: 26,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 15),
                      Text("Choose from gallery",
                          style: TextStyle(fontSize: 18)
                      ),
                    ],
                  ),
                  onTap: () async {
                    final video = await ImagePicker().pickVideo(source: ImageSource.gallery, maxDuration: Duration(seconds: 15));
                    if(video != null){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => UploadVideo(video: File(video.path),)));
                    }
                  },
                ),
                SizedBox(height: 10),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.grey.shade300,
                        child: Icon(
                          Icons.videocam,
                          size: 26,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 15),
                      Text("Take video",
                          style: TextStyle(fontSize: 18)
                      ),
                    ],
                  ),
                  onTap: () async {
                    final video = await ImagePicker().pickVideo(source: ImageSource.camera, maxDuration: Duration(seconds: 15));
                    if(video != null){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => UploadVideo(video: File(video.path),)));
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
