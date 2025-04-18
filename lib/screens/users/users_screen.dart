import 'package:flutter/material.dart';
import 'package:life_link_admin/models/user_model.dart';
import 'package:life_link_admin/screens/users/user_details.dart';
import 'package:life_link_admin/services/user_service.dart';
import 'package:life_link_admin/widgets/button_widget.dart';
import 'package:life_link_admin/widgets/card_widget.dart';
import 'package:life_link_admin/widgets/loading_widget.dart';
import 'package:life_link_admin/widgets/no_data_widget.dart';

class UsersScreen extends StatefulWidget {
  bool isDonor;
  UsersScreen({super.key, required this.isDonor});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<UserModel> list = [];
  List<UserModel> filteredList = [];
  bool isLoading = true;

  UserModel selectedUser = UserModel(
    id: 'Loading',
    fullName: 'Loading',
    dateOfBirth: 'Loading',
    gender: 'Loading',
    nic: 'Loading',
    contact: 'Loading',
    address: 'Loading',
    city: 'Loading',
    isDonor: true,
    bloodType: 'Loading',
    organType: 'Loading',
    hlaTyping: {'Loading': 'Loading'},
    isTestsCompleted: true,
    likes: [],
    history: [],
    waitingTime: 0,
    profileImageUrl: 'Loading',
  );

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() => isLoading = true);

    await UserService.getUsersList(isDonor: widget.isDonor).then((value) {
      setState(() {
        list = value;
        filteredList = value;
        selectedUser = list[0];
      });
    });

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: buildBody(),
      endDrawer: UserDetails(context: context, model: selectedUser, getData: () => getData()),
    );
  }

  AppBar appBar() {
    return AppBar(
      actions: <Widget>[Container()],
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'SEARCH USER',
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 0.0),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 0.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  filteredList =
                      list.where((model) {
                        return model.fullName.toLowerCase().contains(value.toLowerCase());
                      }).toList();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBody() {
    return LoadingWidget(
      inAsyncCall: isLoading,
      child:
          isLoading
              ? const SizedBox()
              : filteredList.length > 0
              ? ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  return _userCard(filteredList[index]);
                },
              )
              : NoDataWidget(),
    );
  }

  Widget _userCard(UserModel model) {
    return CardWidget(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(model.fullName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(model.gender),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Builder(
                  builder:
                      (context) => ButtonWidget(
                        onTap: () {
                          setState(() => selectedUser = model);
                          Scaffold.of(context).openEndDrawer();
                        },
                        title: 'More Details',
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
