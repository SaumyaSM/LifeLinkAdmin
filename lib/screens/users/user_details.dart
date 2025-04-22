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
          _buildInfoCard(),
          const SizedBox(height: 24),
          _buildTerminateButton(),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
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
          children: [
            _buildInfoItem(
              'Blood Type',
              widget.model.bloodType,
              Icons.local_hospital,
            ),
            _divider(),
            _buildInfoItem('Gender', widget.model.gender, Icons.person),
            _divider(),
            _buildInfoItem(
              'Date of Birth',
              widget.model.dateOfBirth,
              Icons.cake,
            ),
            _divider(),
            _buildInfoItem('City', widget.model.city, Icons.location_city),
            if (widget.model.organType.isNotEmpty &&
                widget.model.organType != 'Loading') ...[
              _divider(),
              _buildInfoItem(
                'Organ Type',
                widget.model.organType,
                Icons.biotech,
              ),
            ],
            _divider(),
            _buildInfoItem('Contact', widget.model.contact, Icons.phone),
            _divider(),
            _buildInfoItem('Address', widget.model.address, Icons.home),
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
                  value != 'Loading' ? value : 'Not available',
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
                  Text(
                    'Delete User',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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
