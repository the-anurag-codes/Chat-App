import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  getUserByUsername(String username) async {
    try {
      return await FirebaseFirestore.instance
          .collection('users')
          .where("name", isEqualTo: username)
          .get();
    } catch (e) {
      print(e);
    }
  }

  getUserByUserEmail(String userEmail) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where("email", isEqualTo: userEmail)
        .get();
  }

  uploadUserInfo(userMap) {
    FirebaseFirestore.instance.collection("users").add(userMap);
  }

  createChatRoom(String chatRoomId, chatRoomMap) {
    FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .set(chatRoomMap);
  }

  addMessages(String chatRoomId, messageMap) {
    FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(chatRoomId)
        .collection('messages')
        .add(messageMap)
        .catchError((e) => print(e.toString()));
  }

  getMessages(
    String chatRoomId,
  ) async {
    return await FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('time', descending: false)
        .snapshots();
  }
  
  getChatRooms(String userName) async{
    return await FirebaseFirestore.instance.collection('chatRoom').where('users', arrayContains: userName).snapshots();
  }
}
