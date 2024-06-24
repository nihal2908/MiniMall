import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mnnit/firebase/firebase_auth.dart';
import 'package:mnnit/firebase/firebase_storage.dart';
import 'package:mnnit/pages/chat_room.dart';
import 'package:mnnit/widgets/circular_progress.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final Auth auth = Auth();
  final Firebase storage = Firebase();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: FutureBuilder(
        future: firestore.collection('users').doc(auth.getCurentUser()!.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CenterIndicator();
          }
          if (snapshot.hasError) {
            return ListTile(
              title: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const ListTile(
              title: Text('You have no recent chats. Chats with product dealers will be displayed here.'),
            );
          }
          final userDoc = snapshot.data!;

          final List<dynamic> ids = userDoc['chats'];
          print(ids.length);
          return SingleChildScrollView(
              child: ChatList(ids: ids)
          );
        }
      )
    );
  }

  Widget ChatList({required List<dynamic> ids}){
    if(ids.isEmpty) return const Center(child: Padding(
      padding: EdgeInsets.all(20.0),
      child: Text('You have no recent chats. Chats with product dealers will be displayed here.', style: TextStyle(color: Colors.white),),
    ),);
    return FutureBuilder(
        future: firestore.collection('users').where(FieldPath.documentId, whereIn: ids).get(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CenterIndicator();
          }
          if (snapshot.hasError) {
            return ListTile(
              title: Text('Error: ${snapshot.error}'),
            );
          }
          return Column(
          children: snapshot.data!.docs.map((element) {
            String name = element.data()['name'];
            String id = element.id;
            return Container(
              color: Colors.grey.shade200,
              child: ListTile(
                title: Text(name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: (){
                    storage.deleteChat(id: id);
                    setState(() {});
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatRoomPage(chatUserId: id, name: name,)),
                  );
                },
              ),
            );
          }).toList(),
          );
        }
    );
  }
}
