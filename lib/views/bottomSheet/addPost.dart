import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../uploadPost.dart';

class AddPost extends StatefulWidget {
  const AddPost({Key key}) : super(key: key);

  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {

  var post;

  cropImage(ImageSource source) async {
    final tempImage = await ImagePicker().pickImage(source: source, imageQuality: 95);
    if(tempImage != null) {
      File croppedPhoto = await ImageCropper.cropImage(
          sourcePath: tempImage.path,
          compressQuality: 100,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
            toolbarTitle: "Edit photo",
            toolbarColor: Colors.white,
            toolbarWidgetColor: Color(0xffb1325f),
            activeControlsWidgetColor: Color(0xffb1325f),
          )
      );
      setState(() {
        post = croppedPhoto;
      });
      if(post != null){
        Navigator.push(
            context, MaterialPageRoute(
            builder: (context) => UploadPost(post: post))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.drag_handle_rounded,
            size: 30,
            color: Colors.white,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(20),
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
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.grey.shade300,
                        child: Icon(
                          Icons.photo,
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
                  onTap: () {
                    cropImage(ImageSource.gallery);
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
                          Icons.camera_alt,
                          size: 26,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 15),
                      Text("Take photo",
                          style: TextStyle(fontSize: 18)
                      ),
                    ],
                  ),
                  onTap: () {
                    cropImage(ImageSource.camera);
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