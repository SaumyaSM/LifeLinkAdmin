import 'package:flutter/material.dart';
import 'package:life_link_admin/services/dashboard_service.dart';
import 'package:life_link_admin/widgets/card_widget.dart';
import 'package:life_link_admin/widgets/title_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int donatorsCount = 0;
  int recipientsCount = 0;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() async {
      donatorsCount = await DashboardService.getDonatorsCount();
      recipientsCount = await DashboardService.getRecipientsCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return buildScreen();
  }

  Widget buildScreen() {
    return Column(children: [countCards()]);
  }

  Widget countCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TitleCard(title: 'Donators', value: donatorsCount.toString()),
        TitleCard(title: 'Recipients', value: recipientsCount.toString()),
      ],
    );
  }
}
