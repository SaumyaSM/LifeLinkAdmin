import 'package:flutter/material.dart';
import 'package:life_link_admin/widgets/card_widget.dart';

class TitleCard extends StatelessWidget {
  String title;
  String value;
  TitleCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return CardWidget(child: Column(children: [Text(title), Text(value)]));
  }
}
