import 'package:chat_app_firebase/view/chatRoom.dart';
import 'package:chat_app_firebase/widget/Widget.dart';
import 'package:flutter/material.dart';
import 'package:chat_app_firebase/services/database.dart';
import 'package:chat_app_firebase/helper/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatsScreen extends StatefulWidget {
  final String chatRoomId;
  ChatsScreen({@required this.chatRoomId});

  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  TextEditingController messageTextEditCon = new TextEditingController();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  Stream<QuerySnapshot> chats;
  QuerySnapshot querySnapshot;

  @override
  void initState() {
    getConverstionMessage();
    super.initState();
  }

  updateMessage() async {
    await databaseMethods.getConMessageDoc(widget.chatRoomId).then((val) {
      querySnapshot = val;
    });

    for (var snap in querySnapshot.documents) {
      if (snap.data["sendBy"] != Constants.myName &&
          snap.data["status"] != "read") {
        DatabaseMethods().updateMessage(snap.documentID, widget.chatRoomId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        updateMessage();
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ChatRoom()));
      },
      child: Scaffold(
        appBar: appBarMain(context),
        body: Container(
          child: Stack(
            children: <Widget>[
              chatMessage(),
              Container(
                alignment: Alignment.bottomCenter,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  color: Color(0x54FFFFFF),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: TextField(
                        controller: messageTextEditCon,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Meassage...",
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                        ),
                      )),
                      SizedBox(width: 16),
                      InkWell(
                        onTap: () {
                          sendMessage();
                        },
                        child: Container(
                            height: 40,
                            width: 40,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [
                                      const Color(0x36FFFFFF),
                                      const Color(0x0FFFFFFF)
                                    ],
                                    begin: FractionalOffset.topLeft,
                                    end: FractionalOffset.bottomRight),
                                borderRadius: BorderRadius.circular(50)),
                            child: Image.asset(
                              "assets/images/send.png",
                              width: 25,
                              height: 25,
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget chatMessage() {
    bool _ck = false;
    int unReadIndex = 0;

    return StreamBuilder(
      stream: chats,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (BuildContext context, int index) {
                  if (snapshot.data.documents[index].data["status"] == "send" &&
                      snapshot.data.documents[index].data["sendBy"] !=
                          Constants.myName &&
                      unReadIndex == 0) {
                    _ck = true;
                    unReadIndex = index;
                  } else {
                    _ck = false;
                  }
                  return MessageTile(
                    message: snapshot.data.documents[index].data["message"],
                    isSendMe: snapshot.data.documents[index].data["sendBy"] ==
                        Constants.myName,
                    readCk: _ck,
                    chatRoomId: widget.chatRoomId,
                    snapshot: snapshot.data.documents[index],
                  );
                },
              )
            : Center(
                child: Container(
                  child: CircularProgressIndicator(),
                ),
              );
      },
    );
  }

  sendMessage() {
    if (messageTextEditCon.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": messageTextEditCon.text,
        "sendBy": Constants.myName,
        "time": DateTime.now().millisecondsSinceEpoch,
        "status": "send",
      };
      databaseMethods.addConverstionMeassage(widget.chatRoomId, messageMap);
      setState(() {
        messageTextEditCon.text = "";
      });
    }
  }

  getConverstionMessage() async {
    databaseMethods.getConverstionMeassage(widget.chatRoomId).then((value) {
      if (value != null) {
        chats = value;
        setState(() {});
      }
    });
  }
}

class MessageTile extends StatefulWidget {
  final String message;
  final bool isSendMe;
  final bool readCk;
  final String chatRoomId;
  final dynamic snapshot;
  MessageTile({
    @required this.message,
    @required this.isSendMe,
    @required this.readCk,
    @required this.chatRoomId,
    @required this.snapshot,
  });

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        widget.readCk
            ? Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Container(
                  width: 150,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(15)),
                  child: Text(
                    "Unread Message",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              )
            : Container(),
        Container(
          padding: EdgeInsets.only(
              top: 2,
              bottom: 2,
              left: widget.isSendMe ? 0 : 16,
              right: widget.isSendMe ? 16 : 0),
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(vertical: 8),
          alignment:
              widget.isSendMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: widget.isSendMe
                ? EdgeInsets.only(left: 30)
                : EdgeInsets.only(right: 30),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 24),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.isSendMe
                      ? [const Color(0xff007EF4), const Color(0xff2A75BC)]
                      : [const Color(0x1AFFFFFF), const Color(0x1AFFFFFF)],
                ),
                borderRadius: widget.isSendMe
                    ? BorderRadius.only(
                        topLeft: Radius.circular(23),
                        topRight: Radius.circular(23),
                        bottomLeft: Radius.circular(23),
                      )
                    : BorderRadius.only(
                        topLeft: Radius.circular(23),
                        topRight: Radius.circular(23),
                        bottomRight: Radius.circular(23),
                      )),
            child: Text(
              widget.message,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
