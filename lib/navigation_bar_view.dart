import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_bloc.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_event.dart';
import 'package:planted/blocs/notificationBloc/notification_bloc.dart';
import 'package:planted/blocs/notificationBloc/notification_event.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/firebase_paths.dart';
import 'package:planted/constants/strings.dart';
import 'package:planted/screens/addAnnouncement/add_announcement_screen.dart';
import 'package:planted/screens/browse/browse_screen.dart';
import 'package:planted/screens/messages/messages_screen.dart';
import 'package:planted/screens/userProfile/user_profile_screen.dart';

class NavigationBarView extends HookWidget {
  const NavigationBarView({super.key});

  @override
  Widget build(BuildContext context) {
    final currentPageIndex = useState(0);

    final notificationCount = context
        .select<NotificationBloc, int>((bloc) => bloc.state.currentBadgeNumber);

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        currentPageIndex.value = 2;
        final conversationID = message.data[conversationIDField];
        context.read<MessagesScreenBloc>().add(
            MessagesScreenEventGoToConversationFromPushMessage(
                conversationID: conversationID));
      }
    });

    FirebaseMessaging.onMessage.listen((message) => context
        .read<NotificationBloc>()
        .add(NewNotificationArrivedEvent(message: message)));

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      currentPageIndex.value = 2;
      final conversationID = message.data[conversationIDField];
      context.read<MessagesScreenBloc>().add(
          MessagesScreenEventGoToConversationFromPushMessage(
              conversationID: conversationID));
    });

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
            label: AppBarTitleText.browse,
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
            label: AppBarTitleText.add,
          ),
          NavigationDestination(
            selectedIcon: Badge(
              backgroundColor: colorRedKenyanCopper,
              label: Text('$notificationCount'),
              isLabelVisible: notificationCount == 0 ? false : true,
              child: Icon(
                Icons.message_outlined,
                color: Colors.white.withAlpha(200),
              ),
            ),
            icon: Badge(
              backgroundColor: colorRedKenyanCopper,
              label: Text('$notificationCount'),
              isLabelVisible: notificationCount == 0 ? false : true,
              child: const Icon(
                Icons.message_outlined,
                color: colorSepia,
              ),
            ),
            label: AppBarTitleText.messages,
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
            label: AppBarTitleText.yoursAccount,
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

class BadgeIcon extends StatelessWidget {
  final Widget icon;
  final int badgeCount;

  const BadgeIcon({super.key, required this.icon, required this.badgeCount});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        icon,
        if (badgeCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                badgeCount.toString(),
                style: const TextStyle(
                  color: listTileBackground,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
