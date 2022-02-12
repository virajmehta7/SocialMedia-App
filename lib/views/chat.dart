import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  final snapshot;
  const Chat({Key key, this.snapshot}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
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
      body: SingleChildScrollView(
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
            widget.snapshot['name'] != "" ?
            Center(
              child: Text(widget.snapshot['name'],
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                ),
              ),
            ) :
            Container(),
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
                padding: EdgeInsets.fromLTRB(10,20,10,15),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: (){
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => RemoteUserProfile()));
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.width * 0.09,
                    width: MediaQuery.of(context).size.width * 0.35,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Center(
                      child: Text('View profile',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
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
            )
          ],
        ),
      ),
    );
  }
}