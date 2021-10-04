import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'changePassword.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  var profileBgPhoto;
  var profilePhoto;
  var email = '';
  var name = '';
  var username = '';
  var bio = '';

  var profilePic;
  var profileBgPic;

  String url1;
  String url2;

  bool loading = false;

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController bioTextEditingController = TextEditingController();

  cropImage(ImageSource source) async {
    final tempImage = await ImagePicker().pickImage(source: source, imageQuality: 90);
    if(tempImage != null) {
      File croppedFile = await ImageCropper.cropImage(
          sourcePath: tempImage.path,
          aspectRatio: CropAspectRatio(ratioX: 4, ratioY: 1.5),
          compressQuality: 100,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: "Edit Photo",
              toolbarColor: Colors.white,
              toolbarWidgetColor: Colors.blue,
              activeControlsWidgetColor: Colors.blue
          )
      );
      setState(() {
        profileBgPic = croppedFile;
      });
    }
  }

  getData() async {
    DocumentSnapshot ds = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();

    setState(() {
      profileBgPhoto = ds.get('profileBgPhoto');
      profilePhoto = ds.get('profilePhoto');
      email = ds.get('email');
      name = ds.get('name');
      username = ds.get('username');
      bio = ds.get('bio');

      nameTextEditingController.text = name;
      bioTextEditingController.text = bio;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
              Icons.check,
              color: Color(0xffb1325f),
            ),
            onPressed: () async {
              setState(() {
                loading = true;
              });
              if(profilePic != null){
                Reference ref = FirebaseStorage.instance
                    .ref()
                    .child('profilePhoto')
                    .child(username)
                    .child(username+'-${DateTime.now().toString()}');
                UploadTask task = ref.putFile(profilePic);
                task.whenComplete(() async {
                  url1 = await ref.getDownloadURL();
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser.uid)
                      .update({
                    'profilePhoto' : url1
                  });
                }).catchError((e){
                  setState(() {
                    loading = false;
                  });
                });
              }
              if(profileBgPic != null){
                Reference ref = FirebaseStorage.instance
                    .ref()
                    .child('profileBgPhoto')
                    .child(username)
                    .child(username+'-${DateTime.now().toString()}');
                UploadTask task = ref.putFile(profileBgPic);
                task.whenComplete(() async {
                  url2 = await ref.getDownloadURL();
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser.uid)
                      .update({
                    'profileBgPhoto' : url2
                  });
                }).catchError((e){
                  setState(() {
                    loading = false;
                  });
                });
              }
              if(profileBgPic == null && profileBgPhoto == null){
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser.uid)
                    .update({
                  'profileBgPhoto' : null
                });
              }
              if(profilePic == null && profilePhoto == null){
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser.uid)
                    .update({
                  'profilePhoto' : null
                });
              }
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser.uid)
                  .update({
                'bio' : bioTextEditingController.text.trim(),
                'name' : nameTextEditingController.text.trim(),
              });
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: loading ?
        Padding(
          padding: EdgeInsets.only(top: 50),
          child: Center(
            child: CircularProgressIndicator(
              color: Color(0xffb1325f),
            ),
          ),
        ) :
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: (){
                    showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (context) {
                          return Column(
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
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
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
                                      onTap: () async {
                                        cropImage(ImageSource.gallery);
                                        Navigator.pop(context);
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
                                      onTap: () async {
                                        cropImage(ImageSource.camera);
                                        Navigator.pop(context);
                                      },
                                    ),
                                    SizedBox(height: 10),
                                    if(profileBgPic != null || profileBgPhoto != null)
                                      GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 22,
                                              backgroundColor: Colors.grey.shade300,
                                              child: Icon(
                                                Icons.close,
                                                size: 26,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(width: 15),
                                            Text("Remove photo",
                                                style: TextStyle(fontSize: 18)
                                            ),
                                          ],
                                        ),
                                        onTap: () async {
                                          setState(() {
                                            profileBgPhoto = null;
                                            profileBgPic = null;
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                    );
                  },
                  child: profileBgPic == null ?
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 150,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: profileBgPhoto != null ? NetworkImage(profileBgPhoto) : AssetImage("assets/images/bg.jpg"),
                            fit: BoxFit.fitWidth
                        )
                    ),
                  ) :
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 150,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(profileBgPic),
                        fit: BoxFit.fitWidth
                      )
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) {
                        return Column(
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
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30),
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
                                    onTap: () async {
                                      var tempImage = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 75);
                                      setState(() {
                                        profilePic = File(tempImage.path);
                                      });
                                      Navigator.pop(context);
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
                                    onTap: () async {
                                      var tempImage = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 75);
                                      setState(() {
                                        profilePic = File(tempImage.path);
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                  SizedBox(height: 10),
                                  if(profilePic != null || profilePhoto != null)
                                    GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 22,
                                            backgroundColor: Colors.grey.shade300,
                                            child: Icon(
                                              Icons.close,
                                              size: 26,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(width: 15),
                                          Text("Remove photo",
                                              style: TextStyle(fontSize: 18)
                                          ),
                                        ],
                                      ),
                                      onTap: () async {
                                        setState(() {
                                          profilePhoto = null;
                                          profilePic = null;
                                        });
                                        Navigator.pop(context);
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    );
                  },
                  child: profilePic == null ?
                  Container(
                    margin: EdgeInsets.only(top: 80, bottom: 5),
                    child: Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        backgroundImage: profilePhoto != null ? NetworkImage(profilePhoto) : AssetImage("assets/images/profile.png"),
                      ),
                    ),
                  ) :
                  Container(
                    margin: EdgeInsets.only(top: 80, bottom: 8),
                    child: Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        backgroundImage: FileImage(profilePic),
                      ),
                    ),
                  ),
                )
              ],
            ),
            Center(
              child: Text("@"+username,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
              ),
            ),
            SizedBox(height: 12),
            Divider(
              thickness: 1,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
              child: Text("Name",
                style: TextStyle(fontSize: 16),
              ),
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: TextField(
                  controller: nameTextEditingController,
                  style: TextStyle(fontSize: 18),
                )
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 18, 15, 0),
              child: Text("Bio",
                style: TextStyle(fontSize: 16),
              ),
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: TextField(
                  controller: bioTextEditingController,
                  style: TextStyle(fontSize: 18),
                  maxLength: 180,
                  maxLines: null,
                )
            ),
            SizedBox(height: 12),
            Divider(
              thickness: 1,
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, top: 5),
              child: Text("Private Information",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 20, 0 ,0),
              child: Text("Email address",
                style: TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 0, 10),
              child: Text(email,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(height: 10),
            Divider(
              thickness: 1,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 5, 0, 10),
              child: GestureDetector(
                onTap: (){
                  Navigator.push(
                      context, MaterialPageRoute(
                      builder: (context) => ChangePassword())
                  );
                },
                child: Row(
                  children: [
                    Text('Change password',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Icon(
                      Icons.arrow_right,
                      size: 30,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}