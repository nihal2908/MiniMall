import 'package:flutter/material.dart';

void showCircularProgressIndicator(BuildContext context){
  showDialog(context: context, builder: (context){
    return Center(
      child: CircularProgressIndicator(),
    );
  });
}

class CenterIndicator extends StatelessWidget {
  Color? color;
  CenterIndicator({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: color ?? Colors.white,
      ),
    );
  }
}
