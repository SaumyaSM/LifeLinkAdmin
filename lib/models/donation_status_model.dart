import 'package:cloud_firestore/cloud_firestore.dart';

enum DonationStatusType {
  matched,
  adminApproved,
  notifyUser,
  medicalTestingPhase,
  compatibilityVerified,
  consentAndClearance,
  organProcurement,
  transplantInProgress,
  postOpRecovery,
  immunosuppressionInitiated,
  followUpCare,
}

class DonationStatus {
  final String id;
  final String matchId; // ID of the original match notification
  final String donorId;
  final String donorName;
  final String recipientId;
  final String recipientName;
  final String organType;
  final DonationStatusType status;
  final DateTime statusTimestamp;
  final String? adminNotes;
  final Map<String, DateTime> statusHistory;

  const DonationStatus({
    required this.id,
    required this.matchId,
    required this.donorId,
    required this.donorName,
    required this.recipientId,
    required this.recipientName,
    required this.organType,
    required this.status,
    required this.statusTimestamp,
    this.adminNotes,
    required this.statusHistory,
  });

  // Factory constructor to create DonationStatus from Firestore document
  factory DonationStatus.fromMap(Map<String, dynamic> data, String id) {
    // Convert statusHistory from map of timestamps to map of DateTimes
    Map<String, DateTime> statusHistory = {};
    if (data['statusHistory'] != null) {
      final Map<String, dynamic> historyData = Map<String, dynamic>.from(
        data['statusHistory'],
      );
      historyData.forEach((key, value) {
        if (value is Timestamp) {
          statusHistory[key] = value.toDate();
        }
      });
    }

    return DonationStatus(
      id: id,
      matchId: data['matchId'] ?? '',
      donorId: data['donorId'] ?? '',
      donorName: data['donorName'] ?? '',
      recipientId: data['recipientId'] ?? '',
      recipientName: data['recipientName'] ?? '',
      organType: data['organType'] ?? '',
      status: _stringToStatusType(data['status'] ?? 'matched'),
      statusTimestamp:
          data['statusTimestamp'] is Timestamp
              ? (data['statusTimestamp'] as Timestamp).toDate()
              : DateTime.now(),
      adminNotes: data['adminNotes'],
      statusHistory: statusHistory,
    );
  }

  // Convert DonationStatus to Map for Firestore
  Map<String, dynamic> toMap() {
    // Convert statusHistory from map of DateTimes to map of Timestamps
    Map<String, Timestamp> firestoreStatusHistory = {};
    statusHistory.forEach((key, value) {
      firestoreStatusHistory[key] = Timestamp.fromDate(value);
    });

    return {
      'matchId': matchId,
      'donorId': donorId,
      'donorName': donorName,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'organType': organType,
      'status': status.toString().split('.').last,
      'statusTimestamp': Timestamp.fromDate(statusTimestamp),
      'adminNotes': adminNotes,
      'statusHistory': firestoreStatusHistory,
    };
  }

  // Create a copy of this DonationStatus with modified fields
  DonationStatus copyWith({
    String? id,
    String? matchId,
    String? donorId,
    String? donorName,
    String? recipientId,
    String? recipientName,
    String? organType,
    DonationStatusType? status,
    DateTime? statusTimestamp,
    String? adminNotes,
    Map<String, DateTime>? statusHistory,
  }) {
    return DonationStatus(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      donorId: donorId ?? this.donorId,
      donorName: donorName ?? this.donorName,
      recipientId: recipientId ?? this.recipientId,
      recipientName: recipientName ?? this.recipientName,
      organType: organType ?? this.organType,
      status: status ?? this.status,
      statusTimestamp: statusTimestamp ?? this.statusTimestamp,
      adminNotes: adminNotes ?? this.adminNotes,
      statusHistory: statusHistory ?? Map.from(this.statusHistory),
    );
  }

  // Helper method to get status display info
  Map<String, dynamic> getStatusInfo() {
    switch (status) {
      case DonationStatusType.matched:
        return {
          'emoji': '🟡',
          'title': 'Matched',
          'description':
              'Mutual match between donor and recipient found. Awaiting admin review.',
        };
      case DonationStatusType.adminApproved:
        return {
          'emoji': '🟠',
          'title': 'Admin Approved',
          'description':
              'Admin has reviewed and approved the match. Pre-transplant procedures to begin.',
        };
      case DonationStatusType.notifyUser:
        return {
          'emoji': '📞',
          'title': 'Notifies User via Call',
          'description':
              'Both donor and recipient are contacted by hospital staff via phone. They are informed about the match and invited for further medical evaluation and testing.',
        };
      case DonationStatusType.medicalTestingPhase:
        return {
          'emoji': '🟠',
          'title': 'Medical Testing Phase',
          'description':
              'Both donor and recipient undergo hospital-based lab tests (e.g., HLA typing, tissue typing, infectious disease screening).',
        };
      case DonationStatusType.compatibilityVerified:
        return {
          'emoji': '🟣',
          'title': 'Compatibility Verified',
          'description':
              'All required tests confirm high compatibility between donor and recipient.',
        };
      case DonationStatusType.consentAndClearance:
        return {
          'emoji': '🟤',
          'title': 'Consent & Clearance',
          'description':
              'Donor and recipient provide final informed consent. Psychological evaluations and legal paperwork are completed.',
        };
      case DonationStatusType.organProcurement:
        return {
          'emoji': '🟢',
          'title': 'Organ Procurement',
          'description':
              'The donor organ is surgically retrieved and preserved for transplant.',
        };
      case DonationStatusType.transplantInProgress:
        return {
          'emoji': '🔴',
          'title': 'Transplant in Progress',
          'description':
              'Recipient undergoes transplant surgery. Surgical team handles implantation.',
        };
      case DonationStatusType.postOpRecovery:
        return {
          'emoji': '🟩',
          'title': 'Post-Op Recovery',
          'description':
              'Patient is monitored in ICU or transplant unit for immediate recovery and rejection signs.',
        };
      case DonationStatusType.immunosuppressionInitiated:
        return {
          'emoji': '🔵',
          'title': 'Immunosuppression Initiated',
          'description':
              'Recipient begins medication to prevent organ rejection. Dosage adjusted based on early response.',
        };
      case DonationStatusType.followUpCare:
        return {
          'emoji': '✅',
          'title': 'Follow-Up Care',
          'description':
              'Long-term follow-up phase including outpatient visits, medication management, and psychological support.',
        };
    }
  }

  // Convert string to DonationStatusType enum
  static DonationStatusType _stringToStatusType(String status) {
    switch (status) {
      case 'matched':
        return DonationStatusType.matched;
      case 'adminApproved':
        return DonationStatusType.adminApproved;
      case 'notifyUser':
        return DonationStatusType.notifyUser;
      case 'medicalTestingPhase':
        return DonationStatusType.medicalTestingPhase;
      case 'compatibilityVerified':
        return DonationStatusType.compatibilityVerified;
      case 'consentAndClearance':
        return DonationStatusType.consentAndClearance;
      case 'organProcurement':
        return DonationStatusType.organProcurement;
      case 'transplantInProgress':
        return DonationStatusType.transplantInProgress;
      case 'postOpRecovery':
        return DonationStatusType.postOpRecovery;
      case 'immunosuppressionInitiated':
        return DonationStatusType.immunosuppressionInitiated;
      case 'followUpCare':
        return DonationStatusType.followUpCare;
      default:
        return DonationStatusType.matched;
    }
  }

  // Get the index of the current status in the flow
  int get statusIndex {
    return DonationStatusType.values.indexOf(status);
  }
}
