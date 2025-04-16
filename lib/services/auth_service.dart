import 'package:firebase_auth/firebase_auth.dart';
import 'package:life_link_admin/models/admin_model.dart';
import 'package:life_link_admin/services/admin_service.dart';

class AuthService {
  static const adminCollection = 'admins';

  static Future<AdminModel> loginAdmin({required String email, required String password}) async {
    UserCredential user = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return await AdminService.getAdminData(user.user!.uid);
  }

  static Future<void> logoutAdmin() async {
    await FirebaseAuth.instance.signOut();
  }

  static Future<String> registerAdmin(String email, String password) async {
    return await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) => value.user!.uid);
  }
}
