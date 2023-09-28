import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_bloc.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_event.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_state.dart';
import 'package:planted/screens/messages/conversation_view.dart';
import 'package:planted/screens/messages/messages_list_view.dart';
import 'package:planted/utilities/dialogs/show_database_error_dialog.dart';
import 'package:planted/utilities/loading/loading_screen.dart';

class MessagesScreenBlocConsumer extends StatelessWidget {
  const MessagesScreenBlocConsumer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MessagesScreenBloc, MessagesScreenState>(
      listener: (context, messagesScreenState) {
        if (messagesScreenState.isLoading) {
          LoadingScreen.instance().show(context: context, text: 'Ładuję...');
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
      },
      builder: (context, messagesScreenState) {
        Widget child;

        if (messagesScreenState is InConversationsListMessagesScreenState) {
          child = const MessagesListView();
        } else if (messagesScreenState is InConversationMessagesScreenState) {
          child = ConversationView(
            conversationID: messagesScreenState.conversation.conversationID,
            announcementID: messagesScreenState.announcement.docID,
            currentUserID: messagesScreenState.userProfile.userID,
            announcement: messagesScreenState.announcement,
            sendMessageBlocEvent: (
                {required announcement,
                required conversationID,
                required message}) {
              context
                  .read<MessagesScreenBloc>()
                  .add(SendMessageMessagesScreenEvent(
                    announcement: announcement,
                    conversationID: conversationID,
                    message: message,
                  ));
            },
            returnBlocEvent: ({
              required announcement,
              required int messagesCount,
              required String conversationID,
            }) {
              context
                  .read<MessagesScreenBloc>()
                  .add(GoToListOfConvesationsMessagesScreenEvent(
                    announcement: announcement,
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
