import 'package:flutter/material.dart';

class UsersScreen extends StatefulWidget {
  bool isDonor;
  UsersScreen({super.key, required this.isDonor});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
