import 'package:flutter/material.dart';
import 'package:life_link_admin/constants/colors.dart';
import 'package:life_link_admin/models/user_model.dart';
import 'package:life_link_admin/services/toast_service.dart';
import 'package:life_link_admin/services/user_service.dart';
import 'package:life_link_admin/widgets/button_widget.dart';
import 'package:life_link_admin/widgets/card_widget.dart';

class UserDetails extends StatefulWidget {
  BuildContext context;
  UserModel model;
  Function getData;
  UserDetails({super.key, required this.context, required this.model, required this.getData});

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 800,
      child: Drawer(
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                IconButton(
                  onPressed: () => Scaffold.of(context).closeEndDrawer(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),
          body: Padding(padding: const EdgeInsets.all(20), child: buildBody()),
        ),
      ),
    );
  }

  Widget buildBody() {
    return ListView(
      children: [
        Image(image: NetworkImage(widget.model.profileImageUrl), width: 200, height: 200),
        CardWidget(
          child: Column(
            children: [
              Text(
                widget.model.fullName,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(widget.model.gender, style: TextStyle(fontSize: 18)),
              Text(widget.model.bloodType, style: TextStyle(fontSize: 18)),
              Text(widget.model.dateOfBirth, style: TextStyle(fontSize: 18)),
              Text(widget.model.city, style: TextStyle(fontSize: 18)),
              Text(widget.model.organType, style: TextStyle(fontSize: 18)),
              Text(widget.model.contact, style: TextStyle(fontSize: 18)),
              Text(widget.model.address, style: TextStyle(fontSize: 18)),
              ButtonWidget(
                onTap: () => deleteUser(widget.model),
                title: 'Terminate User',
                color: kProfileIcon,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void deleteUser(UserModel model) {
    showDialog<String>(
      context: context,
      builder:
          (BuildContext context) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 30, 30, 20),
                  child: Text('Do you want to delete ${model.fullName}?'),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          Scaffold.of(context).closeEndDrawer();
                          await UserService.deleteUser(model)
                              .then((value) {
                                ToastService.displaySuccessMotionToast(
                                  context: context,
                                  description: '${model.fullName} Deleted!',
                                );
                              })
                              .catchError((error) {
                                ToastService.displayErrorMotionToast(
                                  context: context,
                                  description: 'Something went wrong!',
                                );
                              });
                        },
                        child: const Text('YES'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('NO'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
