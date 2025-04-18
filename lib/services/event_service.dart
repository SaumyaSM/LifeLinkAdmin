import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_link_admin/models/events_model.dart';

class EventService {
  static const eventsCollection = 'events';

  static Future<List<EventModel>> getEventsList() async {
    List<EventModel> list = [];

    await FirebaseFirestore.instance.collection(eventsCollection).orderBy('timeStamp').get().then((
      QuerySnapshot querySnapshot,
    ) {
      querySnapshot.docs.forEach((doc) {
        list.add(EventModel.fromDocumentSnapshot(doc));
      });
    });

    return list;
  }

  static Future<void> createEvent(EventModel model) async {
    await FirebaseFirestore.instance.collection(eventsCollection).doc(model.id).set(model.toMap());
  }

  static Future<void> deleteEvent(String id) async {
    await FirebaseFirestore.instance.collection(eventsCollection).doc(id).delete();
  }
}
