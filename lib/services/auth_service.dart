import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:life_link_admin/models/admin_model.dart';
import 'package:life_link_admin/services/admin_service.dart';

class AuthService {
  static const adminCollection = 'admins';

  static Future<AdminModel> loginAdmin({
    required String email,
    required String password,
  }) async {
    UserCredential user = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return await AdminService.getAdminData(user.user!.uid);
  }

  static Future<void> logoutAdmin() async {
    await FirebaseAuth.instance.signOut();
  }

  // Original method that generates a random password
  static Future<String> registerAdmin(String email) async {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rand = Random.secure();
    String newPass =
        List.generate(8, (index) => chars[rand.nextInt(chars.length)]).join();

    return await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: newPass)
        .then((value) => value.user!.uid);
  }

  // New method that accepts a custom password
  static Future<String> registerAdminWithPassword({
    required String email,
    required String password,
  }) async {
    return await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) => value.user!.uid);
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }
}
