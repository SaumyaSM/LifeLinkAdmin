import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_link_admin/models/user_model.dart';

class UserService {
  static final userCollection = 'users';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    await FirebaseFirestore.instance
        .collection(userCollection)
        .doc(admin.id)
        .delete();
  }

  Future<UserModel> getUserById(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      return UserModel.fromDocumentSnapshot(userDoc);
    } catch (e) {
      print('Error getting user by ID: $e');
      throw e;
    }
  }

  // Get all donors
  Future<List<UserModel>> getAllDonors() async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection('users')
              .where('isDonor', isEqualTo: true)
              .get();

      return snapshot.docs
          .map((doc) => UserModel.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error getting all donors: $e');
      throw e;
    }
  }

  // Get all recipients
  Future<List<UserModel>> getAllRecipients() async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection('users')
              .where('isDonor', isEqualTo: false)
              .get();

      return snapshot.docs
          .map((doc) => UserModel.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error getting all recipients: $e');
      throw e;
    }
  }

  // Get donors of specific organ type
  Future<List<UserModel>> getDonorsByOrganType(String organType) async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection('users')
              .where('isDonor', isEqualTo: true)
              .where('organType', isEqualTo: organType)
              .get();

      return snapshot.docs
          .map((doc) => UserModel.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error getting donors by organ type: $e');
      throw e;
    }
  }

  // Get recipients of specific organ type
  Future<List<UserModel>> getRecipientsByOrganType(String organType) async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection('users')
              .where('isDonor', isEqualTo: false)
              .where('organType', isEqualTo: organType)
              .get();

      return snapshot.docs
          .map((doc) => UserModel.fromDocumentSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error getting recipients by organ type: $e');
      throw e;
    }
  }
}
