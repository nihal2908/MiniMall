import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mnnit/firebase/user_manager.dart';

class ChatService{

  //get instance
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;


  Future<Map<String, dynamic>> buildContact({required String dealerId}) async {
    await firestore.collection('users').doc(UserManager.userId).update({
      'chats': FieldValue.arrayUnion([dealerId])
    });
    DocumentSnapshot snapshot = await firestore.collection('users').doc(dealerId).get();
    final data = snapshot.data() as Map<String, dynamic>;
    return data;
  }

  //send message
  Future<void> sendMessage({required String chatRoomId, required String recieverId, required String message}) async {
    // firestore.collection('users').doc(senderId).update({
    //   'chats': FieldValue.arrayUnion([chatRoomID])
    // });
    // firestore.collection('users').doc(recieverId).update({
    //   'chats': FieldValue.arrayUnion([chatRoomID])
    // });

    //add new message to database
    await firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'message': message,
      'sender': UserManager.userId,
      'reciever': recieverId,
      'timestamp': FieldValue.serverTimestamp()
    });
  }

  //getting messages
  Stream<QuerySnapshot> getMessages({required String chatRoomId}){

    return firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> deleteChatRoom({required String id}) async {
    String chatRoomId = (List<String>.from([id, UserManager.userId])..sort()..join('_')) as String;
    await firestore.collection('chat_rooms').doc(chatRoomId).delete();
    await firestore.collection('users').doc(UserManager.userId).update({
      'chats': FieldValue.arrayRemove([id])
    });
    await firestore.collection('users').doc(id).update({
      'chats': FieldValue.arrayRemove([UserManager.userId])
    });
  }

  Future<void> clearChat({required String chatRoomId}) async {
    await firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').doc().delete();
  }

  Future<void> deleteMessage({required String chatRoomId, required String messageId}) async {
    await firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').doc(messageId).delete();
  }

  Future<void> updateMessage({required String chatRoomId, required String messageId, required String message}) async {
    await firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').doc(messageId).update({
      'message': message,
      'edited': true
    });
  }

  Future<void> blockCHat({required String chatRoomId}) async {
    await firestore.collection('chat_rooms').doc(chatRoomId).update({
      'blocked': true,
      'blocker': UserManager.userId
    });
    await firestore.collection('blocked').doc(chatRoomId).set({
      'blocker': UserManager.userId,
      'timestamp': FieldValue.serverTimestamp()
    });
  }

  Future<void> reportChat({required String chatRoomId, required BuildContext context, required String reason}) async {
    await firestore.collection('chat_rooms').doc(chatRoomId).update({
      'reported': true,
      'reporter': UserManager.userId
    });
    DocumentReference ref = await firestore.collection('reported').doc(chatRoomId);
    ref.set({
      'timestamp': FieldValue.serverTimestamp(),
      'reporter': UserManager.userId,
      'reason': reason
    });
  }

  Future<void> showReasonDialog({required BuildContext context, required String chatRoomId}) async {
    List<String> reasons = ['iwef', 'ishfd'];
    String? selectedValue;
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text('Choose the reason to report'),
            content: StatefulBuilder(
              builder: (context, setState) {
                return DropdownButtonFormField<String>(
                  value: reasons[0],
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    labelText: 'Reason',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  items: reasons.map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedValue = value!;
                    });
                  },
                );
              },
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel', style: TextStyle(color: Colors.green)),
              ),
              ElevatedButton(
                onPressed: () async {
                  await reportChat(chatRoomId: chatRoomId, context: context, reason: selectedValue!);
                },
                child: Text('Report', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
        barrierDismissible: false
    );
  }

}