import 'package:flutter/material.dart';
import 'package:life_link_admin/models/admin_model.dart';
import 'package:life_link_admin/services/admin_service.dart';
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
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() async {
    await AdminService.getAdminList().then((value) {
      setState(() => list = value);
    });

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [ButtonWidget(onTap: () {}, title: 'Create Admin')],
        ),
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return LoadingWidget(
      inAsyncCall: isLoading,
      child:
          list.length > 0
              ? ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return _adminCard(list[index]);
                },
              )
              : NoDataWidget(),
    );
  }

  Widget _adminCard(AdminModel model) {
    return CardWidget(
      child: Column(
        children: [
          Text(model.name),
          Text(model.email),
          Text(model.isSuperAdmin ? 'Super Admin' : 'Admin'),
        ],
      ),
    );
  }
}
