import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/donation_status_model.dart';
import '../models/match_notification_model.dart';

class DonationStatusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final donationStatusCollection = 'donationStatuses';

  // Create a new donation status from an admin-approved match
  Future<String> createDonationStatus(MatchNotification matchNotification) async {
    try {
      // Validate that the notification is admin-approved
      if (matchNotification.status != 'admin_approved') {
        throw Exception('Cannot create donation status from unapproved match');
      }

      // Get user information from the related notifications
      List<String> relatedNotificationIds = List<String>.from(
        matchNotification.relatedNotifications ?? [],
      );

      if (relatedNotificationIds.isEmpty) {
        throw Exception('No related notifications found for this match');
      }

      // Create initial status history
      Map<String, DateTime> statusHistory = {
        'matched': DateTime.now(),
        'adminApproved': DateTime.now(),
      };

      String statusId = _firestore.collection('donationStatuses').doc().id;

      DonationStatus donationStatus = DonationStatus(
        id: statusId,
        matchId: matchNotification.id,
        donorId: matchNotification.user1Id,
        donorName: matchNotification.user1Name,
        recipientId: matchNotification.user2Id,
        recipientName: matchNotification.user2Name,
        organType: matchNotification.organType,
        status: DonationStatusType.adminApproved,
        statusTimestamp: DateTime.now(),
        adminNotes: 'Initial status created from admin-approved match',
        statusHistory: statusHistory,
      );

      await _firestore.collection('donationStatuses').doc(statusId).set(donationStatus.toMap());

      return statusId;
    } catch (e) {
      print('Error creating donation status: $e');
      throw e;
    }
  }

  // Update the status of a donation
  Future<void> updateDonationStatus(
    String donationId,
    DonationStatusType newStatus,
    String adminNotes,
  ) async {
    try {
      // Get the current donation status
      DocumentSnapshot doc = await _firestore.collection('donationStatuses').doc(donationId).get();

      if (!doc.exists) {
        throw Exception('Donation status not found');
      }

      DonationStatus currentStatus = DonationStatus.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );

      // Add the new status to history
      Map<String, DateTime> updatedHistory = Map.from(currentStatus.statusHistory);
      String statusKey = newStatus.toString().split('.').last;
      updatedHistory[statusKey] = DateTime.now();

      // Update the donation status
      DonationStatus updatedStatus = currentStatus.copyWith(
        status: newStatus,
        statusTimestamp: DateTime.now(),
        adminNotes: adminNotes,
        statusHistory: updatedHistory,
      );

      await _firestore.collection('donationStatuses').doc(donationId).update(updatedStatus.toMap());

      // Send notifications to users about status change
      await _notifyStatusChange(updatedStatus);
    } catch (e) {
      print('Error updating donation status: $e');
      throw e;
    }
  }

  // Get a single donation status
  Future<DonationStatus?> getDonationStatus(String donationId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('donationStatuses').doc(donationId).get();

      if (!doc.exists) {
        return null;
      }

      return DonationStatus.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      print('Error getting donation status: $e');
      throw e;
    }
  }

  // Get all donation statuses (for admin)
  Stream<List<DonationStatus>> getAllDonationStatuses() {
    return _firestore
        .collection('donationStatuses')
        .orderBy('statusTimestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => DonationStatus.fromMap(doc.data(), doc.id)).toList();
        });
  }

  // Get donation statuses for a specific user (donor or recipient)
  Stream<List<DonationStatus>> getUserDonationStatuses(String userId) {
    return _firestore
        .collection('donationStatuses')
        .where(
          Filter.or(Filter('donorId', isEqualTo: userId), Filter('recipientId', isEqualTo: userId)),
        )
        .orderBy('statusTimestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => DonationStatus.fromMap(doc.data(), doc.id)).toList();
        });
  }

  // Notify users about status changes
  Future<void> _notifyStatusChange(DonationStatus status) async {
    try {
      final statusInfo = status.getStatusInfo();

      // Create notification for donor
      await _createStatusNotification(
        recipientId: status.donorId,
        title: '${statusInfo['emoji']} ${statusInfo['title']}',
        message: statusInfo['description'],
        donationId: status.id,
      );

      // Create notification for recipient
      await _createStatusNotification(
        recipientId: status.recipientId,
        title: '${statusInfo['emoji']} ${statusInfo['title']}',
        message: statusInfo['description'],
        donationId: status.id,
      );
    } catch (e) {
      print('Error notifying users about status change: $e');
    }
  }

  // Create a status notification
  Future<void> _createStatusNotification({
    required String recipientId,
    required String title,
    required String message,
    required String donationId,
  }) async {
    try {
      await _firestore.collection('statusNotifications').add({
        'recipientId': recipientId,
        'title': title,
        'message': message,
        'donationId': donationId,
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating status notification: $e');
    }
  }

  // Get donation status by match ID
  Future<DonationStatus?> getDonationStatusByMatchId(String matchId) async {
    try {
      QuerySnapshot query =
          await _firestore
              .collection('donationStatuses')
              .where('matchId', isEqualTo: matchId)
              .limit(1)
              .get();

      if (query.docs.isEmpty) {
        return null;
      }

      return DonationStatus.fromMap(
        query.docs.first.data() as Map<String, dynamic>,
        query.docs.first.id,
      );
    } catch (e) {
      print('Error getting donation status by match ID: $e');
      throw e;
    }
  }

  // Filter donation statuses by status type
  Stream<List<DonationStatus>> getDonationStatusesByType(DonationStatusType statusType) {
    return _firestore
        .collection('donationStatuses')
        .where('status', isEqualTo: statusType.toString().split('.').last)
        .orderBy('statusTimestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => DonationStatus.fromMap(doc.data(), doc.id)).toList();
        });
  }

  // Add this method to the DonationStatusService class
  Future<List<DonationStatus>> getAllDonationStatusesFuture() async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection('donationStatuses')
              .orderBy('statusTimestamp', descending: true)
              .get();

      print('Retrieved ${snapshot.docs.length} donation status documents');

      List<DonationStatus> statuses = [];
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          print('Processing document: ${doc.id}');

          // Handle potential timestamp conversion issues
          DateTime statusTimestamp;
          try {
            final timestamp = data['statusTimestamp'];
            if (timestamp is Timestamp) {
              statusTimestamp = timestamp.toDate();
            } else {
              statusTimestamp = DateTime.now();
            }
          } catch (e) {
            print('Error parsing timestamp: $e');
            statusTimestamp = DateTime.now();
          }

          // Handle status enum conversion
          DonationStatusType status;
          try {
            final statusStr = data['status'] as String;
            status = DonationStatusType.values.firstWhere(
              (e) => e.toString().split('.').last == statusStr,
              orElse: () => DonationStatusType.matched,
            );
          } catch (e) {
            print('Error parsing status: $e');
            status = DonationStatusType.matched;
          }

          DonationStatus donationStatus = DonationStatus.fromMap(data, doc.id);
          statuses.add(donationStatus);
        } catch (e) {
          print('Error parsing document ${doc.id}: $e');
          // Continue to next document
        }
      }

      return statuses;
    } catch (e) {
      print('Error getting all donation statuses: $e');
      return [];
    }
  }
}
