import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModel {
  late String id;
  late String name;
  late String type;
  late String email;

  AdminModel({required this.id, required this.name, required this.type, required this.email});

  AdminModel.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    final data = documentSnapshot.data() as Map<String, dynamic>;

    id = data['id'] ?? '';
    name = data['name'] ?? '';
    type = data['type'] ?? '';
    email = data['email'] ?? '';
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'type': type, 'email': email};
  }
}
