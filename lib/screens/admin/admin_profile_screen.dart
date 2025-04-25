import 'package:flutter/material.dart';
import 'package:life_link_admin/constants/colors.dart';
import 'package:life_link_admin/models/admin_model.dart';
import 'package:life_link_admin/services/auth_service.dart';
import 'package:life_link_admin/services/toast_service.dart';

class AdminProfileScreen extends StatelessWidget {
  final AdminModel admin;
  final Function() onLogout;

  const AdminProfileScreen({
    Key? key,
    required this.admin,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: kOrangeColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kOrangeColor, Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Container(
              width: 450,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [kOrangeColor, kPinkColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kOrangeColor.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        admin.name.isNotEmpty
                            ? admin.name.substring(0, 1).toUpperCase()
                            : "A",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Admin Name
                  Text(
                    admin.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Admin Email
                  Text(
                    admin.email,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 16),

                  // Admin Type Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          admin.isSuperAdmin
                              ? kPurpleColor.withOpacity(0.1)
                              : kPeachColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: admin.isSuperAdmin ? kPurpleColor : kPeachColor,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      admin.isSuperAdmin ? 'Super Admin' : 'Standard Admin',
                      style: TextStyle(
                        color: admin.isSuperAdmin ? kPurpleColor : kPeachColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmLogout(context),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('LOGOUT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kOrangeColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Confirm Logout',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: kOrangeColor,
              ),
            ),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'CANCEL',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    Navigator.pop(context);
                    await AuthService.logoutAdmin();
                    onLogout();

                    ToastService.displaySuccessMotionToast(
                      context: context,
                      description: 'Logged out successfully',
                    );
                  } catch (e) {
                    ToastService.displayErrorMotionToast(
                      context: context,
                      description: 'Logout failed',
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kOrangeColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('LOGOUT'),
              ),
            ],
          ),
    );
  }
}
