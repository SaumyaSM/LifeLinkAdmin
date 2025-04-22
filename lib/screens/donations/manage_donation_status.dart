import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/donation_status_model.dart';
import '../../services/donation_status_service.dart';
import '../../services/notification_service.dart';
import '../../models/match_notification_model.dart';

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

  // Track the currently selected match notification
  MatchNotification? _selectedMatch;
  // Track the selected donation status
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
      appBar: AppBar(title: const Text('Manage Donation Status')),
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
                const VerticalDivider(width: 1, thickness: 1),
                // Right side: Status progress tracker or empty state
                Expanded(
                  flex: 2,
                  child:
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _selectedDonationStatus != null
                          ? _buildStatusProgressTracker(
                            _selectedDonationStatus!,
                          )
                          : const Center(
                            child: Text(
                              'Select a match to view status details',
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by donor or recipient name',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = "";
                      });
                    },
                  )
                  : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
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
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final approvedMatches = snapshot.data ?? [];

        if (approvedMatches.isEmpty) {
          return const Center(child: Text('No approved matches found'));
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
          return const Center(child: Text('No matches found for this search'));
        }

        return ListView.builder(
          itemCount: filteredMatches.length,
          itemBuilder: (context, index) {
            final match = filteredMatches[index];
            final isSelected = _selectedMatch?.id == match.id;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              color: isSelected ? Colors.blue.shade50 : null,
              elevation: isSelected ? 3 : 1,
              child: ListTile(
                leading: const Icon(Icons.people_alt),
                title: Text('${match.user1Name} → ${match.user2Name}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Organ: ${match.organType}'),
                    Text(
                      'Approved: ${_formatDateTime(match.timestamp)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
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

  // Function to load donation status when a match is selected
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create donation status: $e')),
          );
        }
      }

      // Update UI with the loaded status
      setState(() {
        _selectedDonationStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading donation status: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading donation status: $e')),
      );
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
                  color: isCurrent ? Colors.blue.shade50 : null,
                  child: ListTile(
                    leading:
                        isCompleted
                            ? const CircleAvatar(
                              backgroundColor: Colors.green,
                              child: Icon(Icons.check, color: Colors.white),
                            )
                            : CircleAvatar(
                              backgroundColor: Colors.grey.shade300,
                              child: Text((index + 1).toString()),
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
                            style: const TextStyle(color: Colors.green),
                          ),
                      ],
                    ),
                    // Only enable statuses that are one step ahead of current
                    enabled: index == currentStatusIndex + 1,
                    trailing:
                        index > currentStatusIndex
                            ? index == currentStatusIndex + 1
                                ? IconButton(
                                  icon: const Icon(Icons.arrow_forward),
                                  color: Colors.blue,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(statusInfo['emoji'], style: const TextStyle(fontSize: 32)),
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
                    ),
                  ),
                  Text(
                    'Organ: ${donationStatus.organType}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Status: ${statusInfo['title']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(statusInfo['description']),
              const SizedBox(height: 4),
              Text(
                'Last Updated: ${_formatDateTime(donationStatus.statusTimestamp)}',
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
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
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(donationStatus.adminNotes!),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        const Text(
          'Status Timeline',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
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
          title: const Text('Update Status'),
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
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(statusInfo['emoji']),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, color: Colors.grey),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: Text(newStatusInfo['emoji']),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'From: ${statusInfo['title']}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                Text(
                  'To: ${newStatusInfo['title']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(newStatusInfo['description']),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Admin Notes',
                    hintText: 'Add notes about this status update',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
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

      setState(() {
        _selectedDonationStatus = updatedStatus;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status updated successfully')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating status: $e')));
    }
  }
}
