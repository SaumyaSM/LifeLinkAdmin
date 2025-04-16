import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:life_link_admin/screens/home_screen.dart';
import 'package:life_link_admin/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyA9W35HY2MEnKrZKM-cAEA0pO8hezbBqAk",
      projectId: "lifelink-test",
      messagingSenderId: "482307347175",
      appId: "1:482307347175:web:ffb7942c6a120867f40842",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Life Link', home: HomeScreen(isSuperAdmin: true));
  }
}
