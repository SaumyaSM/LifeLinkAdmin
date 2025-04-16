import 'package:flutter/material.dart';
import 'package:life_link_admin/widgets/loading_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(canPop: false, child: LoadingWidget(inAsyncCall: isLoading));
  }
}
