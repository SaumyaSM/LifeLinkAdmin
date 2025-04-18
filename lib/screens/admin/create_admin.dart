import 'package:flutter/material.dart';
import 'package:life_link_admin/models/admin_model.dart';
import 'package:life_link_admin/services/admin_service.dart';
import 'package:life_link_admin/services/auth_service.dart';
import 'package:life_link_admin/services/toast_service.dart';
import 'package:life_link_admin/widgets/button_widget.dart';
import 'package:life_link_admin/widgets/loading_widget.dart';
import 'package:life_link_admin/widgets/text_input_widget.dart';
import 'package:life_link_admin/widgets/title_text.dart';

class CreateAdmin extends StatefulWidget {
  BuildContext context;
  Function() getData;
  CreateAdmin({super.key, required this.context, required this.getData});

  @override
  State<CreateAdmin> createState() => _CreateAdminState();
}

class _CreateAdminState extends State<CreateAdmin> {
  bool isLoading = false;
  TextEditingController emailTEC = TextEditingController();
  TextEditingController nameTEC = TextEditingController();
  bool _isSuperAdmin = false;

  @override
  Widget build(BuildContext context) {
    return LoadingWidget(
      inAsyncCall: isLoading,
      child: SizedBox(
        width: 800,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.all(50),
            children: [
              TitleText(text: 'Create Admin'),
              const SizedBox(height: 50),
              TextInputWidget(
                controller: nameTEC,
                title: 'Name',
                icon: const Icon(Icons.person_outline_outlined),
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 20),
              TextInputWidget(
                controller: emailTEC,
                title: 'Email',
                icon: const Icon(Icons.mail_outline),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              Column(
                children: <Widget>[
                  RadioListTile(
                    title: const Text('Admin'),
                    value: false,
                    groupValue: _isSuperAdmin,
                    onChanged: (bool? value) {
                      setState(() {
                        _isSuperAdmin = value!;
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('Super Admin'),
                    value: true,
                    groupValue: _isSuperAdmin,
                    onChanged: (bool? value) {
                      setState(() {
                        _isSuperAdmin = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ButtonWidget(onTap: () => createAdmin(), title: 'SUBMIT'),
            ],
          ),
        ),
      ),
    );
  }

  createAdmin() async {
    if (emailTEC.text.trim() == '') {
      ToastService.displayErrorMotionToast(context: context, description: 'Email is Missing!');
      return;
    }

    if (nameTEC.text.trim() == '') {
      ToastService.displayErrorMotionToast(context: context, description: 'Name is Missing!');
      return;
    }

    setState(() => isLoading = true);

    await AuthService.registerAdmin(emailTEC.text.trim())
        .then((String uid) async {
          AdminModel model = AdminModel(
            id: uid,
            name: nameTEC.text.trim(),
            isSuperAdmin: _isSuperAdmin,
            email: emailTEC.text.trim(),
          );
          await AdminService.createAdmin(model).then((value) {
            ToastService.displaySuccessMotionToast(context: context, description: 'Admin Created!');
            Scaffold.of(context).closeEndDrawer();
            setState(() => isLoading = false);
            widget.getData();
          });
        })
        .catchError((error) {
          ToastService.displayErrorMotionToast(
            context: context,
            description: 'Something went wrong!',
          );
          setState(() => isLoading = false);
        });
  }
}
