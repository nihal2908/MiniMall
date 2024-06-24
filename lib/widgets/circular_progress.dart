import 'package:flutter/material.dart';

void showCircularProgressIndicator(BuildContext context){
  showDialog(context: context, builder: (context){
    return Center(
      child: CircularProgressIndicator(),
    );
  });
}

class CenterIndicator extends StatelessWidget {
  const CenterIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: Colors.white,
      ),
    );
  }
}
