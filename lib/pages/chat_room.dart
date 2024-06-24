import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatRoomPage extends StatelessWidget {
  final String name;
  final String chatUserId;
  final TextEditingController message = TextEditingController();

  ChatRoomPage({required this.chatUserId, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name.toUpperCase()),
        actions: [
          customPopupMenuButton(context),
        ],
      ),
      body: SingleChildScrollView(),
      bottomSheet: BottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0)
        ),
        enableDrag: false,
        onClosing: (){},
        builder: (context) =>
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          height: 60,
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              SizedBox(
                width: 330,
                height: 50,
                child: TextField(
                  enabled: true,
                  autofocus: true,
                  maxLines: 10,
                  onSubmitted: (_){sendMessage();},
                  controller: message,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              IconButton(onPressed: (){
                // print(message.text);
                sendMessage();
                // message.clear();
              }, icon: Icon(Icons.send),),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuButton<int> customPopupMenuButton(BuildContext context) {
    return PopupMenuButton(
          itemBuilder: (context){
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
          onSelected: (index){
            switch(index){
              case 1:{
                showDeleteDialog(context);
              }
              case 2:{
                showReportDialog(context);
              }
              case 3:{
                showBlockDialog(context);
              }
            }
          },
        );
  }

  void showDeleteDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text('Clear Chat?'),
            content: Text('This will delete the chat for both the users!'),
            actions: [
              ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text('Cancel', style: TextStyle(color: Colors.green),)
              ),
              ElevatedButton(
                  onPressed: (){

                  },
                  child: Text('Delete', style: TextStyle(color: Colors.red),)
              ),
            ],
          );
        }
    );
  }

  void showReportDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text('Report Chat?'),
            content: Text('The messages will be examined for any inappropriate message. Do not report unnecessarily'),
            actions: [
              ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text('Cancel', style: TextStyle(color: Colors.green),)
              ),
              ElevatedButton(
                  onPressed: (){

                  },
                  child: Text('Report', style: TextStyle(color: Colors.red),)
              ),
            ],
          );
        }
    );
  }

  void showBlockDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text('Block User?'),
            content: Text('Non of the users will be able to message.'),
            actions: [
              ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text('Cancel', style: TextStyle(color: Colors.green),)
              ),
              ElevatedButton(
                  onPressed: (){

                  },
                  child: Text('Block', style: TextStyle(color: Colors.red),)
              ),
            ],
          );
        }
    );
  }

  void sendMessage() {
    print(message.text);
    message.text = '';
  }
}