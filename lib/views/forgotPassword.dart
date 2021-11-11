import 'package:coolname/utils/colors.dart';
import 'package:coolname/utils/outlineInputBorder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController email = new TextEditingController();
  String error;

  Widget showAlert() {
    if (error != null) {
      return Container(
        color: Colors.red,
        width: double.infinity,
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.error_outline_sharp, color: Colors.white,),
            ),
            Expanded(
              child: Text(error,
                style: TextStyle(color: Colors.white),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white,),
                onPressed: () {
                  setState(() {
                    error = null;
                  });
                },
              ),
            )
          ],
        ),
      );
    }
    return SizedBox(
      height: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Your Account',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 50),
            Text('Enter your email linked to your account.',
              style: TextStyle(fontSize: 16),
            ),
            Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.fromLTRB(30,30,30,20),
                child: TextFormField(
                  controller: email,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(borderSide: BorderSide()),
                      labelText: 'Email',
                      labelStyle: TextStyle(
                          color: mlight,
                          fontSize: 16
                      ),
                    prefixIcon: Icon(
                      Icons.email,
                      color: mlight,
                    ),
                    enabledBorder: outlineInputBorder,
                    focusedBorder: outlineInputBorder,
                    errorBorder: outlineInputBorder,
                    focusedErrorBorder: outlineInputBorder,
                  ),
                  validator: (value) {
                    if(value.isEmpty)
                      return 'Email can\'t be empty';
                    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value))
                      return 'Enter a valid email';
                    return null;
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: showAlert(),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState.validate()){
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                        email: email.text
                    );
                    setState(() {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Password Reset Email Sent"),
                              content: Text("An email has been sent to ${email.text} "),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: Text('Ok'),
                                )
                              ],
                            );
                          }
                      );
                    });
                  } catch(e) {
                    setState(() {
                      error = e.message;
                    });
                  }
                }
              },
              child: Text('Send password reset email',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                primary: mlight,
                padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              ),
            )
          ],
        ),
      ),
    );
  }
}