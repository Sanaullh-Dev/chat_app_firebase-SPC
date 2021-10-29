import 'package:chat_app_firebase/view/SignUpPhone.dart';
import 'package:chat_app_firebase/view/SplashScreen.dart';
import 'package:chat_app_firebase/view/chatRoom.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xff1F1F1F),
        accentColor: Color(0xff007EF4),
        primaryColor: Color(0xff145C9E),
      ),
      home: SplashScreen(),
      routes: <String, WidgetBuilder>{
        '/ChatRoom': (BuildContext context) => new ChatRoom(),
        // '/SignUpPhone' : (BuildContext context) => new SignUpPhone(toggleview),
      },
    );
  }
}
