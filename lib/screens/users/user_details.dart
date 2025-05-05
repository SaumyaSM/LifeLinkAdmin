import 'package:flutter/material.dart';
import 'package:life_link_admin/constants/colors.dart';
import 'package:life_link_admin/models/user_model.dart';
import 'package:life_link_admin/services/toast_service.dart';
import 'package:life_link_admin/services/user_service.dart';

class UserDetails extends StatefulWidget {
  final BuildContext context;
  final UserModel model;
  final Function getData;

  const UserDetails({
    super.key,
    required this.context,
    required this.model,
    required this.getData,
  });

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Drawer(
        backgroundColor: Colors.white,
        elevation: 0,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'User Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            leading: IconButton(
              onPressed: () => Scaffold.of(context).closeEndDrawer(),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
            backgroundColor: kPurpleColor,
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(gradient: kGradientHome),
            ),
          ),
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kPurpleColor.withOpacity(0.05), Colors.white],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildPersonalInfoCard(),
          const SizedBox(height: 20),
          _buildMedicalInfoCard(),
          const SizedBox(height: 20),
          _buildHLATypingCard(),
          const SizedBox(height: 20),
          _buildMedicalDocumentsCard(),
          const SizedBox(height: 20),
          _buildMedicalHistoryCard(),
          const SizedBox(height: 24),
          _buildTerminateButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [kPeachColor, kOrangeColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: kOrangeColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(75),
              child:
                  widget.model.imageUrl != 'Loading'
                      ? Image.network(
                        widget.model.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Center(
                              child: Text(
                                widget.model.fullName.isNotEmpty
                                    ? widget.model.fullName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                      )
                      : Center(
                        child: Text(
                          widget.model.fullName.isNotEmpty
                              ? widget.model.fullName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.model.fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kPurpleColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: widget.model.isDonor ? kRedColor : kDarkPinkColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.model.isDonor ? 'Donor' : 'Recipient',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      widget.model.isTestsCompleted
                          ? Colors.green
                          : Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.model.isTestsCompleted
                      ? 'Tests Completed'
                      : 'Tests Pending',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return _buildCard('Personal Information', Icons.person_outline, [
      _buildInfoItem('Full Name', widget.model.fullName, Icons.person),
      _divider(),
      _buildInfoItem('Gender', widget.model.gender, Icons.wc),
      _divider(),
      _buildInfoItem('Date of Birth', widget.model.dateOfBirth, Icons.cake),
      _divider(),
      _buildInfoItem('NIC', widget.model.nic, Icons.badge),
      _divider(),
      _buildInfoItem('Contact', widget.model.contact, Icons.phone),
      _divider(),
      _buildInfoItem('Address', widget.model.address, Icons.home),
      _divider(),
      _buildInfoItem('City', widget.model.city, Icons.location_city),
    ]);
  }

  Widget _buildMedicalInfoCard() {
    return _buildCard('Medical Information', Icons.medical_services_outlined, [
      _buildInfoItem('Blood Type', widget.model.bloodType, Icons.bloodtype),
      _divider(),
      _buildInfoItem('Organ Type', widget.model.organType, Icons.biotech),
      if (!widget.model.isDonor) ...[
        _divider(),
        _buildInfoItem(
          'Waiting Time',
          '${widget.model.waitingTime} days',
          Icons.timelapse,
        ),
      ],
    ]);
  }

  Widget _buildHLATypingCard() {
    return _buildCard('HLA Typing Information', Icons.science_outlined, [
      for (var entry in widget.model.hlaTyping.entries) ...[
        _buildInfoItem(entry.key, entry.value, Icons.science),
        if (entry.key != widget.model.hlaTyping.keys.last) _divider(),
      ],
      if (widget.model.hlaTyping.isEmpty)
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            'No HLA Typing information available',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
    ]);
  }

  Widget _buildMedicalDocumentsCard() {
    return _buildCard('Medical Documents', Icons.description_outlined, [
      for (var entry in widget.model.medicalDocuments.entries) ...[
        _buildDocumentItem(entry.key, entry.value),
        if (entry.key != widget.model.medicalDocuments.keys.last) _divider(),
      ],
      if (widget.model.medicalDocuments.isEmpty)
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            'No medical documents available',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
    ]);
  }

  Widget _buildMedicalHistoryCard() {
    return _buildCard('Medical History', Icons.history_edu, [
      if (widget.model.history.isNotEmpty)
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.model.history.length,
          separatorBuilder: (context, index) => _divider(),
          itemBuilder: (context, index) {
            return _buildHistoryItem(widget.model.history[index], index);
          },
        )
      else
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            'No medical history available',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
    ]);
  }

  Widget _buildCard(String title, IconData titleIcon, List<Widget> children) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, kPeachColor.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(titleIcon, color: kPurpleColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kPurpleColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kPurpleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: kPurpleColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty || value == 'Loading' ? 'Not available' : value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(String documentName, String documentUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kPurpleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.file_present,
              color: kPurpleColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  documentName,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () {
                    // Handle document viewing
                    // You can add code to open the document URL
                  },
                  child: Text(
                    'View Document',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: kPurpleColor,
                      decoration: TextDecoration.underline,
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

  Widget _buildHistoryItem(String historyEntry, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kPurpleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: kPurpleColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              historyEntry,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(color: Colors.grey.withOpacity(0.3), height: 1),
    );
  }

  Widget _buildTerminateButton() {
    return ElevatedButton.icon(
      onPressed: () => _deleteUser(widget.model),
      icon: const Icon(Icons.person_remove),
      label: const Text('Terminate User'),
      style: ElevatedButton.styleFrom(
        backgroundColor: kProfileIcon,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }

  void _deleteUser(UserModel model) {
    showDialog<String>(
      context: context,
      builder:
          (BuildContext dialogContext) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: kRedColor,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Delete User',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Are you sure you want to delete ${model.fullName}? This action cannot be undone.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          Scaffold.of(context).closeEndDrawer();
                          await UserService.deleteUser(model)
                              .then((_) {
                                widget.getData();
                                ToastService.displaySuccessMotionToast(
                                  context: context,
                                  description:
                                      '${model.fullName} has been deleted',
                                );
                              })
                              .catchError((error) {
                                ToastService.displayErrorMotionToast(
                                  context: context,
                                  description: 'Failed to delete user',
                                );
                              });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kProfileIcon,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
