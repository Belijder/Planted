import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_bloc.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_state.dart';
import 'package:planted/constants/strings.dart';
import 'package:planted/screens/userProfile/administratorPanel/administrator_panel_view.dart';
import 'package:planted/screens/userProfile/blocked_users_view.dart';
import 'package:planted/screens/userProfile/user_profile_view.dart';
import 'package:planted/screens/userProfile/user_reports_view.dart';
import 'package:planted/screens/userProfile/users_announcements_view.dart';
import 'package:planted/utilities/dialogs/show_database_error_dialog.dart';
import 'package:planted/utilities/loading/loading_screen.dart';

class UserProfileScreenBlocConsumer extends HookWidget {
  const UserProfileScreenBlocConsumer({required this.userID, super.key});

  final String userID;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserProfileScreenBloc, UserProfileScreenState>(
      listener: (context, userProfileScreenState) {
        if (userProfileScreenState.isLoading) {
          LoadingScreen.instance().show(
            context: context,
            text: LoadingScreenText.loading,
          );
        } else {
          LoadingScreen.instance().hide();
        }

        final databaseError = userProfileScreenState.databaseError;
        if (databaseError != null) {
          showDatabaseErrorDialog(
            context: context,
            databaseError: databaseError,
          );
        }

        final message = userProfileScreenState.snackbarMessage;
        if (message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 2),
              content: Text(message),
            ),
          );
        }
      },
      builder: (context, userProfileScreenState) {
        Widget child;

        if (userProfileScreenState is UserProfileScreenStateInitial) {
          return Container();
        } else if (userProfileScreenState
            is UserProfileScreenStateInUserProfileView) {
          child = const UserProfileView();
        } else if (userProfileScreenState
            is UserProfileScreenStateInUsersAnnouncementsView) {
          child = UsersAnnouncementsView(userID: userID);
        } else if (userProfileScreenState
            is UserProfileScreenStateInBlockedUsersView) {
          child = BlockedUsersView(userID: userID);
        } else if (userProfileScreenState
            is UserProfileScreenStateInAdministratorPanel) {
          child = AdministatorPanelView(
            initialIndex: userProfileScreenState.initialTabBarIndex,
          );
        } else if (userProfileScreenState
            is UserProfileScreenStateInUserReportsView) {
          child = const UserReportsView();
        } else {
          child = const Center(child: CircularProgressIndicator());
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.fastOutSlowIn,
          transitionBuilder: (child, animation) {
            final scaleAnimation = Tween<double>(
              begin: 0.85,
              end: 1.0,
            ).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            );
          },
          layoutBuilder: (currentChild, previousChildren) {
            return currentChild ?? Container();
          },
          child: child,
        );
      },
    );
  }
}
