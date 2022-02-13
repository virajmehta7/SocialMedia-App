import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods{

  usernameCheck(username) async {
    final result = await FirebaseFirestore.instance
        .collection("users")
        .where('username', isEqualTo: username)
        .get();
    return result.docs.isEmpty;
  }

  roomIdCheck(roomId) async {
    final result = await FirebaseFirestore.instance
        .collection("messages")
        .where('roomId', isEqualTo: roomId)
        .get();
    return result.docs.isNotEmpty;
  }

}