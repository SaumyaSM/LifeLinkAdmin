import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:life_link_admin/models/admin_model.dart';
import 'package:life_link_admin/services/auth_service.dart';

class AdminService {
  static const adminCollection = 'admin';

  static Future<AdminModel> getAdminData(String id) async {
    return AdminModel.fromDocumentSnapshot(
      await FirebaseFirestore.instance
          .collection(adminCollection)
          .doc(id)
          .get(),
    );
  }

  static Future<List<AdminModel>> getAdminList() async {
    List<AdminModel> list = [];

    await FirebaseFirestore.instance.collection(adminCollection).get().then((
      QuerySnapshot querySnapshot,
    ) {
      querySnapshot.docs.forEach((doc) {
        list.add(AdminModel.fromDocumentSnapshot(doc));
      });
    });

    return list;
  }

  static Future<void> createAdmin(
    AdminModel admin, {
    bool sendResetEmail = true,
  }) async {
    await FirebaseFirestore.instance
        .collection(adminCollection)
        .doc(admin.id)
        .set(admin.toMap())
        .then((value) async {
          // Only send password reset email if option is selected
          if (sendResetEmail) {
            await AuthService.sendPasswordResetEmail(admin.email);
          }
        });
  }

  static Future<void> deleteAdmin(AdminModel admin) async {
    await FirebaseFirestore.instance
        .collection(adminCollection)
        .doc(admin.id)
        .delete();
  }
}
