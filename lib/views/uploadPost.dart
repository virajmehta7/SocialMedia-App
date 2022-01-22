import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coolname/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UploadPost extends StatefulWidget {
  final post;
  const UploadPost({Key key, this.post}) : super(key: key);

  @override
  _UploadPostState createState() => _UploadPostState();
}

class _UploadPostState extends State<UploadPost> {

  TextEditingController captionTextEditingController = TextEditingController();

  var tags = <String>{};
  var tagsList = <dynamic>[];
  String url;
  String username = FirebaseAuth.instance.currentUser.displayName;
  String uid = FirebaseAuth.instance.currentUser.uid;
  // RegExp exp = RegExp(r"\B#\w\w+");
  bool loading = false;

  addTag(String text) {
    setState(() {
      tags.add(text.toLowerCase());
      tagsList.add(text.toLowerCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Post',
          style: TextStyle(
            color: Colors.black
          ),
        ),
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
          loading ? IconButton(
            icon: Icon(
              Icons.done,
              color: mlight,
            ),
            onPressed: (){},
          ) :
          IconButton(
            icon: Icon(
              Icons.done,
              color: mlight,
            ),
            onPressed: (){
              setState(() {
                loading = true;
              });

              List splitTags = captionTextEditingController.text.trim().split(" ");
              for (var item in splitTags) {
                if (item.startsWith("#")) {
                  addTag(item);
                }
              }

              Reference ref = FirebaseStorage.instance
                  .ref()
                  .child('posts')
                  .child(uid)
                  .child(uid+'-${DateTime.now().toString()}');
              UploadTask task = ref.putFile(widget.post);
              task.whenComplete(() async {
                url = await ref.getDownloadURL();

                var doc =  FirebaseFirestore.instance
                    .collection('AllPosts')
                    .doc();

                    await doc.set({
                      'username': username,
                      'photo': url,
                      'caption': captionTextEditingController.text.trim(),
                      'uid': uid,
                      'postedAt': Timestamp.now(),
                      'tags': FieldValue.arrayUnion(tagsList),
                      'doc': doc.id,
                    }).then((value) async => {
                      if(tagsList.isNotEmpty){
                        await doc.update({
                          'tags': FieldValue.arrayUnion(tagsList)
                        })
                      }
                    });
                if(tags.isNotEmpty){
                  tags.forEach((element) async {
                    var doc1 = FirebaseFirestore.instance
                        .collection('AllTags')
                        .doc(element.substring(1));
                    doc1.set(
                        {
                          'tag' : element.substring(1)
                        },
                        SetOptions(merge: true)
                    );
                    doc1.collection(element.substring(1))
                        .doc(doc.id)
                        .set({
                      'username': username,
                      'photo': url,
                      'caption': captionTextEditingController.text.trim(),
                      'doc': doc.id,
                      'uid': uid,
                      'postedAt': Timestamp.now(),
                      'tags': FieldValue.arrayUnion(tagsList)
                    });
                  });
                }

                Navigator.pop(context);
                Navigator.pop(context);
              }).catchError((e){
                setState(() {
                  loading = false;
                });
              });
            },
          ),
        ],
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
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
        Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(30,30,30,20),
              child: Image(
                image: FileImage(widget.post),
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
          ],
        ),
      ),
    );
  }
}