import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:life_link_admin/screens/admin/admin_screen.dart';
import 'package:life_link_admin/screens/dashboard/dashboard_screen.dart';
import 'package:life_link_admin/screens/donations/donations_screen.dart';
import 'package:life_link_admin/screens/users/users_screen.dart';

class HomeScreen extends StatefulWidget {
  bool isSuperAdmin;
  HomeScreen({super.key, required this.isSuperAdmin});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController pageController = PageController();
  SideMenuController sideMenu = SideMenuController();

  @override
  void initState() {
    sideMenu.addListener((index) {
      pageController.jumpToPage(index);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('LifeLink'), centerTitle: true),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SideMenu(
            controller: sideMenu,
            style: SideMenuStyle(
              displayMode: SideMenuDisplayMode.open,
              showHamburger: false,
              hoverColor: Colors.blue[100],
              selectedHoverColor: Colors.blue[100],
              selectedColor: Colors.lightBlue,
              selectedTitleTextStyle: const TextStyle(color: Colors.white),
              selectedIconColor: Colors.white,
            ),
            title: Column(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 150, maxWidth: 150),
                  child: Image.asset('assets/images/LifeLink-Logo.PNG'),
                ),
                const Divider(indent: 8.0, endIndent: 8.0),
              ],
            ),
            items: [
              SideMenuItem(
                title: 'Dashboard',
                onTap: (index, _) {
                  sideMenu.changePage(index);
                },
                icon: const Icon(Icons.home),
              ),
              widget.isSuperAdmin
                  ? SideMenuItem(
                    title: 'Admin',
                    onTap: (index, _) {
                      sideMenu.changePage(index);
                    },
                    icon: const Icon(Icons.supervisor_account),
                  )
                  : const SizedBox(),
              SideMenuExpansionItem(
                title: "Users",
                icon: const Icon(Icons.supervisor_account),
                onTap: (index, _, isExpanded) => {print('$index, expanded $isExpanded')},
                children: [
                  SideMenuItem(
                    title: 'Donators',
                    onTap: (index, _) {
                      sideMenu.changePage(index);
                    },
                    icon: const Icon(Icons.supervisor_account),
                  ),
                  SideMenuItem(
                    title: 'Recipients',
                    onTap: (index, _) {
                      sideMenu.changePage(index);
                    },
                    icon: const Icon(Icons.supervisor_account),
                  ),
                ],
              ),
              SideMenuItem(
                title: 'Donations',
                onTap: (index, _) {
                  sideMenu.changePage(index);
                },
                icon: const Icon(Icons.handshake_outlined),
              ),

              // SideMenuItem(
              //   builder: (context, displayMode) {
              //     return const Divider(endIndent: 8, indent: 8);
              //   },
              // ),
            ],
          ),
          const VerticalDivider(width: 0),
          Expanded(
            child: PageView(
              controller: pageController,
              children: [
                DashboardScreen(),
                widget.isSuperAdmin ? AdminScreen() : const SizedBox.shrink(),
                UsersScreen(isDonor: true),
                UsersScreen(isDonor: false),
                DonationsScreen(),

                // this is for SideMenuItem with builder (divider)
                // const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
