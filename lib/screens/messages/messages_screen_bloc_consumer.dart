import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:planted/blocs/authBloc/auth_bloc.dart';
import 'package:planted/blocs/authBloc/auth_event.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_bloc.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_state.dart';
import 'package:planted/constants/enums.dart';
import 'package:planted/constants/strings.dart';
import 'package:planted/models/user_profile.dart';
import 'package:planted/screens/messages/conversation_view.dart';
import 'package:planted/screens/messages/messages_list_view.dart';
import 'package:planted/screens/views/report_view.dart';
import 'package:planted/utilities/dialogs/show_database_error_dialog.dart';
import 'package:planted/utilities/loading/loading_screen.dart';
import 'package:planted/utilities/widget_utils.dart';

class MessagesScreenBlocConsumer extends HookWidget {
  const MessagesScreenBlocConsumer({required this.userID, super.key});
  final String userID;

  @override
  Widget build(BuildContext context) {
    final userProfileStream =
        context.watch<MessagesScreenBloc>().state.userProfileStream;

    return BlocConsumer<MessagesScreenBloc, MessagesScreenState>(
      listener: (context, messagesScreenState) {
        if (messagesScreenState.isLoading) {
          LoadingScreen.instance().show(
            context: context,
            text: LoadingScreenText.loading,
          );
        } else {
          LoadingScreen.instance().hide();
        }

        final databaseError = messagesScreenState.databaseError;
        if (databaseError != null) {
          showDatabaseErrorDialog(
            context: context,
            databaseError: databaseError,
          );
        }

        final message = messagesScreenState.snackbarMessage;
        if (message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 2),
              content: Text(message),
            ),
          );
        }
      },
      builder: (context, messagesScreenState) {
        Widget child;
        if (messagesScreenState is MessagesScreenStateInitial) {
          return Container();
        } else if (messagesScreenState
            is MessagesScreenStateInConversationsList) {
          child = StreamBuilder<UserProfile>(
              stream: userProfileStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || snapshot.data == null) {
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                }

                final userProfile = snapshot.data!;
                return MessagesListView(
                  blockedUsers: userProfile.blockedUsers,
                );
              });
        } else if (messagesScreenState is MessagesScreenStateInConversation) {
          final conversationStream = context
              .read<MessagesScreenBloc>()
              .state
              .conversationDetailsStream;
          child = ConversationView(
            parentScreen: ParentScreen.messagesScreen,
            currentUserID: messagesScreenState.userProfile.userID,
            announcement: messagesScreenState.announcement,
            conversation: messagesScreenState.conversation,
            conversationStream: conversationStream,
          );
        } else if (messagesScreenState is MessagesScreenStateInReportView) {
          child = ReportView(
            announcement: messagesScreenState.announcement,
            conversation: messagesScreenState.conversation,
            userID: userID,
            parentScreen: ParentScreen.messagesScreen,
          );
        } else {
          child = const Center(child: CircularProgressIndicator());
        }

        return createAnimatedSwitcher(child: child);
      },
    );
  }
}
