import 'package:chat_app_firebase/helper/authenticate.dart';
import 'package:chat_app_firebase/helper/constants.dart';
import 'package:chat_app_firebase/helper/helperFun.dart';
import 'package:chat_app_firebase/services/auth.dart';
import 'package:chat_app_firebase/services/database.dart';
import 'package:chat_app_firebase/view/SearchScreen.dart';
import 'package:chat_app_firebase/view/chatsScreen.dart';
import 'package:chat_app_firebase/widget/Widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  AuthMetods authMetods = new AuthMetods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  Stream<QuerySnapshot> chatRoom;
  DateTime backbuttonpressedTime;

  @override
  void initState() {
    getChatRoom();
    super.initState();
  }

  getChatRoom() async {
    Constants.myName = await HelperFunction.getUName();
    databaseMethods.getChatRooms(Constants.myName).then((value) {
      chatRoom = value;
      setState(() {});
    });
  }

  Future<bool> onWillPop() async {
    DateTime currentTime = DateTime.now();
    //Statement 1 Or statement2
    bool backButton = backbuttonpressedTime == null ||
        currentTime.difference(backbuttonpressedTime) > Duration(seconds: 3);
    if (backButton) {
      backbuttonpressedTime = currentTime;
      Fluttertoast.showToast(
        msg: "Double Click to exit app",
        toastLength: Toast.LENGTH_SHORT,
        webBgColor: "#e74c3c",
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    getChatRoom();
    return Scaffold(
      backgroundColor: Colors.white54,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset("assets/images/logo.png", height: 40),
        elevation: 0.0,
        centerTitle: false,
        actions: <Widget>[
          InkWell(
            onTap: () {
              HelperFunction.saveLogin(false);
              authMetods.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Authenticate()),
              );
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.exit_to_app)),
          )
        ],
      ),
      body: WillPopScope(onWillPop: onWillPop, child: chtRoomList()),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.search),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SearchScreen()));
          }),
    );
  }

  getUName(String name) {
    String _pr;
    int _i;
    _i = name.indexOf("_");
    _pr = name.substring(0, _i);
    if (_pr != Constants.myName)
      return _pr;
    else {
      return name.substring(_i + 1, name.length);
    }
  }

  Widget chtRoomList() {
    return StreamBuilder(
        stream: chatRoom,
        builder: (context, AsyncSnapshot<QuerySnapshot> sanpshot) {
          return sanpshot.hasData
              ? ListView.builder(
                  itemCount: sanpshot.data.documents.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return ChatsRoomTile(
                      userName: getUName(sanpshot
                          .data.documents[index].data["chatroomId"]
                          .toString()),
                      // sanpshot
                      //     .data.documents[index].data["chatroomId"]
                      //     .toString()
                      //     .replaceAll("_", "")
                      //     .substring(startIndex)
                      //     .replaceAll(Constants.myName, ""),
                      chatRoomId:
                          sanpshot.data.documents[index].data["chatroomId"],
                    );
                  },
                )
              : Center(child: CircularProgressIndicator());
        });
  }
}

class ChatsRoomTile extends StatefulWidget {
  final String userName;
  final String chatRoomId;
  ChatsRoomTile({this.userName, @required this.chatRoomId});

  @override
  _ChatsRoomTileState createState() => _ChatsRoomTileState();
}

class _ChatsRoomTileState extends State<ChatsRoomTile> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  Stream<QuerySnapshot> da;

  @override
  void initState() {
    super.initState();
    getMessageCount();
  }

  getMessageCount() async {
    databaseMethods
        .getUnReadMessage(widget.userName, widget.chatRoomId)
        .then((val) {
      da = val;
    });
  }

  Widget newMassageCount() {
    return StreamBuilder(
      stream: da,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return snapshot.hasData && snapshot.data.documents.length > 0
            ? Container(
                child: CircleAvatar(
                radius: 12,
                child: Text(
                  snapshot.data.documents.length.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
                backgroundColor: Colors.green[400],
              ))
            : Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatsScreen(
              chatRoomId: widget.chatRoomId,
            ),
          ),
        );
      },
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: CustomTheme.colorAccent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      widget.userName.substring(0, 1).toString().toUpperCase(),
                      style: mediumStyle(),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    widget.userName,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  newMassageCount(),
                ],
              ),
            ),
            Divider(
              height: 0,
              thickness: .5,
              color: Colors.black45,
            )
          ],
        ),
      ),
    );
  }
}
