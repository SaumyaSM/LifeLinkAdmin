import 'package:flutter/material.dart';
import 'package:life_link_admin/constants/colors.dart';

class ButtonWidget extends StatelessWidget {
  Function onTap;
  String title;
  Color? color;
  ButtonWidget({super.key, required this.onTap, required this.title, this.color = kOrangeColor});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => onTap(),
      style: TextButton.styleFrom(splashFactory: NoSplash.splashFactory),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: Text(title, style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
