import 'package:coolname/utils/colors.dart';
import 'package:coolname/utils/outlineInputBorder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../forgotPassword.dart';
import '../home.dart';

class LoginBottomSheet extends StatefulWidget {
  const LoginBottomSheet({Key key}) : super(key: key);

  @override
  _LoginBottomSheetState createState() => _LoginBottomSheetState();
}

class _LoginBottomSheetState extends State<LoginBottomSheet> {

  final _formKey = GlobalKey<FormState>();

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  String error;
  bool loading = false;

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
    return SingleChildScrollView(
      child: loading ?
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 100),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Colors.white,
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: mlight,
          ),
        ),
      ) :
      Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
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
                  SizedBox(height: 10),
                  Text('Welcome \nBack',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: emailTextEditingController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.email,
                              color: mlight,
                            ),
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w300,
                              color: Colors.black,
                              fontSize: 16
                            ),
                            enabledBorder: outlineInputBorder,
                            focusedBorder: outlineInputBorder,
                            errorBorder: outlineInputBorder,
                            focusedErrorBorder: outlineInputBorder,
                          ),
                          validator: (val) {
                            if(val.isEmpty)
                              return 'Email can\'t be empty';
                            if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val))
                              return 'Enter a valid email';
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: passwordTextEditingController,
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.lock,
                              color: mlight,
                            ),
                            labelText: 'Password',
                            labelStyle: TextStyle(
                                fontWeight: FontWeight.w300,
                                color: Colors.black,
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
                        Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: InkWell(
                            onTap: (){
                              Navigator.pop(context);
                              Navigator.push(
                                  context, MaterialPageRoute(
                                  builder: (context) => ForgotPassword())
                              );
                            },
                            child: Text('Forgot password?',
                                style: TextStyle(color: Colors.black)
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 70,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(10),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: mlight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ElevatedButton(
                        child: Text('LOGIN',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w300
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.transparent,
                          elevation: 0,
                        ),
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          if(_formKey.currentState.validate()) {
                            setState(() {
                              loading = true;
                            });
                            try{
                              await FirebaseAuth.instance.signInWithEmailAndPassword(
                                  email: emailTextEditingController.text.trim(),
                                  password: passwordTextEditingController.text.trim()
                              );
                              final SharedPreferences prefs = await SharedPreferences.getInstance();
                              prefs.setString('email', emailTextEditingController.text.trim());
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => Home()),
                                      (Route<dynamic> route) => false
                              );
                            } catch(e){
                              setState(() {
                                error = e.message;
                                loading = false;
                              });
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            showAlert(),
          ],
        ),
      ),
    );
  }
}