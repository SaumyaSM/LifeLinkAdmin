import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  late String id;
  late String title;
  late String date;
  late String description;

  EventModel({
    required this.id,
    required this.date,
    required this.description,
    required this.title,
  });

  EventModel.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    id = documentSnapshot['id'] ?? '';
    title = documentSnapshot['title'] ?? '';
    description = documentSnapshot['description'] ?? '';
    date = documentSnapshot['date'] ?? '';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'timeStamp': DateTime.now(),
    };
  }
}
