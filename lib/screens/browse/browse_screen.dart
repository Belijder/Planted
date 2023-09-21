import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/browseBloc/browse_screen_bloc.dart';
import 'package:planted/blocs/browseBloc/browse_screen_state.dart';
import 'package:planted/screens/browse/announcement_details_view.dart';
import 'package:planted/screens/browse/announcements_list_view.dart';
import 'package:planted/screens/messages/conversation_view.dart';
import 'package:planted/utilities/dialogs/show_database_error_dialog.dart';
import 'package:planted/utilities/loading/loading_screen.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BrowseScreenBloc, BrowseScreenState>(
      listener: (context, browseScreenState) {
        if (browseScreenState.isLoading) {
          LoadingScreen.instance().show(context: context, text: 'Ładuję...');
        } else {
          LoadingScreen.instance().hide();
        }

        final databaseError = browseScreenState.databaseError;
        if (databaseError != null) {
          showDatabaseErrorDialog(
            context: context,
            databaseError: databaseError,
          );
        }
      },
      builder: (context, browseScreenState) {
        Widget child;

        if (browseScreenState is InAnnouncementsListViewBrowseScreenState) {
          child = const AnnouncementListView();
        } else if (browseScreenState
            is InAnnouncementDetailsBrowseScreenState) {
          child = AnnouncementDetailsView(
              announcement: browseScreenState.announcement);
        } else if (browseScreenState is InConversationViewBrowseScreenState) {
          child = ConversationView(
            conversationID: browseScreenState.conversationID,
            giverDisplayName: browseScreenState.announcement.giverDisplayName,
            giverPhotoURL: browseScreenState.announcement.giverPhotoURL,
            announcementID: browseScreenState.announcement.docID,
            currentUserID: browseScreenState.user.uid,
            announcement: browseScreenState.announcement,
          );
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
