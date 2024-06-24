import 'package:flutter/material.dart';

class ChatRoomPage extends StatelessWidget {
  final String chatUserId;

  ChatRoomPage({required this.chatUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room'),
      ),
      body: Center(
        child: Text('Chat with User ID: $chatUserId'),
      ),
    );
  }
}
