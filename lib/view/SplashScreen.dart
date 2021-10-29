import 'dart:async';
import 'package:chat_app_firebase/helper/authenticate.dart';
import 'package:chat_app_firebase/helper/helperFun.dart';
import 'package:chat_app_firebase/view/chatRoom.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool ckLogin = false;

  getLoginState() async {
    await HelperFunction.getLogin().then((val) {
      setState(() {
        ckLogin = val != null ? val : false;
        print(ckLogin);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getLoginState();
    Timer(
      Duration(seconds: 2),
      () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => ckLogin != null
              ? ckLogin ? ChatRoom() : Authenticate()
              : Container(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff1F1F1F),
              Color(0xff145C9E),
              Color(0xff007EF4),
              Color(0xff145C9E),
              Color(0xff1F1F1F)
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "Wel-Come",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            Image.asset("assets/images/logo.png", height: 120),
          ],
        ),
      ),
    );
  }
}
