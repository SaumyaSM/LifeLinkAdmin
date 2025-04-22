import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:life_link_admin/constants/colors.dart';
import 'package:life_link_admin/screens/admin/admin_screen.dart';
import 'package:life_link_admin/screens/dashboard/dashboard_screen.dart';
import 'package:life_link_admin/screens/donations/donations_screen.dart';
import 'package:life_link_admin/screens/events/events_screen.dart';
import 'package:life_link_admin/screens/users/users_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isSuperAdmin;
  const HomeScreen({super.key, required this.isSuperAdmin});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController pageController = PageController();
  SideMenuController sideMenu = SideMenuController();
  String _currentTitle = 'Dashboard';

  @override
  void initState() {
    sideMenu.addListener((index) {
      pageController.jumpToPage(index);
      _updateTitle(index);
    });
    super.initState();
  }

  void _updateTitle(int index) {
    setState(() {
      if (index == 0) {
        _currentTitle = 'Dashboard';
      } else if (index == 1 && widget.isSuperAdmin) {
        _currentTitle = 'Admin Management';
      } else if ((index == 1 && !widget.isSuperAdmin) ||
          (index == 2 && widget.isSuperAdmin)) {
        _currentTitle = 'Donators';
      } else if ((index == 2 && !widget.isSuperAdmin) ||
          (index == 3 && widget.isSuperAdmin)) {
        _currentTitle = 'Recipients';
      } else if ((index == 3 && !widget.isSuperAdmin) ||
          (index == 4 && widget.isSuperAdmin)) {
        _currentTitle = 'Donations';
      } else if ((index == 4 && !widget.isSuperAdmin) ||
          (index == 5 && widget.isSuperAdmin)) {
        _currentTitle = 'Events';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFFAF0F0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Custom App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: const BoxDecoration(
                gradient: kGradientNavBar,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Image.asset('assets/images/LifeLink-Logo.PNG', height: 40),
                  const SizedBox(width: 12),
                  Text(
                    'LifeLink',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _currentTitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    backgroundColor: kProfileIcon,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Main Content
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Side Menu
                  Container(
                    width: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: Offset(2, 0),
                        ),
                      ],
                    ),
                    child: SideMenu(
                      controller: sideMenu,
                      style: SideMenuStyle(
                        displayMode: SideMenuDisplayMode.open,
                        showHamburger: false,
                        backgroundColor: Colors.white,
                        hoverColor: kPeachColor.withOpacity(0.1),
                        selectedHoverColor: kPeachColor.withOpacity(0.2),
                        selectedColor: kMainButtonColor,
                        selectedTitleTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedTitleTextStyle: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                        selectedIconColor: Colors.white,
                        unselectedIconColor: kPurpleColor,
                        itemOuterPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        itemInnerSpacing: 16,
                      ),
                      title: Column(
                        children: [
                          const SizedBox(height: 20),
                          Container(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxHeight: 100,
                                maxWidth: 100,
                              ),
                              child: Image.asset(
                                'assets/images/LifeLink-Logo.PNG',
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Admin Portal',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: kDarkPinkColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Divider(
                            color: Colors.grey[300],
                            thickness: 1,
                            indent: 20,
                            endIndent: 20,
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                      items: [
                        SideMenuItem(
                          title: 'Dashboard',
                          onTap: (index, _) {
                            sideMenu.changePage(index);
                          },
                          icon: const Icon(Icons.dashboard_rounded),
                        ),
                        if (widget.isSuperAdmin)
                          SideMenuItem(
                            title: 'Admin',
                            onTap: (index, _) {
                              sideMenu.changePage(index);
                            },
                            icon: const Icon(
                              Icons.admin_panel_settings_rounded,
                            ),
                          ),
                        SideMenuExpansionItem(
                          title: "Users",
                          icon: const Icon(Icons.people_alt_rounded),
                          onTap:
                              (index, _, isExpanded) => {
                                print('$index, expanded $isExpanded'),
                              },
                          children: [
                            SideMenuItem(
                              title: 'Donators',
                              onTap: (index, _) {
                                sideMenu.changePage(index);
                              },
                              icon: const Icon(Icons.volunteer_activism),
                            ),
                            SideMenuItem(
                              title: 'Recipients',
                              onTap: (index, _) {
                                sideMenu.changePage(index);
                              },
                              icon: const Icon(Icons.person_rounded),
                            ),
                          ],
                        ),
                        SideMenuItem(
                          title: 'Donations',
                          onTap: (index, _) {
                            sideMenu.changePage(index);
                          },
                          icon: const Icon(Icons.handshake_rounded),
                        ),
                        SideMenuItem(
                          title: 'Events',
                          onTap: (index, _) {
                            sideMenu.changePage(index);
                          },
                          icon: const Icon(Icons.event_rounded),
                        ),
                      ],
                    ),
                  ),
                  // Page Content
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: PageView(
                          controller: pageController,
                          children: [
                            DashboardScreen(),
                            if (widget.isSuperAdmin) AdminScreen(),
                            UsersScreen(isDonor: true),
                            UsersScreen(isDonor: false),
                            DonationScreen(),
                            EventsScreen(),
                          ],
                        ),
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
}
