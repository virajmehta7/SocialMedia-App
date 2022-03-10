import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coolname/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../chat.dart';

class ChatTabPage extends StatefulWidget {
  const ChatTabPage({Key key}) : super(key: key);

  @override
  _ChatTabPageState createState() => _ChatTabPageState();
}

class _ChatTabPageState extends State<ChatTabPage> {

  List users = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Chats',
          style: TextStyle(
              color: Colors.black,
              fontSize: 22
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('messages')
              .where('users', arrayContains: FirebaseAuth.instance.currentUser.uid)
              .snapshots(),
          builder: (context, snapshot){
            if(!snapshot.hasData)
              return Center(
                  child: CircularProgressIndicator(
                      color: mlight
                  )
              );

            users.clear();

            snapshot.data.docs.forEach((e){
              String name = e['username'];
              name.split('-').forEach((element) {
                if(element != FirebaseAuth.instance.currentUser.displayName){
                  users.add(element);
                }
              });
            });

            return snapshot.data.docs.length == 0 ?
            Center(
              child: Container(
                padding: EdgeInsets.only(top: 80),
                child: Column(
                  children: [
                    Icon(
                      Icons.message_outlined,
                      color: Colors.black,
                      size: 40,
                    ),
                    SizedBox(height: 8),
                    Text('No new messages',
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 22
                      ),
                    ),
                  ],
                ),
              ),
            ) : ListView.builder(
              itemCount: users.length,
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemBuilder: (context, index){
                return Container(
                  padding: EdgeInsets.all(10),
                  child: InkWell(
                    onTap: () async {
                      var uid;
                      String id = snapshot.data.docs[index]['roomId'];
                      id.split('-').forEach((element) {
                        if(element != FirebaseAuth.instance.currentUser.uid){
                          uid = element;
                        }
                      });
                      DocumentSnapshot ds =  await FirebaseFirestore.instance
                          .collection('users').doc(uid).get();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Chat(
                        snapshot: ds,
                        roomId: snapshot.data.docs[index]['roomId'],
                      )));
                      },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: mlight.withOpacity(0.5),
                          child: Text(users[index].toString().substring(0,1), style: TextStyle(fontSize: 30, color: mid),),
                        ),
                        SizedBox(width: 15),
                        Text(users[index],
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        Spacer(),
                        Text(DateFormat('hh:mm').format(snapshot.data.docs[index]['messages'].last['time'].toDate()),
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        )
      ),
    );
  }
}