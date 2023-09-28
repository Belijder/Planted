import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/screens/add_announcement/add_announcement_screen.dart';
import 'package:planted/screens/browse/browse_screen.dart';
import 'package:planted/screens/messages/messages_screen.dart';
import 'package:planted/screens/user_profile/user_profile_screen.dart';

class NavigationBarView extends HookWidget {
  const NavigationBarView({super.key});

  @override
  Widget build(BuildContext context) {
    final currentPageIndex = useState(0);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          currentPageIndex.value = index;
        },
        backgroundColor: colorSepia.withAlpha(50),
        indicatorColor: colorDarkMossGreen,
        selectedIndex: currentPageIndex.value,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: Icon(
              Icons.search,
              color: Colors.white.withAlpha(200),
            ),
            icon: const Icon(
              Icons.search,
              color: colorSepia,
            ),
            label: 'Przeglądaj',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.add,
              color: Colors.white.withAlpha(200),
            ),
            icon: const Icon(
              Icons.add,
              color: colorSepia,
            ),
            label: 'Dodaj',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.message_outlined,
              color: Colors.white.withAlpha(200),
            ),
            icon: const Icon(
              Icons.message_outlined,
              color: colorSepia,
            ),
            label: 'Wiadomości',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.person_outline_rounded,
              color: Colors.white.withAlpha(200),
            ),
            icon: const Icon(
              Icons.person_outline_rounded,
              color: colorSepia,
            ),
            label: 'Profil',
          ),
        ],
      ),
      body: <Widget>[
        const BrowseScreen(),
        const AddAnnouncementScreen(),
        const MessagesScreen(),
        const UserProfileScreen(),
      ][currentPageIndex.value],
    );
  }
}
