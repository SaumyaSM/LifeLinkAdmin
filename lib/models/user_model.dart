import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  late String id;
  late String fullName;
  late String dateOfBirth;
  late String gender;
  late String nic;
  late String contact;
  late String address;
  late String city;
  late bool isDonor;
  late String bloodType;
  late String organType;
  late Map<String, String> hlaTyping;
  late bool isTestsCompleted;
  late List<String> history;
  late int waitingTime;
  late String imageUrl;
  late Map<String, String> medicalDocuments;

  UserModel({
    required this.id,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.nic,
    required this.contact,
    required this.address,
    required this.city,
    required this.isDonor,
    required this.bloodType,
    required this.organType,
    required this.hlaTyping,
    required this.isTestsCompleted,
    required this.history,
    required this.waitingTime,
    required this.imageUrl,
    this.medicalDocuments = const {},
  });

  UserModel.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    final data = documentSnapshot.data() as Map<String, dynamic>;

    id = data['id'] ?? '';
    fullName = data['fullName'] ?? '';
    dateOfBirth = data['dateOfBirth'] ?? '';
    gender = data['gender'] ?? '';
    nic = data['nic'] ?? '';
    contact = data['contact'] ?? '';
    address = data['address'] ?? '';
    city = data['city'] ?? '';
    isDonor = data['isDonor'] ?? false;
    bloodType = data['bloodType'] ?? '';
    organType = data['organType'] ?? '';

    final hlaMap = data['hlaTyping'] as Map<String, dynamic>? ?? {};
    hlaTyping = hlaMap.map((key, value) => MapEntry(key, value.toString()));

    isTestsCompleted = data['isTestsCompleted'] ?? false;
    history = List<String>.from(data['history'] ?? []);
    waitingTime =
        data['waitingTime'] != null
            ? int.tryParse(data['waitingTime'].toString()) ?? 0
            : 0;
    imageUrl = data['imageUrl'] ?? '';

    final docsMap = data['medicalDocuments'] as Map<String, dynamic>? ?? {};
    medicalDocuments = docsMap.map(
      (key, value) => MapEntry(key, value.toString()),
    );
  }
}
