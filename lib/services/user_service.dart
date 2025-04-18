import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_link_admin/models/user_model.dart';

class UserService {
  static final userCollection = 'users';

  static Future<List<UserModel>> getUsersList({required bool isDonor}) async {
    List<UserModel> list = [];

    await FirebaseFirestore.instance
        .collection(userCollection)
        .where('isDonor', isEqualTo: isDonor)
        .get()
        .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            list.add(UserModel.fromDocumentSnapshot(doc));
          });
        });

    return list;
  }

  static Future<void> deleteUser(UserModel admin) async {
    await FirebaseFirestore.instance.collection(userCollection).doc(admin.id).delete();
  }
}
