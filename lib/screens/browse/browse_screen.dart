import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_bloc.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_event.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_state.dart';
import 'package:planted/constants/strings.dart';
import 'package:planted/screens/browse/announcement_details_view.dart';
import 'package:planted/screens/browse/announcements_list_view.dart';
import 'package:planted/screens/messages/conversation_view.dart';
import 'package:planted/screens/views/report_view.dart';
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
          LoadingScreen.instance().show(
            context: context,
            text: LoadingScreenText.loading,
          );
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

        final message = browseScreenState.snackbarMessage;
        if (message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 2),
              content: Text(message),
            ),
          );
        }
      },
      builder: (context, browseScreenState) {
        Widget child;

        if (browseScreenState is BrowseScreenStateInitial) {
          child = Container();
        } else if (browseScreenState
            is BrowseScreenStateInAnnouncementsListView) {
          child = const AnnouncementListView();
        } else if (browseScreenState
            is BrowseScreenStateInAnnouncementDetails) {
          child = AnnouncementDetailsView(
              announcement: browseScreenState.announcement);
        } else if (browseScreenState is BrowseScreenStateInConversationView) {
          final conversationStream =
              context.read<BrowseScreenBloc>().state.conversationDetailsStream;
          child = ConversationView(
            parentScreen: ConversationParentScreen.browseScreen,
            currentUserID: browseScreenState.userID,
            announcement: browseScreenState.announcement,
            conversation: browseScreenState.conversation,
            conversationStream: conversationStream,
          );
        } else if (browseScreenState is BrowseScreenStateInReportView) {
          child = ReportView(
            announcement: browseScreenState.announcement,
            conversation: browseScreenState.conversation,
            userID: browseScreenState.userID,
            returnAction: ({
              required announcement,
              required conversation,
              required userID,
            }) {
              if (conversation != null) {
                context.read<BrowseScreenBloc>().add(
                    BrowseScreenEventGoToConversationView(
                        announcement: announcement));
              } else {
                context.read<BrowseScreenBloc>().add(
                    BrowseScreenEventGoToDetailView(
                        announcement: announcement));
              }
            },
            reportAction: ({
              required additionalInformation,
              required announcement,
              required conversation,
              required reasonForReporting,
              required userID,
            }) {
              context.read<BrowseScreenBloc>().add(BrowseScreenEventSendReport(
                    announcement: announcement,
                    conversation: conversation,
                    userID: userID,
                    reasonForReporting: reasonForReporting,
                    additionalInformation: additionalInformation,
                  ));
            },
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
