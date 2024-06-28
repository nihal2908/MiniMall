import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mnnit/firebase/chat_service.dart';
import 'package:mnnit/firebase/user_manager.dart';
import 'package:mnnit/widgets/decorations.dart';

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

  Set<DocumentSnapshot> selectedMessages = Set<DocumentSnapshot>();
  bool hasSentMessages = false;
  bool hasReceivedMessages = false;
  late final String chatRoomId;

  @override
  void initState() {
    List<String> t = List<String>.from([widget.recieverId, UserManager.userId])..sort();
    chatRoomId = t.join("_");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name.toUpperCase()),
        actions: [
          if (selectedMessages.isNotEmpty) ...[
            if (hasSentMessages && !hasReceivedMessages) IconButton(
              icon: Icon(Icons.delete),
              onPressed: deleteSelectedMessages,
            ),
            if (hasSentMessages && !hasReceivedMessages && selectedMessages.length == 1) IconButton(
              icon: Icon(Icons.edit),
              onPressed: editSelectedMessage,
            ),
            if (hasReceivedMessages && !hasSentMessages) IconButton(
              icon: Icon(Icons.report),
              onPressed: reportSelectedMessages,
            ),
            IconButton(
              icon: Icon(Icons.copy),
              onPressed: copySelectedMessages,
            ),
          ],
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
                    onPressed: sendMessage,
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

  void deleteSelectedMessages() {
    for (var message in selectedMessages) {
      chatService.deleteMessage(chatRoomId: chatRoomId, messageId: message.id);
    }
    setState(() {
      selectedMessages.clear();
    });
  }

  void showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Clear Chat?'),
          content: Text('This will delete all the messages for both the users!'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: TextStyle(color: Colors.green)),
            ),
            ElevatedButton(
              onPressed: () {
                chatService.deleteChatRoom(id: widget.recieverId);
              },
              child: Text('Clear Chat', style: TextStyle(color: Colors.red)),
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
                chatService.showReasonDialog(context: context, chatRoomId: chatRoomId);
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
      stream: chatService.getMessages(chatRoomId: chatRoomId),
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
    bool received = data['reciever'] == UserManager.userId!;
    bool isSelected = selectedMessages.contains(doc);
    // Color sendBubble = (Theme.of(context).brightness == Brightness.light) ? Colors.green.shade200 : Colors.green.shade800;
    // Color recBubble = (Theme.of(context).brightness == Brightness.light) ? Colors.grey.shade200 : Colors.grey.shade800;
    // Color selectionColor = Colors.black;

    return GestureDetector(
      onLongPress: () {
        setState(() {
          if (isSelected) {
            selectedMessages.remove(doc);
          } else {
            selectedMessages.add(doc);
          }
          updateSelectionTypes();
        });
      },
      child: Container(
        color: isSelected ? selectionColor : null,
        alignment: received ? Alignment.centerLeft : Alignment.centerRight,
        child: received
            ? Container(
          decoration: BoxDecoration(
            color: isSelected ? selectionColor : recBubble,
            borderRadius: BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
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
        )
            : Container(
          decoration: BoxDecoration(
            color: isSelected ? selectionColor : sendBubble,
            borderRadius: BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
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
      ),
    );
  }

  void updateSelectionTypes() {
    hasSentMessages = selectedMessages.any((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return data['sender'] == UserManager.userId!;
    });

    hasReceivedMessages = selectedMessages.any((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return data['reciever'] == UserManager.userId!;
    });
  }


  void copySelectedMessages() {
    final selectedText = selectedMessages.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return data['message'];
    }).join('\n');

    Clipboard.setData(ClipboardData(text: selectedText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Messages copied to clipboard')),
    );
    setState(() {
      selectedMessages.clear();
      hasSentMessages = false;
      hasReceivedMessages = false;
    });
  }


  void editSelectedMessage() {
    if (selectedMessages.length == 1) {
      final doc = selectedMessages.first;
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String currentMessage = data['message'];

      showDialog(
        context: context,
        builder: (context) {
          TextEditingController editController = TextEditingController(text: currentMessage);
          return AlertDialog(
            title: Text('Edit Message'),
            content: TextField(
              controller: editController,
              autofocus: true,
              decoration: InputDecoration(hintText: 'Edit new message'),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await chatService.updateMessage(chatRoomId: chatRoomId, messageId: doc.id, message: editController.text);
                  Navigator.pop(context);
                  setState(() {
                    selectedMessages.clear();
                    hasSentMessages = false;
                    hasReceivedMessages = false;
                  });
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      );
    }
  }

  void reportSelectedMessages() {
    // Implement the report functionality as needed
  }



  void sendMessage() async {
    if (messageController.text.isNotEmpty) {
      await chatService.sendMessage(chatRoomId: chatRoomId, recieverId:  widget.recieverId, message:  messageController.text);
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
