import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mnnit/customFunctions/navigator_functions.dart';
import 'package:mnnit/firebase/chat_service.dart';
import 'package:mnnit/firebase/user_manager.dart';
import 'package:mnnit/widgets/alert_box_with_two_action.dart';
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
  double? previousPosition;

  @override
  void initState() {
    List<String> t = List<String>.from([widget.recieverId, UserManager.userId])..sort();
    chatRoomId = t.join("_");
    super.initState();
  }

  @override
  void dispose() {
    messageController.dispose();
    selectedMessages.clear();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name.toUpperCase()),
        actions: [
          if (selectedMessages.isNotEmpty) ...[
            if (hasSentMessages && !hasReceivedMessages) IconButton(
              icon: const Icon(Icons.delete),
              onPressed: showDeleteMessageALert,
            ),
            if (hasSentMessages && !hasReceivedMessages && selectedMessages.length == 1) IconButton(
              icon: const Icon(Icons.edit),
              onPressed: editSelectedMessage,
            ),
            if (hasReceivedMessages && !hasSentMessages)
              IconButton(
                icon: const Icon(Icons.report),
                onPressed: (){
                  chatService.showReasonDialog(context: context, chatRoomId: chatRoomId);
                },
              ),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: copySelectedMessages,
            ),
          ],
          if(selectedMessages.isEmpty) customPopupMenuButton(context),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(child: buildMessageList()),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    maxLines: 7,
                    minLines: 1,
                    decoration: InputDecoration(
                      fillColor: Theme.of(context).cardColor,
                      filled: true,
                      hintText: 'Enter message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40)
                      )
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).cardColor,
                  ),
                  margin: const EdgeInsets.only(left: 10),
                  child: IconButton(
                    onPressed: sendMessage,
                    icon: const Icon(Icons.send, color: Colors.deepPurple,),
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

  void showDeleteMessageALert(){
    showTwoActionAlert(
      context: context,
      title: '',
      content: 'Delete messages for everyone?',
      text: 'Delete',
      action: (){
        deleteSelectedMessages();
        pop(context: context);
      }
    );
  }

  void showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear Chat?'),
          content: const Text('This will delete all the messages for everyone!'),
          actions: [
            ElevatedButton(
              onPressed: () {
                pop(context: context);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.green)),
            ),
            ElevatedButton(
              onPressed: () {
                chatService.clearChat(chatRoomId: chatRoomId);
                pop(context: context);
              },
              child: const Text('Clear Chat', style: TextStyle(color: Colors.red)),
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
          title: const Text('Report Chat?'),
          content: const Text('The messages will be examined for any inappropriate message. Do not report unnecessarily'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.green)),
            ),
            ElevatedButton(
              onPressed: () {
                chatService.showReasonDialog(context: context, chatRoomId: chatRoomId);
              },
              child: const Text('Report', style: TextStyle(color: Colors.red)),
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
          title: const Text('Block User?'),
          content: const Text('Non of the users will be able to message.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.green)),
            ),
            ElevatedButton(
              onPressed: () {

              },
              child: const Text('Block', style: TextStyle(color: Colors.red)),
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
          return const Text('Error');
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          // return const Text('Loading...');
          return SizedBox.shrink();
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients && selectedMessages.isEmpty) {
              _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
            }
            else{
              _scrollController.jumpTo(previousPosition!);
            }
          });
          // print(selectedMessages.map((t)=>t.id));
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
    bool edited = data.containsKey('edited');
    bool isSelected = selectedMessages.map((m)=>m.id).toList().contains(doc.id);
    Color sendBubble = (Theme.of(context).brightness == Brightness.light) ? Colors.green.shade200 : Colors.green.shade800;
    Color recBubble = (Theme.of(context).brightness == Brightness.light) ? Colors.grey.shade200 : Colors.grey.shade800;
    Color selectionColor = Colors.blue.withOpacity(0.5);
    // print(doc.id +" "+ isSelected.toString());

    return InkWell(
      onTap: (){
        if(selectedMessages.isNotEmpty){
          setState(() {
            if (isSelected) {
              selectedMessages.removeWhere((element) => element.id==doc.id,);
            } else {
              selectedMessages.add(doc);
            }
            updateSelectionTypes();
            previousPosition = _scrollController.offset;
          });
        }
      },
      onLongPress: () {
        setState(() {
          if (isSelected) {
            selectedMessages.removeWhere((element) => element.id==doc.id,);
          } else {
            selectedMessages.add(doc);
          }
          updateSelectionTypes();
          previousPosition = _scrollController.offset;
        });
      },
      child: Container(
        color: isSelected ? selectionColor : null,
        alignment: received ? Alignment.centerLeft : Alignment.centerRight,
        child: received ? Container(
          decoration: BoxDecoration(
            color: recBubble,
            borderRadius: const BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
          ),
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
          margin: const EdgeInsets.only(right: 60, top: 3, bottom: 3, left: 3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                data['message'],
                style: const TextStyle(fontSize: 17),
              ),
              if(edited) Text('edited', style: const TextStyle(fontSize: 9)),
            ],
          ),
        )
            : Container(
          decoration: BoxDecoration(
            color: sendBubble,
            borderRadius: const BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
          ),
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
          margin: const EdgeInsets.only(left: 60, top: 3, bottom: 3, right: 3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                data['message'],
                style: const TextStyle(fontSize: 17),
              ),
              if(edited) Text('edited', style: const TextStyle(fontSize: 9))
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
      const SnackBar(content: Text('Messages copied to clipboard')),
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
            title: const Text('Edit Message'),
            content: TextField(
              controller: editController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Edit new message'),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  chatService.updateMessage(chatRoomId: chatRoomId, messageId: doc.id, message: editController.text);
                  Navigator.pop(context);
                  setState(() {
                    selectedMessages.clear();
                    hasSentMessages = false;
                    hasReceivedMessages = false;
                  });
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    }
  }

  void reportSelectedMessages() {

  }



  void sendMessage() async {
    if (messageController.text.trim().isNotEmpty) {
      chatService.sendMessage(chatRoomId: chatRoomId, recieverId:  widget.recieverId, message:  messageController.text.trim());
      messageController.clear();
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }
}
