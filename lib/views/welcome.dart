import 'package:flutter/material.dart';
import 'bottomSheet/login.dart';
import 'bottomSheet/signup.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key key}) : super(key: key);

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {

  // final googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xffDA4453),
                Color(0xffb1325f),
                Color(0xff89216B)
              ]
            )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Spacer(),
              Padding(
                padding: EdgeInsets.fromLTRB(35, 0, 35, 5),
                child: Text('Let\'s Get \nStarted',
                  style: TextStyle(
                    fontSize: 46,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(35, 5, 35, 40),
                child: Text('Share everything \nFor everyone',
                  style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontFamily: 'Caveat'
                  ),
                ),
              ),
              Container(
                height: 76,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(10),
                child: ElevatedButton(
                  child: Text('LOGIN',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w300
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black.withOpacity(0.1),
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: (){
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) => LoginBottomSheet(),
                    );
                  },
                ),
              ),
              Container(
                height: 76,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(10),
                child: ElevatedButton(
                  child: Text('SIGN UP',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w300
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black.withOpacity(0.6),
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: (){
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) => SignUpBottomSheet(),
                    );
                  },
                ),
              ),
              // Container(
              //   height: 76,
              //   width: MediaQuery.of(context).size.width,
              //   padding: EdgeInsets.all(10),
              //   child: ElevatedButton(
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       crossAxisAlignment: CrossAxisAlignment.center,
              //       children: [
              //         CircleAvatar(
              //           radius: 15,
              //           backgroundColor: Colors.transparent,
              //           child: Image.asset('assets/images/google.png'),
              //         ),
              //         Padding(
              //           padding: EdgeInsets.only(left: 8),
              //           child: Text('Continue with Google',
              //             style: TextStyle(
              //                 fontSize: 18,
              //                 fontWeight: FontWeight.w300
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //     style: ElevatedButton.styleFrom(
              //       primary: Colors.black.withOpacity(0.1),
              //       shadowColor: Colors.transparent,
              //       elevation: 0,
              //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              //     ),
              //     onPressed: () async {
              //       try {
              //         final gUser = await googleSignIn.signIn();
              //         final googleAuth = await gUser.authentication;
              //         final credential = GoogleAuthProvider.credential(
              //           idToken: googleAuth.idToken,
              //           accessToken: googleAuth.accessToken,
              //         );
              //         await FirebaseAuth.instance.signInWithCredential(credential)
              //             .then((value) async {
              //               if (value.user != null) {
              //                 Map<String, dynamic> userInfoMap = {
              //                   "uid": FirebaseAuth.instance.currentUser.uid,
              //                   "username" : gUser.email.split('@').first,
              //                   "email" : gUser.email,
              //                   "name" : gUser.displayName,
              //                   "bio" : "",
              //                   "profilePhoto" : null,
              //                   "profileBgPhoto" : null
              //                 };
              //                 await FirebaseFirestore.instance.collection("users")
              //                     .doc(userInfoMap['uid'])
              //                     .set(userInfoMap, SetOptions(merge: true));
              //                 await value.user.updateDisplayName(
              //                     gUser.displayName
              //                 );
              //                 final SharedPreferences prefs = await SharedPreferences.getInstance();
              //                 prefs.setString('email', gUser.email);
              //                 Navigator.of(context).pushAndRemoveUntil(
              //                     MaterialPageRoute(builder: (context) => Home()),
              //                         (Route<dynamic> route) => false
              //                 );
              //               }
              //             });
              //       } catch (e) {
              //         print(e);
              //       }
              //     },
              //   ),
              // ),
              SizedBox(height: 15)
            ],
          ),
        ),
      ),
    );
  }
}