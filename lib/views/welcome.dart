import 'package:coolname/utils/colors.dart';
import 'package:flutter/material.dart';
import 'bottomSheet/login.dart';
import 'bottomSheet/signup.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key key}) : super(key: key);

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
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
                Colors.white,
                light,
                mid,
                mdark
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
                    primary: Colors.black.withOpacity(0.15),
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
                    primary: Colors.black.withOpacity(0.65),
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
              SizedBox(height: 15)
            ],
          ),
        ),
      ),
    );
  }
}