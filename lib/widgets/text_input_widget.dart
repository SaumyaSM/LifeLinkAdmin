import 'package:flutter/material.dart';

class TextInputWidget extends StatelessWidget {
  TextEditingController controller;
  String title;
  bool obscureText;
  TextInputType keyboardType;
  bool enabled;
  int? maxLength;
  int maxLines;
  Icon? icon;

  TextInputWidget({
    super.key,
    required this.controller,
    required this.title,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.maxLength,
    this.maxLines = 1,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      maxLength: maxLength,
      //cursorColor: kColorGold,
      keyboardType: keyboardType,
      enabled: enabled,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: title,
        counterStyle: const TextStyle(color: Colors.white24),
        enabledBorder: const UnderlineInputBorder(
          //borderSide: BorderSide(color: kColorGoldLight),
        ),
        focusedBorder: const UnderlineInputBorder(
          //borderSide: BorderSide(color: kColorGoldLight),
        ),
        prefixIcon: icon != null ? Icon(icon!.icon, color: Colors.grey) : null,
      ),
    );
  }
}
