import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:planted/blocs/app_bloc.dart/app_bloc.dart';
import 'package:planted/blocs/app_bloc.dart/app_event.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_bloc.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_event.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_state.dart';
import 'package:planted/constants/firebase_paths.dart';
import 'package:planted/models/user_profile.dart';
import 'package:planted/screens/messages/conversation_view.dart';
import 'package:planted/screens/messages/messages_list_view.dart';
import 'package:planted/utilities/dialogs/show_database_error_dialog.dart';
import 'package:planted/utilities/loading/loading_screen.dart';

class MessagesScreenBlocConsumer extends HookWidget {
  const MessagesScreenBlocConsumer({required this.userID, super.key});
  final String userID;

  @override
  Widget build(BuildContext context) {
    final userProfileStream = useMemoized(() {
      return FirebaseFirestore.instance
          .collection(profilesPath)
          .doc(userID)
          .snapshots();
    }, [key]);

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

        if (messagesScreenState is InConversationsListMessagesScreenState) {
          child = StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: userProfileStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  context.read<AppBloc>().add(const AppEventLogOut());
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userProfile = UserProfile.fromSnapshot(snapshot.data!);
                return MessagesListView(
                  blockedUsers: userProfile.blockedUsers,
                );
              });
        } else if (messagesScreenState is InConversationMessagesScreenState) {
          child = ConversationView(
            currentUserID: messagesScreenState.userProfile.userID,
            announcement: messagesScreenState.announcement,
            conversation: messagesScreenState.conversation,
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
            blockUserBlocEvent: ({
              required currentUserID,
              required userToBlockID,
              required announcement,
              required conversation,
            }) {
              context
                  .read<MessagesScreenBloc>()
                  .add(BlockUserMessagesScreenEvent(
                    currentUserID: currentUserID,
                    userToBlockID: userToBlockID,
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
