import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../editProfilePage.dart';
import '../welcome.dart';

class More extends StatefulWidget {
  const More({Key key}) : super(key: key);

  @override
  _MoreState createState() => _MoreState();
}

class _MoreState extends State<More> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(20, 5, 20, 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.1,
                      child: Divider(
                        thickness: 3,
                        color: Colors.grey.shade400,
                      ),
                    )
                ),
                // GestureDetector(
                //   behavior: HitTestBehavior.translucent,
                //   child: Row(
                //     children: [
                //       CircleAvatar(
                //         radius: 22,
                //         backgroundColor: Colors.grey.shade300,
                //         child: Icon(
                //           Icons.arrow_circle_down,
                //           size: 26,
                //           color: Colors.black,
                //         ),
                //       ),
                //       SizedBox(width: 15),
                //       Text('Saved',
                //         style: TextStyle(
                //           fontSize: 18,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // SizedBox(height: 10),
                GestureDetector(
                  onTap: (){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => EditProfilePage())
                    );
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.grey.shade300,
                        child: Icon(
                          Icons.edit,
                          size: 26,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 15),
                      Text('Edit profile',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.remove('email');
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => Welcome())
                    );
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.grey.shade300,
                        child: Icon(
                          Icons.logout,
                          size: 26,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 15),
                      Text('Logout',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}