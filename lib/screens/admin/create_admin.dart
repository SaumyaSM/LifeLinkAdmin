import 'package:flutter/material.dart';
import 'package:life_link_admin/constants/colors.dart';
import 'package:life_link_admin/models/admin_model.dart';
import 'package:life_link_admin/services/admin_service.dart';
import 'package:life_link_admin/services/auth_service.dart';
import 'package:life_link_admin/services/toast_service.dart';
import 'package:life_link_admin/widgets/button_widget.dart';
import 'package:life_link_admin/widgets/loading_widget.dart';
import 'package:life_link_admin/widgets/text_input_widget.dart';

class CreateAdmin extends StatefulWidget {
  final BuildContext context;
  final Function() getData;

  const CreateAdmin({super.key, required this.context, required this.getData});

  @override
  State<CreateAdmin> createState() => _CreateAdminState();
}

class _CreateAdminState extends State<CreateAdmin> {
  bool isLoading = false;
  TextEditingController emailTEC = TextEditingController();
  TextEditingController nameTEC = TextEditingController();
  TextEditingController passwordTEC = TextEditingController();
  TextEditingController confirmPasswordTEC = TextEditingController();
  bool _isSuperAdmin = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _sendResetEmail = true;

  @override
  Widget build(BuildContext context) {
    return LoadingWidget(
      inAsyncCall: isLoading,
      child: SizedBox(
        width: 400,
        child: Drawer(
          backgroundColor: Colors.white,
          elevation: 2,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kOrangeColor, kPinkColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person_add_alt_1,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Create New Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 3,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0, bottom: 4.0),
                        child: Text(
                          'Administrator Details',
                          style: TextStyle(
                            color: kOrangeColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextInputWidget(
                        controller: nameTEC,
                        title: 'Full Name',
                        icon: const Icon(Icons.person_outline_rounded),
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 20),
                      TextInputWidget(
                        controller: emailTEC,
                        title: 'Email Address',
                        icon: const Icon(Icons.mail_outline_rounded),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      // Password Field
                      TextFormField(
                        controller: passwordTEC,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: kOrangeColor),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Confirm Password Field
                      TextFormField(
                        controller: confirmPasswordTEC,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: kOrangeColor),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Send Reset Email Option
                      CheckboxListTile(
                        title: const Text(
                          'Send password reset email',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        value: _sendResetEmail,
                        activeColor: kOrangeColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (bool? value) {
                          setState(() {
                            _sendResetEmail = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                        child: Text(
                          'Admin Privileges',
                          style: TextStyle(
                            color: kOrangeColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: <Widget>[
                            RadioListTile<bool>(
                              title: const Text(
                                'Standard Admin',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: const Text(
                                'Regular administrative privileges',
                                style: TextStyle(fontSize: 12),
                              ),
                              value: false,
                              groupValue: _isSuperAdmin,
                              activeColor: kPeachColor,
                              onChanged: (bool? value) {
                                setState(() => _isSuperAdmin = value!);
                              },
                            ),
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: Colors.grey.shade200,
                            ),
                            RadioListTile<bool>(
                              title: const Text(
                                'Super Admin',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: const Text(
                                'Complete system access with all privileges',
                                style: TextStyle(fontSize: 12),
                              ),
                              value: true,
                              groupValue: _isSuperAdmin,
                              activeColor: kPurpleColor,
                              onChanged: (bool? value) {
                                setState(() => _isSuperAdmin = value!);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Scaffold.of(widget.context).closeEndDrawer();
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade400),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'CANCEL',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: createAdmin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kOrangeColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'CREATE ADMIN',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  createAdmin() async {
    // Validate inputs
    if (emailTEC.text.trim().isEmpty) {
      ToastService.displayErrorMotionToast(
        context: context,
        description: 'Email is required!',
      );
      return;
    }

    if (nameTEC.text.trim().isEmpty) {
      ToastService.displayErrorMotionToast(
        context: context,
        description: 'Name is required!',
      );
      return;
    }

    if (passwordTEC.text.isEmpty) {
      ToastService.displayErrorMotionToast(
        context: context,
        description: 'Password is required!',
      );
      return;
    }

    if (passwordTEC.text.length < 6) {
      ToastService.displayErrorMotionToast(
        context: context,
        description: 'Password must be at least 6 characters long!',
      );
      return;
    }

    if (passwordTEC.text != confirmPasswordTEC.text) {
      ToastService.displayErrorMotionToast(
        context: context,
        description: 'Passwords do not match!',
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Create user with provided password
      String uid = await AuthService.registerAdminWithPassword(
        email: emailTEC.text.trim(),
        password: passwordTEC.text,
      );

      // Create admin model
      AdminModel model = AdminModel(
        id: uid,
        name: nameTEC.text.trim(),
        isSuperAdmin: _isSuperAdmin,
        email: emailTEC.text.trim(),
      );

      // Create admin in database
      await AdminService.createAdmin(model, sendResetEmail: _sendResetEmail);

      ToastService.displaySuccessMotionToast(
        context: context,
        description: 'Admin successfully created!',
      );

      Scaffold.of(widget.context).closeEndDrawer();
      widget.getData();
    } catch (error) {
      ToastService.displayErrorMotionToast(
        context: context,
        description:
            error.toString().contains('email-already-in-use')
                ? 'Email already in use!'
                : 'Something went wrong!',
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    emailTEC.dispose();
    nameTEC.dispose();
    passwordTEC.dispose();
    confirmPasswordTEC.dispose();
    super.dispose();
  }
}
