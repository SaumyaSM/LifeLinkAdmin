import 'package:flutter/material.dart';
import 'package:life_link_admin/screens/home_screen.dart';
import 'package:life_link_admin/services/auth_service.dart';
import 'package:life_link_admin/services/toast_service.dart';
import 'package:life_link_admin/widgets/button_widget.dart';
import 'package:life_link_admin/widgets/loading_widget.dart';
import 'package:life_link_admin/constants/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  final TextEditingController emailTEC = TextEditingController();
  final TextEditingController passwordTEC = TextEditingController();
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: LoadingWidget(inAsyncCall: isLoading, child: buildBody()),
      ),
    );
  }

  Widget buildBody() {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      decoration: const BoxDecoration(gradient: kGradientLogin),
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: screenSize.height * 0.15),
            _buildLogo(),
            SizedBox(height: screenSize.height * 0.05),
            _buildLoginCard(),
            SizedBox(height: screenSize.height * 0.03),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: Image.asset(
            'assets/images/LifeLink-Logo.PNG',
            width: 100,
            height: 100,
          ),
        ),
        const SizedBox(width: 15),
        Text(
          'LifeLink',
          style: TextStyle(
            fontSize: 45,
            fontWeight: FontWeight.bold,
            foreground:
                Paint()
                  ..shader = const LinearGradient(
                    colors: [Colors.white, Colors.white70],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    final screenSize = MediaQuery.of(context).size;
    final cardWidth = screenSize.width * (screenSize.width > 600 ? 0.5 : 0.85);

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'ADMIN',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 30),
          _buildEmailField(),
          const SizedBox(height: 50),
          _buildPasswordField(),

          const SizedBox(height: 50),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => onClickLogin(),
              style: ElevatedButton.styleFrom(
                backgroundColor: kOrangeColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 2,
              ),
              child: const Text(
                'LOGIN',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: emailTEC,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: 'Email',
        prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: passwordTEC,
      obscureText: obscurePassword,
      decoration: InputDecoration(
        hintText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              obscurePassword = !obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
      ),
    );
  }

  onClickLogin() async {
    if (emailTEC.text.trim() == '') {
      ToastService.displayErrorMotionToast(
        context: context,
        description: 'Email is Missing!',
      );
      return;
    }

    if (passwordTEC.text.trim() == '') {
      ToastService.displayErrorMotionToast(
        context: context,
        description: 'Password is Missing!',
      );
      return;
    }

    setState(() => isLoading = true);

    await AuthService.loginAdmin(
          email: emailTEC.text.trim(),
          password: passwordTEC.text.trim(),
        )
        .then((adminModel) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => HomeScreen(
                    isSuperAdmin: adminModel.isSuperAdmin,
                    adminModel:
                        adminModel, // Add this line to pass the admin model
                  ),
            ),
          );
        })
        .catchError((error) {
          setState(() => isLoading = false);
          ToastService.displayErrorMotionToast(
            context: context,
            description: 'Invalid Login!',
          );
        });
  }
}
