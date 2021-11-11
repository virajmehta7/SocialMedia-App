import 'package:coolname/utils/colors.dart';
import 'package:coolname/utils/outlineInputBorder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'forgotPassword.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key key}) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController password = new TextEditingController();
  TextEditingController newPassword = new TextEditingController();
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
        title: Text('Password',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            onPressed: () async {
              if(_formKey.currentState.validate()){
                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: FirebaseAuth.instance.currentUser.email,
                    password: password.text,
                  );
                  await FirebaseAuth.instance.currentUser.updatePassword(newPassword.text)
                      .then((_){
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Password changed successfully!"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
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
                } catch (e) {
                  setState(() {
                    error = e.message;
                  });
                }
              }
            },
            icon: Icon(Icons.done),
            color: mlight,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(15,30,15,20),
                    child: TextFormField(
                      controller: password,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderSide: BorderSide()),
                        labelText: 'Current password',
                        labelStyle: TextStyle(
                            color: mlight,
                            fontSize: 16
                        ),
                        enabledBorder: outlineInputBorder,
                        focusedBorder: outlineInputBorder,
                        errorBorder: outlineInputBorder,
                        focusedErrorBorder: outlineInputBorder,
                      ),
                      validator: (value) {
                        if(value.isEmpty)
                          return 'Password can\'t be empty';
                        if(value.length < 8)
                          return 'Password must be at least 8 characters';
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(15,5,15,20),
                    child: TextFormField(
                      controller: newPassword,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderSide: BorderSide()),
                        labelText: 'New password',
                        labelStyle: TextStyle(
                            color: mlight,
                            fontSize: 16
                        ),
                        enabledBorder: outlineInputBorder,
                        focusedBorder: outlineInputBorder,
                        errorBorder: outlineInputBorder,
                        focusedErrorBorder: outlineInputBorder,
                      ),
                      validator: (value) {
                        if(value.isEmpty)
                          return 'Password can\'t be empty';
                        if(value.length < 8)
                          return 'Password must be at least 8 characters';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15,5,15,20),
              child: InkWell(
                onTap: (){
                  Navigator.push(
                      context, MaterialPageRoute(
                      builder: (context) => ForgotPassword())
                  );
                },
                child: Text('Forgot password?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            showAlert(),
          ],
        ),
      ),
    );
  }
}