import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void push({required BuildContext context, required Widget page}){
  Navigator.push(context, MaterialPageRoute(builder: (context)=>page));
}

void pop({required BuildContext context}){
  Navigator.pop(context);
}

void pushReplacement({required BuildContext context, required Widget page}){
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>page));
}

void pushAndRemoveAll({required BuildContext context, required Widget page}){
  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>page), (route) => false,);
}