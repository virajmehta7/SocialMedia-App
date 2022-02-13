import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coolname/utils/colors.dart';
import 'package:coolname/views/remoteUserProfile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  final snapshot, roomId;
  const Chat({Key key, this.snapshot, this.roomId}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {

  TextEditingController message = TextEditingController();
  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: Duration(milliseconds: 1),
        curve: Curves.ease,
      );
    });
  }

  sendMessages(String msg, String by, String time) async {
    if(msg.trim().isNotEmpty){
      message.clear();
      await FirebaseFirestore.instance.collection('messages').doc(widget.roomId).update({
        'messages': FieldValue.arrayUnion([
          {
            'msg': msg,
            'by': by,
            'time': time
          }
        ])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            widget.snapshot['profilePhoto'] != null ?
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(widget.snapshot['profilePhoto']),
            ) :
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage("assets/images/profile.png"),
            ),
            SizedBox(width: 10,),
            Expanded(
              child: Text(widget.snapshot['username'],
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _controller,
            child: Column(
              children: [
                widget.snapshot['profilePhoto'] != null ?
                Container(
                  margin: EdgeInsets.only(top: 20, bottom: 8),
                  child: Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(widget.snapshot['profilePhoto']),
                    ),
                  ),
                ) :
                Container(
                  margin: EdgeInsets.only(top: 20, bottom: 8),
                  child: Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage("assets/images/profile.png"),
                    ),
                  ),
                ),
                Center(
                  child: Text(widget.snapshot['username'],
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 18
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10,10,10,15),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RemoteUserProfile(uid: widget.snapshot['uid'],username: widget.snapshot['username'],)));
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.width * 0.08,
                        width: MediaQuery.of(context).size.width * 0.3,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Center(
                          child: Text('View profile',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Divider(thickness: 1),
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('messages')
                      .doc(widget.roomId)
                      .snapshots(),
                  builder: (context, snapshot){
                    if(!snapshot.hasData){
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return ListView.builder(
                      itemCount: snapshot.data['messages'].length,
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      itemBuilder: (context, index){
                        return snapshot.data['messages'].isNotEmpty ?
                        MessageTile(
                          message: snapshot.data['messages'][index]['msg'],
                          byMe: FirebaseAuth.instance.currentUser.uid == snapshot.data['messages'][index]['by'] ? true : false,
                        )
                            : Container();
                      },
                    );
                  },
                ),
                SizedBox(height: 80),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        maxLines: 5,
                        minLines: 1,
                        keyboardType: TextInputType.multiline,
                        controller: message,
                        onSubmitted: (_){
                          sendMessages(message.text.trim(), FirebaseAuth.instance.currentUser.uid, DateTime.now().toString());
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Message...",
                        ),
                      ),
                    ),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: message,
                      builder: (context, value, child){
                        return value.text.trim().isNotEmpty ? InkWell(
                          onTap: (){
                            sendMessages(message.text.trim(), FirebaseAuth.instance.currentUser.uid, DateTime.now().toString());
                          },
                          child: Text('Send',
                            style: TextStyle(
                                color: light,
                                fontSize: 16,
                                fontWeight: FontWeight.w500
                            ),
                          ),
                        ) : Text('');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool byMe;

  MessageTile({@required this.message, @required this.byMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10,
        left: byMe ? 0 : MediaQuery.of(context).size.width*0.02,
        right: byMe ? MediaQuery.of(context).size.width*0.02 : 0,
      ),
      alignment: byMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: byMe ? EdgeInsets.only(left: MediaQuery.of(context).size.width*0.2) : EdgeInsets.only(right: MediaQuery.of(context).size.width*0.2),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
            borderRadius: byMe ? BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30)
            ) :
            BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30)
            ),
            gradient: LinearGradient(
              colors: byMe ? [light, mlight] : [mdark, mid],
            )
        ),
        child: Text(message,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}