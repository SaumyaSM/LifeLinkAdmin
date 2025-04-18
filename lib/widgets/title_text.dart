import 'package:flutter/material.dart';

class TitleText extends StatelessWidget {
  String text;
  TitleText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25));
  }
}
