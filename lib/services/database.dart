import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  getUserByName(String username) async {
    return await Firestore.instance
        .collection("users")
        .where("name", isEqualTo: username)
        .getDocuments();
  }

  getByUserEmail(String uEmail) async {
    return await Firestore.instance
        .collection("users")
        .where("email", isEqualTo: uEmail)
        .getDocuments();
  }

  uploadUserInfo(userMap) async {
    return await Firestore.instance
        .collection("users")
        .add(userMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  crateChatRoom(String chatRoomId, chatRoomMap) {
    Firestore.instance
        .collection("ChatRoom")
        .document(chatRoomId)
        .setData(chatRoomMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  addConverstionMeassage(String chatRoomId, massageMap) {
    Firestore.instance
        .collection("ChatRoom")
        .document(chatRoomId)
        .collection("chats")
        .add(massageMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  getchatRoomId(String chatRoomId) async {
    return await Firestore.instance
        .collection("ChatRoom")
        .document(chatRoomId)
        .collection(chatRoomId)
        .where("chatroomId", isEqualTo: chatRoomId)
        .getDocuments();
  }

  getConverstionMeassage(String chatRoomId) async {
    return await Firestore.instance
        .collection("ChatRoom")
        .document(chatRoomId)
        .collection("chats")
        .orderBy("time", descending: false)
        .snapshots();
  }

  getConMessageDoc(String chatRoomId) async {
    return await Firestore.instance
        .collection("ChatRoom")
        .document(chatRoomId)
        .collection("chats")
        .orderBy("time", descending: false)
        .getDocuments();
  }

  getChatRooms(String userName) async {
    return await Firestore.instance
        .collection("ChatRoom")
        .where("users", arrayContains: userName)
        .snapshots();
  }

  getUnReadMessage(String uToName, String chatRoomId) async {
    return await Firestore.instance
        .collection("ChatRoom")
        .document(chatRoomId)
        .collection("chats")
        .where("status", isEqualTo: "send")
        .where("sendBy", isEqualTo: uToName)
        .snapshots();
  }

  updateMessage(String docId, String chatRoomId) {
    Firestore.instance
        .collection("ChatRoom")
        .document(chatRoomId)
        .collection("chats")
        .document(docId)
        .updateData({"status": "read"}).then((val) {
      print("update Message");
    });
  }
}
