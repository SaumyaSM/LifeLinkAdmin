import 'package:flutter/material.dart';
import 'package:life_link_admin/screens/home_screen.dart';
import 'package:life_link_admin/services/auth_service.dart';
import 'package:life_link_admin/services/toast_service.dart';
import 'package:life_link_admin/widgets/button_widget.dart';
import 'package:life_link_admin/widgets/card_widget.dart';
import 'package:life_link_admin/widgets/loading_widget.dart';
import 'package:life_link_admin/widgets/text_input_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;

  TextEditingController emailTEC = TextEditingController();
  TextEditingController passwordTEC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(body: LoadingWidget(inAsyncCall: isLoading, child: buildBody())),
    );
  }

  Widget buildBody() {
    return Center(
      child: CardWidget(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.06),
            Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.025),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/LifeLink-Logo.PNG',
                    width: MediaQuery.of(context).size.width * 0.2,
                  ),
                  const SizedBox(width: 10),
                  Text('LifeLink'),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: CardWidget(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Text('LOGIN'),
                      const SizedBox(height: 30),
                      TextInputWidget(
                        controller: emailTEC,
                        title: 'Email',
                        icon: const Icon(Icons.mail_outline),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      TextInputWidget(
                        controller: passwordTEC,
                        obscureText: true,
                        title: 'Password',
                        icon: const Icon(Icons.lock_outline),
                      ),

                      const SizedBox(height: 20),
                      ButtonWidget(onTap: () => onClickLogin(), title: 'LOGIN'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  onClickLogin() async {
    if (emailTEC.text.trim() == '') {
      ToastService.displayErrorMotionToast(context: context, description: 'Email is Missing!');
      return;
    }

    if (passwordTEC.text.trim() == '') {
      ToastService.displayErrorMotionToast(context: context, description: 'Password is Missing!');
      return;
    }

    setState(() => isLoading = true);

    await AuthService.loginAdmin(email: emailTEC.text.trim(), password: passwordTEC.text.trim())
        .then((value) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(isSuperAdmin: value.isSuperAdmin)),
          );
        })
        .catchError((error) {
          setState(() => isLoading = false);
          ToastService.displayErrorMotionToast(context: context, description: 'Invalid Login!');
          return;
        });
  }
}
