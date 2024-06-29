import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showTwoActionAlert({
  required BuildContext context,
  required String title,
  required String content,
  required String text,
  required Function() action,
  String? cancelText,
  Function()? cancelAction,
}){
  showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: title.isEmpty ? null : Text(title),
          content: Text(content),
          actions: [
            ElevatedButton(onPressed: (){Navigator.pop(context);}, child: Text('Cancel', style: TextStyle(color: Colors.green),)),
            ElevatedButton(onPressed: (){action();}, child: Text(text, style: TextStyle(color: Colors.red),),),
          ],
        );
      }
  );
}