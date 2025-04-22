import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/match_notification_model.dart';
import '../../models/user_model.dart';
import '../../services/notification_service.dart';
import '../../services/user_service.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({Key? key}) : super(key: key);

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final NotificationService _notificationService = NotificationService();
  final UserService _userService = UserService();
  final TextEditingController _feedbackController = TextEditingController();

  String? _selectedNotificationId;
  MatchNotification? _selectedNotification;
  UserModel? _donorUser;
  UserModel? _recipientUser;
  bool _isLoading = false;

  // Track which tab is currently selected
  String _currentTabStatus = 'pending';

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _resetSelection() {
    setState(() {
      _selectedNotificationId = null;
      _selectedNotification = null;
      _donorUser = null;
      _recipientUser = null;
      _feedbackController.clear();
    });
  }

  Future<void> _loadUserDetails(String donorId, String recipientId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final donor = await _userService.getUserById(donorId);
      final recipient = await _userService.getUserById(recipientId);

      setState(() {
        _donorUser = donor;
        _recipientUser = recipient;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading user details: $e')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _approveMatch() async {
    if (_selectedNotificationId == null ||
        _feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide feedback before approving'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _notificationService.adminApproveMatch(
        _selectedNotificationId!,
        _feedbackController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match approved successfully')),
      );
      _resetSelection();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error approving match: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _rejectMatch() async {
    if (_selectedNotificationId == null ||
        _feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide feedback before rejecting'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _notificationService.adminRejectMatch(
        _selectedNotificationId!,
        _feedbackController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match rejected successfully')),
      );
      _resetSelection();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error rejecting match: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Match Reviews'),
        backgroundColor: Colors.teal,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - List of matches with tabs
          Expanded(
            flex: 2,
            child: Card(
              margin: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tab selection buttons
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(child: _buildTabButton('Pending', 'pending')),
                        Expanded(
                          child: _buildTabButton('Approved', 'admin_approved'),
                        ),
                        Expanded(
                          child: _buildTabButton('Rejected', 'admin_rejected'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<List<MatchNotification>>(
                      stream: _getMatchesStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          print(
                            'FIREBASE ERROR IN STREAMBUILDER: ${snapshot.error}',
                          );
                          print('ERROR DETAILS: ${snapshot.error.toString()}');
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        final notifications = snapshot.data ?? [];

                        if (notifications.isEmpty) {
                          return Center(
                            child: Text(
                              'No ${_getStatusDisplayName()} matches found',
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notification = notifications[index];

                            return ListTile(
                              title: Text(
                                '${notification.user1Name} & ${notification.user2Name}',
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Organ: ${notification.organType} • Match Score: ${notification.matchScore}%',
                                  ),
                                  if (_currentTabStatus != 'pending' &&
                                      notification.adminFeedback != null)
                                    Text(
                                      'Feedback: ${notification.adminFeedback}',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _formatDate(notification.timestamp),
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  if (_currentTabStatus == 'admin_approved')
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                  if (_currentTabStatus == 'admin_rejected')
                                    Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                      size: 16,
                                    ),
                                ],
                              ),
                              selected:
                                  _selectedNotificationId == notification.id,
                              onTap: () {
                                setState(() {
                                  _selectedNotificationId = notification.id;
                                  _selectedNotification = notification;

                                  // Pre-populate feedback if available
                                  if (notification.adminFeedback != null) {
                                    _feedbackController.text =
                                        notification.adminFeedback!;
                                  } else {
                                    _feedbackController.clear();
                                  }
                                });

                                _loadUserDetails(
                                  notification.user1Id,
                                  notification.user2Id,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right side - Selected match details
          Expanded(
            flex: 3,
            child:
                _selectedNotificationId == null
                    ? const Center(child: Text('Select a match to review'))
                    : _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildMatchDetails(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, String status) {
    bool isSelected = _currentTabStatus == status;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.teal : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: isSelected ? 4 : 0,
      ),
      onPressed: () {
        setState(() {
          _currentTabStatus = status;
          _resetSelection();
        });
      },
      child: Text(title),
    );
  }

  // Helper to get the appropriate match stream based on the selected tab
  Stream<List<MatchNotification>> _getMatchesStream() {
    switch (_currentTabStatus) {
      case 'pending':
        return _notificationService.getAdminPendingReviews();
      case 'admin_approved':
        return _notificationService.getAdminReviewedMatches('admin_approved');
      case 'admin_rejected':
        return _notificationService.getAdminReviewedMatches('admin_rejected');
      default:
        return _notificationService.getAdminPendingReviews();
    }
  }

  // Helper to display status in UI
  String _getStatusDisplayName() {
    switch (_currentTabStatus) {
      case 'pending':
        return 'pending';
      case 'admin_approved':
        return 'approved';
      case 'admin_rejected':
        return 'rejected';
      default:
        return '';
    }
  }

  Widget _buildMatchDetails() {
    if (_donorUser == null ||
        _recipientUser == null ||
        _selectedNotification == null) {
      return const Center(child: Text('Unable to load match details'));
    }

    bool isReviewed = _currentTabStatus != 'pending';

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Match Review: ${_donorUser!.fullName} & ${_recipientUser!.fullName}',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isReviewed)
                  _currentTabStatus == 'admin_approved'
                      ? _buildStatusChip('Approved', Colors.green)
                      : _buildStatusChip('Rejected', Colors.red),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Organ Type: ${_selectedNotification!.organType} • Match Score: ${_selectedNotification!.matchScore}%',
              style: TextStyle(color: Colors.grey[700], fontSize: 16.0),
            ),
            const Divider(height: 32),

            // Donor and Recipient details in two columns
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Donor details
                  Expanded(child: _buildUserDetailsCard(_donorUser!, 'Donor')),

                  const SizedBox(width: 16),

                  // Recipient details
                  Expanded(
                    child: _buildUserDetailsCard(_recipientUser!, 'Recipient'),
                  ),
                ],
              ),
            ),

            const Divider(height: 32),

            // Admin feedback input
            TextField(
              controller: _feedbackController,
              decoration: const InputDecoration(
                labelText: 'Feedback (required)',
                border: OutlineInputBorder(),
                hintText: 'Provide reason for approval or rejection...',
              ),
              maxLines: 3,
              readOnly: isReviewed, // Make read-only if already reviewed
            ),

            const SizedBox(height: 16),

            // Action buttons - only show for pending matches
            if (!isReviewed)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _resetSelection,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _rejectMatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Reject Match'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _approveMatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Approve Match'),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _resetSelection,
                    child: const Text('Back'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }

  Widget _buildUserDetailsCard(UserModel user, String role) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      user.imageUrl.isNotEmpty
                          ? NetworkImage(user.imageUrl) as ImageProvider
                          : const AssetImage(
                            'assets/images/avatar_placeholder.png',
                          ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        role,
                        style: TextStyle(
                          color: role == 'Donor' ? Colors.blue : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildInfoRow('Age', _calculateAge(user.dateOfBirth)),
            _buildInfoRow('Gender', user.gender),
            _buildInfoRow('Blood Type', user.bloodType),
            _buildInfoRow('City', user.city),
            const SizedBox(height: 16),
            const Text(
              'HLA Typing',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  user.hlaTyping.entries.map((entry) {
                    return Chip(
                      label: Text('${entry.key}: ${entry.value}'),
                      backgroundColor: Colors.grey[200],
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),
            if (user.isDonor == false) // Only for recipients
              _buildInfoRow('Waiting Time', '${user.waitingTime} days'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateAge(String dateOfBirth) {
    try {
      DateTime dob;
      // Check if the date is in DD/MM/YYYY format
      if (dateOfBirth.contains('/')) {
        List<String> parts = dateOfBirth.split('/');
        if (parts.length == 3) {
          int day = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int year = int.parse(parts[2]);
          dob = DateTime(year, month, day);
        } else {
          return 'Unknown';
        }
      } else {
        // Try standard ISO format
        dob = DateTime.parse(dateOfBirth);
      }

      final today = DateTime.now();
      int age = today.year - dob.year;
      if (today.month < dob.month ||
          (today.month == dob.month && today.day < dob.day)) {
        age--;
      }
      return '$age years';
    } catch (e) {
      print('Error calculating age: $e');
      return 'Unknown';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
