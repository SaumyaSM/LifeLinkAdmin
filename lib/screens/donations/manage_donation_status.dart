import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/donation_status_model.dart';
import '../../services/donation_status_service.dart';
import '../../services/notification_service.dart';
import '../../models/match_notification_model.dart';
import '../../constants/colors.dart';

class ManageDonationStatusScreen extends StatefulWidget {
  const ManageDonationStatusScreen({Key? key}) : super(key: key);

  @override
  _ManageDonationStatusScreenState createState() =>
      _ManageDonationStatusScreenState();
}

class _ManageDonationStatusScreenState
    extends State<ManageDonationStatusScreen> {
  final DonationStatusService _donationStatusService = DonationStatusService();
  final NotificationService _notificationService = NotificationService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  MatchNotification? _selectedMatch;
  DonationStatus? _selectedDonationStatus;
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Donation Status'),
        backgroundColor: kMainButtonColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side: List of admin approved matches
                Expanded(flex: 1, child: _buildApprovedMatchesList()),
                // Divider
                Container(width: 1, color: Colors.grey.shade300),
                // Right side: Status progress tracker or empty state
                Expanded(
                  flex: 2,
                  child:
                      _isLoading
                          ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                kMainButtonColor,
                              ),
                            ),
                          )
                          : _selectedDonationStatus != null
                          ? _buildStatusProgressTracker(
                            _selectedDonationStatus!,
                          )
                          : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.volunteer_activism,
                                  size: 80,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Select a match to view status details',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: kMainButtonColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by donor or recipient name',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = "";
                      });
                    },
                  )
                  : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 20,
          ),
        ),
        style: const TextStyle(color: Colors.white),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildApprovedMatchesList() {
    return StreamBuilder<List<MatchNotification>>(
      stream: _notificationService.getAdminReviewedMatches('admin_approved'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kMainButtonColor),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: kRedColor, size: 48),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        final approvedMatches = snapshot.data ?? [];

        if (approvedMatches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_alt_outlined,
                  size: 48,
                  color: Colors.grey.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No approved matches found',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Filter by search query if needed
        final filteredMatches =
            _searchQuery.isEmpty
                ? approvedMatches
                : approvedMatches.where((match) {
                  final searchLower = _searchQuery.toLowerCase();
                  return match.user1Name.toLowerCase().contains(searchLower) ||
                      match.user2Name.toLowerCase().contains(searchLower) ||
                      match.organType.toLowerCase().contains(searchLower);
                }).toList();

        if (filteredMatches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 48,
                  color: Colors.grey.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No matches found for this search',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredMatches.length,
          itemBuilder: (context, index) {
            final match = filteredMatches[index];
            final isSelected = _selectedMatch?.id == match.id;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              color: isSelected ? Colors.grey.shade100 : null,
              elevation: isSelected ? 3 : 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side:
                    isSelected
                        ? BorderSide(color: kMainButtonColor, width: 2)
                        : BorderSide.none,
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: kMainButtonColor,
                  child: const Icon(Icons.people_alt, color: Colors.white),
                ),
                title: Text(
                  '${match.user1Name} → ${match.user2Name}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Organ: ${match.organType}'),
                    Text(
                      'Approved: ${_formatDateTime(match.timestamp)}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                isThreeLine: true,
                selected: isSelected,
                onTap: () => _selectMatch(match),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _selectMatch(MatchNotification match) async {
    setState(() {
      _selectedMatch = match;
      _isLoading = true;
      _selectedDonationStatus = null; // Clear previous selection while loading
    });

    try {
      // First check if a donation status already exists
      DonationStatus? status = await _donationStatusService
          .getDonationStatusByMatchId(match.id);

      // If status doesn't exist, we may need to create one
      if (status == null) {
        try {
          // Create a new donation status from the match
          String statusId = await _donationStatusService.createDonationStatus(
            match,
          );
          status = await _donationStatusService.getDonationStatus(statusId);
        } catch (e) {
          print('Error creating donation status: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to create donation status: $e'),
                backgroundColor: kRedColor,
              ),
            );
          }
        }
      }

      // Update UI with the loaded status
      if (mounted) {
        setState(() {
          _selectedDonationStatus = status;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading donation status: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading donation status: $e'),
            backgroundColor: kRedColor,
          ),
        );
      }
    }
  }

  Widget _buildStatusProgressTracker(DonationStatus donationStatus) {
    final List<DonationStatusType> allStatuses = DonationStatusType.values;
    final currentStatusIndex = allStatuses.indexOf(donationStatus.status);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with donation info
          _buildStatusHeader(donationStatus),
          const SizedBox(height: 24),

          // Status timeline checklist
          Expanded(
            child: ListView.builder(
              itemCount: allStatuses.length,
              itemBuilder: (context, index) {
                final statusType = allStatuses[index];
                final statusInfo =
                    donationStatus.copyWith(status: statusType).getStatusInfo();
                final bool isCompleted = index <= currentStatusIndex;
                final bool isCurrent = index == currentStatusIndex;

                // Check if this status is in the history
                final String statusKey = statusType.toString().split('.').last;
                final DateTime? completedDate =
                    donationStatus.statusHistory[statusKey];

                return Card(
                  elevation: isCurrent ? 3 : 1,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 0,
                  ),
                  color: isCurrent ? Colors.grey.shade100 : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side:
                        isCurrent
                            ? BorderSide(color: kMainButtonColor, width: 1)
                            : BorderSide.none,
                  ),
                  child: ListTile(
                    leading:
                        isCompleted
                            ? CircleAvatar(
                              backgroundColor: kMainButtonColor,
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                            )
                            : CircleAvatar(
                              backgroundColor: Colors.grey.shade300,
                              child: Text(
                                (index + 1).toString(),
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ),
                    title: Row(
                      children: [
                        Text(
                          statusInfo['emoji'],
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          statusInfo['title'],
                          style: TextStyle(
                            fontWeight:
                                isCurrent ? FontWeight.bold : FontWeight.normal,
                            color: isCurrent ? kMainButtonColor : null,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(statusInfo['description']),
                        if (completedDate != null)
                          Text(
                            'Completed on: ${_formatDateTime(completedDate)}',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    // Only enable statuses that are one step ahead of current
                    enabled: index == currentStatusIndex + 1,
                    trailing:
                        index > currentStatusIndex
                            ? index == currentStatusIndex + 1
                                ? ElevatedButton.icon(
                                  icon: const Icon(Icons.arrow_forward),
                                  label: const Text('Update'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kMainButtonColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed:
                                      () => _showStatusUpdateDialog(
                                        donationStatus,
                                        statusType,
                                      ),
                                )
                                : null
                            : const Icon(Icons.done_all, color: Colors.green),
                    isThreeLine: completedDate != null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(DonationStatus donationStatus) {
    final statusInfo = donationStatus.getStatusInfo();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kMainButtonColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kMainButtonColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  statusInfo['emoji'],
                  style: const TextStyle(fontSize: 32),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${donationStatus.donorName} → ${donationStatus.recipientName}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Organ: ${donationStatus.organType}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kMainButtonColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Status: ${statusInfo['title']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusInfo['description'],
                  style: TextStyle(color: Colors.grey.shade800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last Updated: ${_formatDateTime(donationStatus.statusTimestamp)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                if (donationStatus.adminNotes != null &&
                    donationStatus.adminNotes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Admin Notes:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          donationStatus.adminNotes!,
                          style: TextStyle(color: Colors.grey.shade800),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: kMainButtonColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Status Timeline',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    String minutes = dateTime.minute.toString().padLeft(2, '0');
    String hours = dateTime.hour.toString().padLeft(2, '0');
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} $hours:$minutes';
  }

  void _showStatusUpdateDialog(
    DonationStatus status,
    DonationStatusType newStatus,
  ) {
    final statusInfo = status.getStatusInfo();
    final newStatusInfo = status.copyWith(status: newStatus).getStatusInfo();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Update Status',
            style: TextStyle(color: kMainButtonColor),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      const TextSpan(text: 'Updating status for '),
                      TextSpan(
                        text: '${status.donorName} → ${status.recipientName}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kMainButtonColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        statusInfo['emoji'],
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: Colors.grey.shade300,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kMainButtonColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        newStatusInfo['emoji'],
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From: ${statusInfo['title']}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'To: ${newStatusInfo['title']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kMainButtonColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(newStatusInfo['description']),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: 'Admin Notes',
                    hintText: 'Add notes about this status update',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: kMainButtonColor),
                    ),
                    labelStyle: TextStyle(color: kMainButtonColor),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kMainButtonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onPressed: () {
                _updateDonationStatus(
                  status.id,
                  newStatus,
                  notesController.text,
                );
                Navigator.pop(context);
              },
              child: const Text('Confirm Update'),
            ),
          ],
        );
      },
    );
  }

  void _updateDonationStatus(
    String donationId,
    DonationStatusType newStatus,
    String notes,
  ) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _donationStatusService.updateDonationStatus(
        donationId,
        newStatus,
        notes,
      );

      // Refresh the selected donation status
      final updatedStatus = await _donationStatusService.getDonationStatus(
        donationId,
      );

      if (mounted) {
        setState(() {
          _selectedDonationStatus = updatedStatus;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Status updated successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(8),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: kRedColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(8),
          ),
        );
      }
    }
  }
}
