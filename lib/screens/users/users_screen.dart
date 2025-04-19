import 'package:flutter/material.dart';
import 'package:life_link_admin/models/user_model.dart';
import 'package:life_link_admin/screens/users/user_details.dart';
import 'package:life_link_admin/services/user_service.dart';
import 'package:life_link_admin/widgets/loading_widget.dart';
import 'package:life_link_admin/widgets/no_data_widget.dart';
import '../../constants/colors.dart';

class UsersScreen extends StatefulWidget {
  final bool isDonor;
  const UsersScreen({super.key, required this.isDonor});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<UserModel> list = [];
  List<UserModel> filteredList = [];
  bool isLoading = true;
  late UserModel selectedUser;

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
        if (value.isNotEmpty) {
          selectedUser = list[0];
        }
      });
    });

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      endDrawer:
          filteredList.isNotEmpty
              ? UserDetails(
                context: context,
                model: selectedUser,
                getData: () => getData(),
              )
              : null,
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: kPurpleColor,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(
        widget.isDonor ? 'Donors' : 'Recipients',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        Container(
          width: 300,
          margin: const EdgeInsets.only(right: 16),
          child: SizedBox(
            height: 40,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search User',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.white, width: 1.0),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  filteredList =
                      list
                          .where(
                            (model) => model.fullName.toLowerCase().contains(
                              value.toLowerCase(),
                            ),
                          )
                          .toList();
                });
              },
            ),
          ),
        ),
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: kGradientHome),
      ),
    );
  }

  Widget _buildBody() {
    return LoadingWidget(
      inAsyncCall: isLoading,
      child:
          isLoading
              ? const SizedBox()
              : filteredList.isNotEmpty
              ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [kPurpleColor.withOpacity(0.1), Colors.white],
                  ),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    return _userCard(filteredList[index]);
                  },
                ),
              )
              : const NoDataWidget(),
    );
  }

  Widget _userCard(UserModel model) {
    final bloodOrOrganInfo =
        widget.isDonor
            ? "Blood Type: ${model.bloodType}"
            : "Organ: ${model.organType}";

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.white, kPeachColor.withOpacity(0.2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: kOrangeColor,
                    backgroundImage:
                        model.profileImageUrl != 'Loading'
                            ? NetworkImage(model.profileImageUrl)
                            : null,
                    child:
                        model.profileImageUrl == 'Loading'
                            ? Text(
                              model.fullName.isNotEmpty
                                  ? model.fullName[0].toUpperCase()
                                  : '',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                            : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kPurpleColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bloodOrOrganInfo,
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.isDonor ? kRedColor : kDarkPinkColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "City: ${model.city}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(model.gender),
                    backgroundColor: kPeachColor.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  Builder(
                    builder:
                        (context) => ElevatedButton.icon(
                          onPressed: () {
                            setState(() => selectedUser = model);
                            Scaffold.of(context).openEndDrawer();
                          },
                          icon: const Icon(Icons.visibility),
                          label: const Text('Details'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kMainButtonColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
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
