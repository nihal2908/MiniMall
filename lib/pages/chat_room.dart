import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mnnit/firebase/chat_service.dart';
import 'package:mnnit/firebase/user_manager.dart';

class ChatRoomPage extends StatefulWidget {
  final String name;
  final String recieverId;

  ChatRoomPage({required this.recieverId, required this.name});

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController messageController = TextEditingController();
  final ChatService chatService = ChatService();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name.toUpperCase()),
        actions: [
          customPopupMenuButton(context),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(child: buildMessageList()),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      fillColor: Theme.of(context).cardColor,
                      filled: true,
                      hintText: 'Enter message...',
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).cardColor,
                  ),
                  margin: EdgeInsets.only(left: 10),
                  child: IconButton(
                    onPressed: () {
                      sendMessage();
                    },
                    icon: Icon(Icons.send),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuButton<int> customPopupMenuButton(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) {
        return [
          const PopupMenuItem(
            value: 1,
            child: Row(
              children: [
                Text('Clear Chat'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 2,
            child: Row(
              children: [
                Text('Report'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 3,
            child: Row(
              children: [
                Text('Block'),
              ],
            ),
          ),
        ];
      },
      onSelected: (index) {
        switch (index) {
          case 1:
            showDeleteDialog(context);
            break;
          case 2:
            showReportDialog(context);
            break;
          case 3:
            showBlockDialog(context);
            break;
        }
      },
    );
  }

  void showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Clear Chat?'),
          content: Text('This will delete the chat for both the users!'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: TextStyle(color: Colors.green)),
            ),
            ElevatedButton(
              onPressed: () {
                // Clear chat logic here
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Report Chat?'),
          content: Text('The messages will be examined for any inappropriate message. Do not report unnecessarily'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: TextStyle(color: Colors.green)),
            ),
            ElevatedButton(
              onPressed: () {
                // Report chat logic here
              },
              child: Text('Report', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void showBlockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Block User?'),
          content: Text('Non of the users will be able to message.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: TextStyle(color: Colors.green)),
            ),
            ElevatedButton(
              onPressed: () {
                // Block user logic here
              },
              child: Text('Block', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget buildMessageList() {
    return StreamBuilder(
      stream: chatService.getMessages(UserManager.userId!, widget.recieverId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error');
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading...');
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
            }
          });
          return ListView(
            controller: _scrollController,
            children: snapshot.data!.docs.map((doc) => buildMessageItem(doc, context)).toList(),
          );
        }
      },
    );
  }

  Widget buildMessageItem(DocumentSnapshot doc, BuildContext context) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool received = data['receiver'] == UserManager.userId!;
    Color sendBubble = (Theme.of(context).brightness == Brightness.light) ? Colors.green.shade200 : Colors.green.shade800;
    Color recBubble = (Theme.of(context).brightness == Brightness.light) ? Colors.grey.shade200 : Colors.grey.shade800;

    return Container(
      alignment: received ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        decoration: BoxDecoration(
          color: received ? recBubble : sendBubble,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
        margin: EdgeInsets.all(3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['message'],
              style: TextStyle(fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage() async {
    if (messageController.text.isNotEmpty) {
      await chatService.sendMessage(UserManager.userId!, widget.recieverId, messageController.text);
      messageController.clear();
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }
}
