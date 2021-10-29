import 'package:chat_app_firebase/helper/constants.dart';
import 'package:chat_app_firebase/services/database.dart';
import 'package:chat_app_firebase/view/chatRoom.dart';
import 'package:chat_app_firebase/view/chatsScreen.dart';
import 'package:chat_app_firebase/widget/Widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchTxtEditCon = new TextEditingController();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  QuerySnapshot searchSnapshot;
  bool isloading = false;
  bool userSearch = false;

  initateSearch() async {
    if (searchTxtEditCon.text.isNotEmpty &&
        searchTxtEditCon.text != Constants.myName) {
      setState(() {
        isloading = true;
      });
      await databaseMethods.getUserByName(searchTxtEditCon.text).then((val) {
        searchSnapshot = val;
        setState(() {
          isloading = false;
          userSearch = true;
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ChatRoom()));
      },
      child: Scaffold(
        appBar: appBarMain(context),
        body: Container(
            child: Column(
          children: <Widget>[
            Container(
              color: Color(0x54FFFFFF),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: TextField(
                    controller: searchTxtEditCon,
                    onChanged: (text) {
                      initateSearch();
                    },
                    style: simpleStyle(),
                    decoration: InputDecoration(
                      hintText: "search username ...",
                      hintStyle: TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                    ),
                  )),
                  InkWell(
                    onTap: () {
                      initateSearch();
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
                          borderRadius: BorderRadius.circular(40)),
                      child: Image.asset(
                        "assets/images/search_white.png",
                        width: 25,
                        height: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            searchList(),
          ],
        )),
      ),
    );
  }

  Widget searchList() {
    return isloading
        ? Container(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : userSearch
            ? searchSnapshot.documents.length > 0
                ? ListView.builder(
                    itemCount: searchSnapshot.documents.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return searchTile(
                        username: searchSnapshot.documents[index].data["name"],
                        useremail:
                            searchSnapshot.documents[index].data["email"],
                      );
                    })
                : Container(
                    height: 300,
                    alignment: Alignment.center,
                    child: Text("No Data", style: mediumStyle()))
            : Center(
                child: userSearch ? CircularProgressIndicator() : Container());
  }

  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  createChatRoom(String userName) {
    if (userName != Constants.myName) {
      String chatRoomId = getChatRoomId(userName, Constants.myName);

      List<String> users = [userName, Constants.myName];
      Map<String, dynamic> chatRoomMap = {
        "users": users,
        "chatroomId": chatRoomId
      };

      DatabaseMethods().crateChatRoom(chatRoomId, chatRoomMap);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatsScreen(chatRoomId: chatRoomId),
        ),
      );
    } else {
      print("This user name your self");
    }
  }

  Widget searchTile({String username, String useremail}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                username,
                style: simpleStyle(),
              ),
              Text(
                useremail,
                style: simpleStyle(),
              ),
            ],
          ),
          Spacer(),
          InkWell(
            onTap: () {
              createChatRoom(username);
            },
            child: Container(
              child: Text("Message", style: mediumStyle()),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(24)),
            ),
          )
        ],
      ),
    );
  }
}
