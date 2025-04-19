import 'package:flutter/material.dart';
import 'package:life_link_admin/constants/colors.dart';
import 'package:life_link_admin/models/admin_model.dart';
import 'package:life_link_admin/screens/admin/create_admin.dart';
import 'package:life_link_admin/services/admin_service.dart';
import 'package:life_link_admin/services/auth_service.dart';
import 'package:life_link_admin/services/toast_service.dart';
import 'package:life_link_admin/widgets/button_widget.dart';
import 'package:life_link_admin/widgets/card_widget.dart';
import 'package:life_link_admin/widgets/loading_widget.dart';
import 'package:life_link_admin/widgets/no_data_widget.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<AdminModel> list = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() => isLoading = true);

    await AdminService.getAdminList().then((value) {
      setState(() => list = value);
    });

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEnableOpenDragGesture: false,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: kOrangeColor.withOpacity(0.9),
        title: const Text(
          'Admin Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Builder(
              builder:
                  (context) => ElevatedButton.icon(
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Create Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, kPeachColor.withOpacity(0.15)],
          ),
        ),
        child: buildBody(),
      ),
      endDrawer: CreateAdmin(context: context, getData: () => getData()),
    );
  }

  Widget buildBody() {
    return LoadingWidget(
      inAsyncCall: isLoading,
      child:
          isLoading
              ? const SizedBox()
              : list.isNotEmpty
              ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _adminCard(list[index]),
                    );
                  },
                ),
              )
              : const NoDataWidget(),
    );
  }

  Widget _adminCard(AdminModel model) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CardWidget(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor:
                        model.isSuperAdmin ? kPurpleColor : kPeachColor,
                    radius: 30,
                    child: Text(
                      model.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kOrangeColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          model.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                model.isSuperAdmin
                                    ? kPurpleColor.withOpacity(0.2)
                                    : kPeachColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  model.isSuperAdmin
                                      ? kPurpleColor
                                      : kPeachColor,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            model.isSuperAdmin ? 'Super Admin' : 'Admin',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color:
                                  model.isSuperAdmin
                                      ? kPurpleColor
                                      : kPeachColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => resetPassword(model),
                    icon: const Icon(Icons.lock_reset, size: 18),
                    label: const Text('Reset Password'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPeachColor,
                      side: const BorderSide(color: kPeachColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => deleteAdmin(model),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kProfileIcon,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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

  void resetPassword(AdminModel model) async {
    await AuthService.sendPasswordResetEmail(model.email)
        .then((value) {
          ToastService.displaySuccessMotionToast(
            context: context,
            description: 'Password Reset Email Sent!',
          );
        })
        .catchError((error) {
          ToastService.displayErrorMotionToast(
            context: context,
            description: 'Something went wrong!',
          );
        });
  }

  void deleteAdmin(AdminModel model) {
    showDialog<String>(
      context: context,
      builder:
          (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0.0, 10.0),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: kOrangeColor,
                    size: 50,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Delete Admin',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Do you want to delete ${model.name}?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[800],
                          side: BorderSide(color: Colors.grey[400]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Text('CANCEL'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          setState(() => isLoading = true);
                          await AdminService.deleteAdmin(model)
                              .then((value) {
                                getData();
                                ToastService.displaySuccessMotionToast(
                                  context: context,
                                  description: '${model.name} Deleted!',
                                );
                              })
                              .catchError((error) {
                                ToastService.displayErrorMotionToast(
                                  context: context,
                                  description: 'Something went wrong!',
                                );
                              });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kProfileIcon,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Text('DELETE'),
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
