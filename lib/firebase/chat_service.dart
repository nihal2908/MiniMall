import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService{

  //get instance
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;


  //send message
  Future<void> sendMessage(String senderId, String recieverId, String message) async {
    //get current user info
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    //construct a chat room id
    List<String> ids = [senderId, recieverId];
    // making the chat room id by joing the user ids of the sender, reciever
    ids.sort();
    String chatRoomID = ids.join('_');

    //add new message to database
    await firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .add({
      'message': message,
      'sender': senderId,
      'reciever': recieverId,
      'timestamp': FieldValue.serverTimestamp()
    });
  }

  //getting messages
  Stream<QuerySnapshot> getMessages(String sender, String reciever){
    List<String> ids = [sender, reciever];
    ids.sort();
    String chatRoomId = ids.join('_');

    return firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }



  Stream<List<Map<String, dynamic>>> getPatientStream(){
    return firestore.collection('Patient').snapshots().map((snapshot) {
      return snapshot.docs.map((doc){
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getDoctorStream(){
    return firestore.collection('Doctor').snapshots().map((snapshot) {
      return snapshot.docs.map((doc){
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getRoomStream(){
    return firestore.collection('chat_rooms').snapshots().map((snapshot) {
      return snapshot.docs.map((doc){
        final user = doc.data();
        return user;
      }).toList();
    });
  }

}