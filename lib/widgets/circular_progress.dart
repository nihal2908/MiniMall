import 'package:flutter/material.dart';

void showCircularProgressIndicator(BuildContext context){
  showDialog(context: context, builder: (context){
    return const Center(
      child: CircularProgressIndicator(),
    );
  });
}

// ignore: must_be_immutable
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
