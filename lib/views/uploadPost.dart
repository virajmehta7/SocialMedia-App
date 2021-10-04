import 'package:cloud_firestore/cloud_firestore.dart';
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
  TextEditingController tagsTextEditingController = TextEditingController();

  var tags = <String>{};
  var tagsList = <dynamic>[];

  String url;
  String username = FirebaseAuth.instance.currentUser.displayName;
  String uid = FirebaseAuth.instance.currentUser.uid;

  bool loading = false;

  addTag() {
    if (tagsTextEditingController.text.trim() == null || tagsTextEditingController.text.trim() == '') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Invalid tag',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xffb1325f),
        duration: Duration(seconds: 1),
      ));
      return;
    }
    setState(() {
      tags.add("#"+tagsTextEditingController.text.trim().toLowerCase());
      tagsList.add("#"+tagsTextEditingController.text.trim().toLowerCase());
    });
    tagsTextEditingController.clear();
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
                  .child('posts')
                  .child(username)
                  .child(username+'-${DateTime.now().toString()}');
              UploadTask task = ref.putFile(widget.post);
              task.whenComplete(() async {
                url = await ref.getDownloadURL();
                var doc = FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser.uid)
                    .collection('posts')
                    .doc();
                await doc.set({
                  'username': username,
                  'photo': url,
                  'caption': captionTextEditingController.text.trim(),
                  'doc': doc.id,
                  'uid': uid,
                  'postedAt': Timestamp.now(),
                  'tags': []
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
                await FirebaseFirestore.instance
                    .collection('AllPosts')
                    .doc(doc.id)
                    .set({
                  'username': username,
                  'photo': url,
                  'caption': captionTextEditingController.text.trim(),
                  'doc': doc.id,
                  'uid': uid,
                  'postedAt': Timestamp.now(),
                  'tags': FieldValue.arrayUnion(tagsList),
                });
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
            color: Color(0xffb1325f),
          ),
        ) :
        Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(30,30,30,20),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(6,4),
                    blurRadius: 3,
                  )
                ],
              ),
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
            Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: TextField(
                  controller: tagsTextEditingController,
                  style: TextStyle(fontSize: 18),
                  onSubmitted: (_){
                    addTag();
                  },
                  decoration: InputDecoration(
                      hintText: "Add tags...",
                      hintStyle: TextStyle(fontSize: 16),
                      suffixIcon: IconButton(
                        color: Color(0xffb1325f),
                        icon: Icon(Icons.add_circle_outline),
                        iconSize: 26,
                        onPressed: addTag,
                      )
                  ),
                )
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.fromLTRB(15,5,15,30),
              child: Wrap(
                direction: Axis.horizontal,
                spacing: 10,
                runSpacing: -5,
                children: tags.map((val) {
                  return Chip(
                    label: Text(val),
                    labelStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                    deleteIcon: Icon(
                      Icons.close,
                      size: 20,
                    ),
                    deleteIconColor: Colors.white,
                    backgroundColor: Color(0xffb1325f),
                    elevation: 8,
                    padding: EdgeInsets.all(8),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    onDeleted: () {
                      setState(() {
                        tags.remove(val);
                        tagsList.remove(val);
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}