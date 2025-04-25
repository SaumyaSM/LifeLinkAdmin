import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_link_admin/services/donation_status_service.dart';
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

  static Future<int> getNewRequestsCount() async {
    // Using the exact string that would be in the database
    return await FirebaseFirestore.instance
        .collection(DonationStatusService.donationStatusCollection)
        .where('status', isEqualTo: 'adminApproved')
        .count()
        .get()
        .then((value) => value.count!);
  }

  static Future<int> getApprovedDonationsCount() async {
    // Using the exact string that would be in the database
    return await FirebaseFirestore.instance
        .collection(DonationStatusService.donationStatusCollection)
        .where('status', isEqualTo: 'adminApproved')
        .count()
        .get()
        .then((value) => value.count!);
  }

  static Future<int> getRejectedDonationsCount() async {
    // Update this string to match whatever rejection status is used in your database
    // Common options might be 'rejected', 'declined', 'denied', etc.
    return await FirebaseFirestore.instance
        .collection(DonationStatusService.donationStatusCollection)
        .where('status', isEqualTo: 'rejected')
        .count()
        .get()
        .then((value) => value.count!);
  }
}
