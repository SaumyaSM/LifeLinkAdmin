import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match_notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send a match notification (initial "like")
  Future<void> sendMatchNotification(MatchNotification notification) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap());
    } catch (e) {
      print('Error sending notification: $e');
      throw e;
    }
  }

  // Get notifications for a specific user
  Stream<List<MatchNotification>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('receiverUserId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MatchNotification.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Update notification status when user likes/dislikes a match
  Future<void> updateNotificationStatus(
    String notificationId,
    String status,
  ) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'status': status,
      });
    } catch (e) {
      print('Error updating notification status: $e');
      throw e;
    }
  }

  // Send a "liked" notification
  Future<String> sendLikeNotification(
    String senderUserId,
    String senderName,
    String receiverUserId,
    int matchScore,
    String matchType,
    String organType,
    String senderRole,
    String receiverRole,
  ) async {
    try {
      String notificationId = _firestore.collection('notifications').doc().id;

      MatchNotification notification = MatchNotification(
        id: notificationId,
        senderUserId: senderUserId,
        senderName: senderName,
        receiverUserId: receiverUserId,
        matchScore: matchScore,
        matchType: matchType,
        organType: organType,
        status: 'liked', // Initial status is "liked"
        timestamp: DateTime.now(),
        senderRole: senderRole,
        receiverRole: receiverRole,
      );

      await sendMatchNotification(notification);
      return notificationId;
    } catch (e) {
      print('Error sending like notification: $e');
      throw e;
    }
  }

  // Update to "matched" when both users like each other
  // Update to "matched" when both users like each other
  // Update to "matched" when both users like each other
  Future<void> createMatchedNotification(
    String originalNotificationId,
    String otherNotificationId,
  ) async {
    try {
      print(
        'Creating matched notification between $originalNotificationId and $otherNotificationId',
      );

      // Verify we're not using the same notification ID twice
      if (originalNotificationId == otherNotificationId) {
        throw Exception('Cannot match a notification with itself');
      }

      // Get both notifications
      DocumentSnapshot originalDoc =
          await _firestore
              .collection('notifications')
              .doc(originalNotificationId)
              .get();

      DocumentSnapshot otherDoc =
          await _firestore
              .collection('notifications')
              .doc(otherNotificationId)
              .get();

      if (!originalDoc.exists || !otherDoc.exists) {
        throw Exception('One or more notifications not found');
      }

      // Extract data from original notifications
      Map<String, dynamic> originalData =
          originalDoc.data() as Map<String, dynamic>;
      Map<String, dynamic> otherData = otherDoc.data() as Map<String, dynamic>;

      // Verify we're not matching the same user with themselves
      String originalSenderId = originalData['senderUserId'];
      String otherSenderId = otherData['senderUserId'];

      print('Original sender: $originalSenderId, Other sender: $otherSenderId');

      if (originalSenderId == otherSenderId) {
        print('ERROR: Attempting to match a user with themselves');
        throw Exception('Cannot match a user with themselves');
      }

      // Update status to "matched" for both notifications
      await _firestore
          .collection('notifications')
          .doc(originalNotificationId)
          .update({'status': 'matched'});

      await _firestore
          .collection('notifications')
          .doc(otherNotificationId)
          .update({'status': 'matched'});

      // Create a new notification for admin review
      String adminNotificationId =
          _firestore.collection('notifications').doc().id;

      // Create admin notification
      MatchNotification adminNotification = MatchNotification(
        id: adminNotificationId,
        senderUserId: originalData['senderUserId'],
        senderName: 'System',
        receiverUserId: 'admin', // Special receiver ID for admin notifications
        matchScore: originalData['matchScore'],
        matchType: 'admin_approval',
        organType: originalData['organType'],
        status: 'pending',
        timestamp: DateTime.now(),
        adminReviewed: false,
        senderRole: originalData['senderRole'],
        receiverRole: 'admin',
      );

      // Add references to the original notifications
      Map<String, dynamic> adminNotificationMap = adminNotification.toMap();
      adminNotificationMap['relatedNotifications'] = [
        originalNotificationId,
        otherNotificationId,
      ];

      // Debug the user information we're about to set
      print(
        'Setting user1 to ${originalData['senderName']} (${originalData['senderUserId']})',
      );
      print(
        'Setting user2 to ${otherData['senderName']} (${otherData['senderUserId']})',
      );

      // Make sure we set the distinct users for the admin notification
      adminNotificationMap['user1Id'] = originalData['senderUserId'];
      adminNotificationMap['user1Name'] = originalData['senderName'];
      adminNotificationMap['user2Id'] = otherData['senderUserId'];
      adminNotificationMap['user2Name'] = otherData['senderName'];

      await _firestore
          .collection('notifications')
          .doc(adminNotificationId)
          .set(adminNotificationMap);

      print('Successfully created admin notification $adminNotificationId');
    } catch (e) {
      print('Error creating matched notification: $e');
      throw e;
    }
  }

  // Admin approval of a match
  Future<void> adminApproveMatch(
    String adminNotificationId,
    String feedback,
  ) async {
    try {
      // Get the admin notification document
      DocumentSnapshot adminDoc =
          await _firestore
              .collection('notifications')
              .doc(adminNotificationId)
              .get();

      if (!adminDoc.exists) {
        throw Exception('Admin notification not found');
      }

      Map<String, dynamic> adminData = adminDoc.data() as Map<String, dynamic>;
      List<String> relatedNotifications = List<String>.from(
        adminData['relatedNotifications'],
      );

      // Update admin notification status
      await _firestore
          .collection('notifications')
          .doc(adminNotificationId)
          .update({
            'status': 'admin_approved',
            'adminReviewed': true,
            'adminFeedback': feedback,
          });

      // Update both user notifications
      for (String notificationId in relatedNotifications) {
        await _firestore.collection('notifications').doc(notificationId).update(
          {
            'status': 'admin_approved',
            'adminReviewed': true,
            'adminFeedback': feedback,
          },
        );
      }

      // Send acceptance notifications to both users
      String user1Id = adminData['user1Id'];
      String user2Id = adminData['user2Id'];
      String organType = adminData['organType'];

      await sendAcceptanceNotification(user1Id, 'Medical Team', organType);
      await sendAcceptanceNotification(user2Id, 'Medical Team', organType);
    } catch (e) {
      print('Error in admin approval process: $e');
      throw e;
    }
  }

  // Admin rejection of a match
  Future<void> adminRejectMatch(
    String adminNotificationId,
    String feedback,
  ) async {
    try {
      // Get the admin notification document
      DocumentSnapshot adminDoc =
          await _firestore
              .collection('notifications')
              .doc(adminNotificationId)
              .get();

      if (!adminDoc.exists) {
        throw Exception('Admin notification not found');
      }

      Map<String, dynamic> adminData = adminDoc.data() as Map<String, dynamic>;
      List<String> relatedNotifications = List<String>.from(
        adminData['relatedNotifications'],
      );

      // Update admin notification status
      await _firestore
          .collection('notifications')
          .doc(adminNotificationId)
          .update({
            'status': 'admin_rejected',
            'adminReviewed': true,
            'adminFeedback': feedback,
          });

      // Update both user notifications
      for (String notificationId in relatedNotifications) {
        await _firestore.collection('notifications').doc(notificationId).update(
          {
            'status': 'admin_rejected',
            'adminReviewed': true,
            'adminFeedback': feedback,
          },
        );
      }
    } catch (e) {
      print('Error in admin rejection process: $e');
      throw e;
    }
  }

  // Get all matches pending admin review
  Stream<List<MatchNotification>> getAdminPendingReviews() {
    return _firestore
        .collection('notifications')
        .where('receiverUserId', isEqualTo: 'admin')
        .where('adminReviewed', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MatchNotification.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Stream<MatchNotification?> getNotificationById(String notificationId) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            return MatchNotification.fromMap(snapshot.data()!, snapshot.id);
          }
          return null;
        });
  }

  Future<void> sendAcceptanceNotification(
    String recipientUserId,
    String senderName,
    String organType,
  ) async {
    try {
      String notificationId = _firestore.collection('notifications').doc().id;

      MatchNotification notification = MatchNotification(
        id: notificationId,
        senderUserId: '',
        senderName: senderName,
        receiverUserId: recipientUserId,
        matchScore: 0,
        matchType: 'acceptance',
        organType: organType,
        status: 'info',
        timestamp: DateTime.now(),
        senderRole: 'system', // System is sending this notification
        receiverRole: 'user', // User is receiving this notification
      );

      await sendMatchNotification(notification);
    } catch (e) {
      print('Error sending acceptance notification: $e');
      throw e;
    }
  }

  // Check if there's an existing match in any state between two users
  // Check if there's an existing match between two users (must be different users)
  Future<MatchNotification?> getExistingMatchBetweenUsers(
    String user1Id,
    String user2Id,
  ) async {
    try {
      // Safety check - don't allow matching with self
      if (user1Id == user2Id) {
        print(
          'ERROR: Attempting to find a match between a user and themselves',
        );
        return null;
      }

      print('Checking for existing match between $user1Id and $user2Id');

      // Query for existing notifications with user2 as sender and user1 as receiver
      // This is the reverse direction we need for a mutual match
      QuerySnapshot query =
          await FirebaseFirestore.instance
              .collection('notifications')
              .where('senderUserId', isEqualTo: user2Id)
              .where('receiverUserId', isEqualTo: user1Id)
              .where('status', whereIn: ['pending', 'liked'])
              .get();

      // Check if any notifications were found
      if (query.docs.isNotEmpty) {
        MatchNotification match = MatchNotification.fromMap(
          query.docs.first.data() as Map<String, dynamic>,
          query.docs.first.id,
        );

        print(
          'Found existing match: ${match.id} from ${match.senderName} to receiver',
        );
        return match;
      }

      return null;
    } catch (e) {
      print('Error checking existing matches: $e');
      return null;
    }
  }

  Future<bool> hasExistingMatchRequest(
    String senderId,
    String receiverId,
  ) async {
    try {
      // Query for any existing notifications with sender as the sender and receiver as the receiver
      QuerySnapshot query =
          await _firestore
              .collection('notifications')
              .where('senderUserId', isEqualTo: senderId)
              .where('receiverUserId', isEqualTo: receiverId)
              .where('status', whereIn: ['pending', 'liked'])
              .limit(1)
              .get();

      // Return true if any matching documents are found
      return query.docs.isNotEmpty;
    } catch (e) {
      print('Error checking for existing match request: $e');
      return false;
    }
  }

  // New helper methods to use the factory methods from MatchNotification

  Future<String> sendDonorToRecipientNotification(
    String donorUserId,
    String donorName,
    String recipientUserId,
    int matchScore,
    String organType,
  ) async {
    try {
      String notificationId = _firestore.collection('notifications').doc().id;

      MatchNotification notification =
          MatchNotification.createDonorToRecipientMatch(
            id: notificationId,
            donorUserId: donorUserId,
            donorName: donorName,
            recipientUserId: recipientUserId,
            matchScore: matchScore,
            organType: organType,
            status: 'pending',
            timestamp: DateTime.now(),
          );

      await sendMatchNotification(notification);
      return notificationId;
    } catch (e) {
      print('Error sending donor to recipient notification: $e');
      throw e;
    }
  }

  Future<String> sendRecipientToDonorNotification(
    String recipientUserId,
    String recipientName,
    String donorUserId,
    int matchScore,
    String organType,
  ) async {
    try {
      String notificationId = _firestore.collection('notifications').doc().id;

      MatchNotification notification =
          MatchNotification.createRecipientToDonorMatch(
            id: notificationId,
            recipientUserId: recipientUserId,
            recipientName: recipientName,
            donorUserId: donorUserId,
            matchScore: matchScore,
            organType: organType,
            status: 'pending',
            timestamp: DateTime.now(),
          );

      await sendMatchNotification(notification);
      return notificationId;
    } catch (e) {
      print('Error sending recipient to donor notification: $e');
      throw e;
    }
  }

  // Add this method to the NotificationService class
  // Get all matches with a specific admin review status (approved/rejected)
  Stream<List<MatchNotification>> getAdminReviewedMatches(String status) {
    return _firestore
        .collection('notifications')
        .where('receiverUserId', isEqualTo: 'admin')
        .where('status', isEqualTo: status)
        .where('adminReviewed', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MatchNotification.fromMap(doc.data(), doc.id))
              .toList();
        });
  }
}
