import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/match_notification_model.dart';
import '../../models/user_model.dart';
import '../../services/notification_service.dart';
import '../../services/user_service.dart';
import '../../constants/colors.dart';

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
  String _currentTabStatus = 'pending';
  String _currentDocsView = '';

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
      _currentDocsView = '';
    });
  }

  Future<void> _loadUserDetails(String donorId, String recipientId) async {
    setState(() => _isLoading = true);

    try {
      final donor = await _userService.getUserById(donorId);
      final recipient = await _userService.getUserById(recipientId);

      setState(() {
        _donorUser = donor;
        _recipientUser = recipient;
        _isLoading = false;
      });
    } catch (e) {
      _showSnackBar('Error loading user details: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openDocument(String url) async {
    if (url.isEmpty) return;

    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Could not launch document URL');
      }
    } catch (e) {
      _showSnackBar('Error opening document: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _approveMatch() async {
    if (_selectedNotificationId == null ||
        _feedbackController.text.trim().isEmpty) {
      _showSnackBar('Please provide feedback before approving');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _notificationService.adminApproveMatch(
        _selectedNotificationId!,
        _feedbackController.text.trim(),
      );
      _showSnackBar('Match approved successfully');
      _resetSelection();
    } catch (e) {
      _showSnackBar('Error approving match: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _rejectMatch() async {
    if (_selectedNotificationId == null ||
        _feedbackController.text.trim().isEmpty) {
      _showSnackBar('Please provide feedback before rejecting');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _notificationService.adminRejectMatch(
        _selectedNotificationId!,
        _feedbackController.text.trim(),
      );
      _showSnackBar('Match rejected successfully');
      _resetSelection();
    } catch (e) {
      _showSnackBar('Error rejecting match: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Match Reviews'),
        backgroundColor: kPinkColor,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Match list with tabs
          Expanded(flex: 2, child: _buildMatchesList()),
          // Right side - Selected match details
          Expanded(flex: 3, child: _buildDetailsPanel()),
        ],
      ),
    );
  }

  Widget _buildMatchesList() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab selection buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(child: _buildTabButton('Pending', 'pending')),
                Expanded(child: _buildTabButton('Approved', 'admin_approved')),
                Expanded(child: _buildTabButton('Rejected', 'admin_rejected')),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<MatchNotification>>(
              stream: _getMatchesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final notifications = snapshot.data ?? [];

                if (notifications.isEmpty) {
                  return Center(
                    child: Text(
                      'No ${_getStatusDisplayName()} matches found',
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  );
                }

                return _buildNotificationsList(notifications);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<MatchNotification> notifications) {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        final bool isSelected = _selectedNotificationId == notification.id;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          elevation: isSelected ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side:
                isSelected
                    ? BorderSide(color: kOrangeColor, width: 2)
                    : BorderSide.none,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Text(
              '${notification.user1Name} & ${notification.user2Name}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.medical_services, size: 16, color: kRedColor),
                    const SizedBox(width: 4),
                    Text(
                      notification.organType,
                      style: TextStyle(color: kRedColor),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.percent, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 4),
                    Text(
                      '${notification.matchScore}%',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                  ],
                ),
                if (_currentTabStatus != 'pending' &&
                    notification.adminFeedback != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Feedback: ${notification.adminFeedback}',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
                const SizedBox(height: 4),
                if (_currentTabStatus == 'admin_approved')
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                if (_currentTabStatus == 'admin_rejected')
                  Icon(Icons.cancel, color: Colors.red, size: 16),
              ],
            ),
            selected: isSelected,
            onTap: () {
              setState(() {
                _selectedNotificationId = notification.id;
                _selectedNotification = notification;
                _currentDocsView = '';

                // Pre-populate feedback if available
                if (notification.adminFeedback != null) {
                  _feedbackController.text = notification.adminFeedback!;
                } else {
                  _feedbackController.clear();
                }
              });

              _loadUserDetails(notification.user1Id, notification.user2Id);
            },
          ),
        );
      },
    );
  }

  Widget _buildDetailsPanel() {
    if (_selectedNotificationId == null) {
      return _buildEmptyDetailsCard();
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return _currentDocsView.isNotEmpty
        ? _buildDocumentsView()
        : _buildMatchDetails();
  }

  Widget _buildEmptyDetailsCard() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Select a match to review',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, String status) {
    bool isSelected = _currentTabStatus == status;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? kOrangeColor : Colors.grey[200],
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: isSelected ? 4 : 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () {
          setState(() {
            _currentTabStatus = status;
            _resetSelection();
          });
        },
        child: Text(title),
      ),
    );
  }

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

  Widget _buildDocumentsView() {
    UserModel user =
        _currentDocsView == 'donor' ? _donorUser! : _recipientUser!;
    Color roleColor = _currentDocsView == 'donor' ? Colors.blue : kOrangeColor;

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() => _currentDocsView = ''),
                  tooltip: 'Back to match details',
                ),
                Expanded(
                  child: Text(
                    'Medical Documents - ${user.fullName}',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    _currentDocsView == 'donor' ? 'Donor' : 'Recipient',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: roleColor,
                ),
              ],
            ),
            const Divider(height: 24),

            if (user.medicalDocuments.isEmpty)
              _buildEmptyDocumentsMessage()
            else
              Expanded(child: _buildDocumentsList(user)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDocumentsMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No medical documents found for this user',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsList(UserModel user) {
    return ListView(
      children:
          user.medicalDocuments.entries.map((entry) {
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kPinkColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.description, color: kPinkColor),
                ),
                title: Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Click to view document'),
                trailing: Icon(Icons.open_in_new, color: kOrangeColor),
                onTap: () => _openDocument(entry.value),
              ),
            );
          }).toList(),
    );
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
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            Row(
              children: [
                Icon(Icons.medical_services, color: kRedColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  _selectedNotification!.organType,
                  style: TextStyle(
                    color: kRedColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.bar_chart, color: Colors.blue[700], size: 18),
                const SizedBox(width: 8),
                Text(
                  'Match Score: ${_selectedNotification!.matchScore}%',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
              decoration: InputDecoration(
                labelText: 'Feedback (required)',
                labelStyle: TextStyle(color: kPinkColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: kPinkColor, width: 2),
                ),
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
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _rejectMatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Reject Match'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _approveMatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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
    final bool isDonor = role == 'Donor';
    final Color roleColor = isDonor ? Colors.blue : kOrangeColor;
    final Color roleBackgroundColor =
        isDonor ? Colors.blue[100]! : kOrangeColor.withOpacity(0.2);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // User profile image
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: roleColor, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        user.imageUrl.isNotEmpty
                            ? NetworkImage(user.imageUrl) as ImageProvider
                            : const AssetImage(
                              'assets/images/avatar_placeholder.png',
                            ),
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
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: roleBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          role,
                          style: TextStyle(
                            color: roleColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Documents view button
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentDocsView = role.toLowerCase();
                    });
                  },
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Documents'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: roleBackgroundColor,
                    foregroundColor: roleColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),

            // User information
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

            // HLA typing chips
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

            // Medical documents count indicator
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color:
                    user.medicalDocuments.isEmpty
                        ? Colors.grey[200]
                        : kPinkColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.folder,
                    color:
                        user.medicalDocuments.isEmpty
                            ? Colors.grey
                            : kPinkColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Medical Documents: ${user.medicalDocuments.length}',
                    style: TextStyle(
                      color:
                          user.medicalDocuments.isEmpty
                              ? Colors.grey
                              : kPinkColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
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
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
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
      return 'Unknown';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
