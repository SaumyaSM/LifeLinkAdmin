import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModel {
  late String id;
  late String name;
  late bool isSuperAdmin;
  late String email;

  AdminModel({
    required this.id,
    required this.name,
    required this.isSuperAdmin,
    required this.email,
  });

  AdminModel.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    final data = documentSnapshot.data() as Map<String, dynamic>;

    id = data['id'] ?? '';
    name = data['name'] ?? '';
    isSuperAdmin = data['isSuperAdmin'] ?? false;
    email = data['email'] ?? '';
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'isSuperAdmin': isSuperAdmin, 'email': email};
  }
}
