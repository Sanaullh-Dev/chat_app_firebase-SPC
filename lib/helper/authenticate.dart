import 'package:chat_app_firebase/view/SignIn.dart';
import 'package:chat_app_firebase/view/SignUp.dart';
import 'package:chat_app_firebase/view/SignUpPhone.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showsignIn = true;

  void toggleview() {
    setState(() {
      showsignIn = !showsignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showsignIn) {
      return SignIn(toggleview);
    } else {
      return SignUpPhone(toggleview);
    }
  }
}
