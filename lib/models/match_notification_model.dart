import 'package:cloud_firestore/cloud_firestore.dart';

class MatchNotification {
  final String id;
  final String senderUserId;
  final String senderName;
  final String receiverUserId;
  final int matchScore;
  final String matchType;
  final String organType;
  final String status;
  final DateTime timestamp;
  final String senderRole;
  final String receiverRole;
  final bool adminReviewed;
  final String? adminFeedback;

  // Additional fields for admin notifications
  final String user1Id;
  final String user1Name;
  final String user2Id;
  final String user2Name;
  final List<String>? relatedNotifications;

  const MatchNotification({
    required this.id,
    required this.senderUserId,
    required this.senderName,
    required this.receiverUserId,
    required this.matchScore,
    required this.matchType,
    required this.organType,
    required this.status,
    required this.timestamp,
    required this.senderRole,
    required this.receiverRole,
    this.adminReviewed = false,
    this.adminFeedback,
    this.user1Id = '',
    this.user1Name = '',
    this.user2Id = '',
    this.user2Name = '',
    this.relatedNotifications,
  });

  // Factory constructor to create MatchNotification from Firestore document
  factory MatchNotification.fromMap(Map<String, dynamic> data, String id) {
    // Handle possible timestamp formats (Timestamp or DateTime)
    DateTime timestamp;
    if (data['timestamp'] is Timestamp) {
      timestamp = (data['timestamp'] as Timestamp).toDate();
    } else if (data['timestamp'] is DateTime) {
      timestamp = data['timestamp'] as DateTime;
    } else {
      timestamp = DateTime.now(); // Default fallback
    }

    return MatchNotification(
      id: id,
      senderUserId: data['senderUserId'] ?? '',
      senderName: data['senderName'] ?? '',
      receiverUserId: data['receiverUserId'] ?? '',
      matchScore: data['matchScore'] ?? 0,
      matchType: data['matchType'] ?? '',
      organType: data['organType'] ?? '',
      status: data['status'] ?? 'pending',
      timestamp: timestamp,
      senderRole: data['senderRole'] ?? '',
      receiverRole: data['receiverRole'] ?? '',
      adminReviewed: data['adminReviewed'] ?? false,
      adminFeedback: data['adminFeedback'],
      user1Id: data['user1Id'] ?? '',
      user1Name: data['user1Name'] ?? '',
      user2Id: data['user2Id'] ?? '',
      user2Name: data['user2Name'] ?? '',
      relatedNotifications:
          data['relatedNotifications'] != null
              ? List<String>.from(data['relatedNotifications'])
              : null,
    );
  }

  // Convert MatchNotification to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderUserId': senderUserId,
      'senderName': senderName,
      'receiverUserId': receiverUserId,
      'matchScore': matchScore,
      'matchType': matchType,
      'organType': organType,
      'status': status,
      'timestamp': timestamp,
      'senderRole': senderRole,
      'receiverRole': receiverRole,
      'adminReviewed': adminReviewed,
      'adminFeedback': adminFeedback,
      'user1Id': user1Id,
      'user1Name': user1Name,
      'user2Id': user2Id,
      'user2Name': user2Name,
      'relatedNotifications': relatedNotifications,
    };
  }

  // Factory method for creating donor-to-recipient matches
  factory MatchNotification.createDonorToRecipientMatch({
    required String id,
    required String donorUserId,
    required String donorName,
    required String recipientUserId,
    required int matchScore,
    required String organType,
    required String status,
    required DateTime timestamp,
  }) {
    return MatchNotification(
      id: id,
      senderUserId: donorUserId,
      senderName: donorName,
      receiverUserId: recipientUserId,
      matchScore: matchScore,
      matchType: 'donor_to_recipient',
      organType: organType,
      status: status,
      timestamp: timestamp,
      senderRole: 'donor',
      receiverRole: 'recipient',
    );
  }

  // Factory method for creating recipient-to-donor matches
  factory MatchNotification.createRecipientToDonorMatch({
    required String id,
    required String recipientUserId,
    required String recipientName,
    required String donorUserId,
    required int matchScore,
    required String organType,
    required String status,
    required DateTime timestamp,
  }) {
    return MatchNotification(
      id: id,
      senderUserId: recipientUserId,
      senderName: recipientName,
      receiverUserId: donorUserId,
      matchScore: matchScore,
      matchType: 'recipient_to_donor',
      organType: organType,
      status: status,
      timestamp: timestamp,
      senderRole: 'recipient',
      receiverRole: 'donor',
    );
  }

  // Create a copy of this MatchNotification with modified fields
  MatchNotification copyWith({
    String? id,
    String? senderUserId,
    String? senderName,
    String? receiverUserId,
    int? matchScore,
    String? matchType,
    String? organType,
    String? status,
    DateTime? timestamp,
    String? senderRole,
    String? receiverRole,
    bool? adminReviewed,
    String? adminFeedback,
    String? user1Id,
    String? user1Name,
    String? user2Id,
    String? user2Name,
    List<String>? relatedNotifications,
  }) {
    return MatchNotification(
      id: id ?? this.id,
      senderUserId: senderUserId ?? this.senderUserId,
      senderName: senderName ?? this.senderName,
      receiverUserId: receiverUserId ?? this.receiverUserId,
      matchScore: matchScore ?? this.matchScore,
      matchType: matchType ?? this.matchType,
      organType: organType ?? this.organType,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      senderRole: senderRole ?? this.senderRole,
      receiverRole: receiverRole ?? this.receiverRole,
      adminReviewed: adminReviewed ?? this.adminReviewed,
      adminFeedback: adminFeedback ?? this.adminFeedback,
      user1Id: user1Id ?? this.user1Id,
      user1Name: user1Name ?? this.user1Name,
      user2Id: user2Id ?? this.user2Id,
      user2Name: user2Name ?? this.user2Name,
      relatedNotifications: relatedNotifications ?? this.relatedNotifications,
    );
  }
}
