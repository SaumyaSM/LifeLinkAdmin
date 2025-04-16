import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_link_admin/services/user_service.dart';

class DashboardService {
  static Future<int> getDonatorsCount() async {
    return await FirebaseFirestore.instance
        .collection(UserService.userCollection)
        .where('isDonor', isEqualTo: true)
        .count()
        .get()
        .then((value) => value.count!);
  }

  static Future<int> getRecipientsCount() async {
    return await FirebaseFirestore.instance
        .collection(UserService.userCollection)
        .where('isDonor', isEqualTo: false)
        .count()
        .get()
        .then((value) => value.count!);
  }
}
