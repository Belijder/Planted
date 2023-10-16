import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_bloc.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_event.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/strings.dart';
import 'package:planted/screens/userProfile/administratorPanel/announcements_tab_bar_view.dart';
import 'package:planted/screens/userProfile/administratorPanel/reports_tab_bar_view.dart';
import 'package:planted/styles/text_styles.dart';

class AdministatorPanelView extends StatelessWidget {
  const AdministatorPanelView({required this.initialIndex, super.key});
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialIndex,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorEggsheel,
          leading: IconButton(
            onPressed: () {
              context.read<UserProfileScreenBloc>().add(
                    const UserProfileScreenEventGoToUserProfileView(),
                  );
            },
            icon: const Icon(Icons.arrow_back),
            color: colorSepia,
          ),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppBarTitleText.adminPanel,
              style: TextStyles.titleTextStyle(weight: FontWeight.bold),
            ),
          ),
          bottom: const TabBar(tabs: [
            Tab(text: CustomText.announcements),
            Tab(text: CustomText.reports),
          ]),
        ),
        body: const TabBarView(
          children: [
            AnnounementsTabBarView(),
            ReportsTabBarView(),
          ],
        ),
      ),
    );
  }
}
