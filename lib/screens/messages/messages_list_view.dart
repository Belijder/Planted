import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_bloc.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/strings.dart';
import 'package:planted/helpers/request_permission_for_push.dart';
import 'package:planted/screens/messages/conversation_tile.dart';
import 'package:planted/screens/views/empty_state_view.dart';
import 'package:planted/styles/text_styles.dart';

class MessagesListView extends HookWidget {
  const MessagesListView({required this.blockedUsers, super.key});
  final Iterable<String> blockedUsers;

  @override
  Widget build(BuildContext context) {
    requestPermissionForPushNotifications();

    final conversationsStream =
        context.read<MessagesScreenBloc>().state.conversationsListStream;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              AppBarTitleText.messages,
              style: TextStyles.largeTitleTextStyle(weight: FontWeight.w800),
            ),
          ],
        ),
        backgroundColor: colorEggsheel,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: StreamBuilder(
          stream: conversationsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || snapshot.data == null) {
              return const EmptyStateView(
                  message: StreamMessageText.messagesError);
            }

            final conversations = snapshot.data!;
            final filteredConversations = conversations.where((element) =>
                !blockedUsers.contains(element.giver) &&
                !blockedUsers.contains(element.taker));

            if (filteredConversations.isEmpty) {
              return const EmptyStateView(
                message: StreamMessageText.messagesEmpty,
              );
            } else {
              return ListView.builder(
                itemCount: filteredConversations.length,
                itemBuilder: (context, index) {
                  final conversation = filteredConversations.elementAt(index);
                  final currentUserID = FirebaseAuth.instance.currentUser?.uid;

                  return ConversationTile(
                      conversation: conversation, currentUserID: currentUserID);
                },
              );
            }
          },
        ),
      ),
    );
  }
}
