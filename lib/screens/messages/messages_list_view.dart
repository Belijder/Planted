import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/firebase_paths.dart';
import 'package:planted/helpers/request_permission_for_push.dart';
import 'package:planted/models/conversation.dart';
import 'package:planted/screens/messages/conversation_tile.dart';
import 'package:planted/screens/views/empty_state_view.dart';

class MessagesListView extends HookWidget {
  const MessagesListView({required this.blockedUsers, super.key});
  final Iterable<String> blockedUsers;

  @override
  Widget build(BuildContext context) {
    requestPermissionForPushNotifications();
    final conversationStream = useMemoized(() {
      final userID = FirebaseAuth.instance.currentUser?.uid ?? '';
      return FirebaseFirestore.instance
          .collection(conversationsPath)
          .where(
            Filter.or(
              Filter('giver', isEqualTo: userID),
              Filter('taker', isEqualTo: userID),
            ),
          )
          .orderBy('timeStamp', descending: true)
          .snapshots();
    }, [key]);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text(
              'Wiadomości',
              style: TextStyle(
                  color: colorSepia,
                  fontSize: 30.0,
                  fontWeight: FontWeight.w800),
            ),
          ],
        ),
        backgroundColor: colorEggsheel,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: StreamBuilder(
          stream: conversationStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                  child: Text(
                'Nie udało się pobrać wiadomości. Sprawdz połączenie z internetem i spróbuj ponownie za chwilę.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colorSepia, fontSize: 10),
              ));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final conversations = snapshot.data!.docs
                .map((snapshot) => Conversation.fromSnapshot(snapshot));

            final filteredConversations = conversations.where((element) =>
                !blockedUsers.contains(element.giver) &&
                !blockedUsers.contains(element.taker));

            if (filteredConversations.isEmpty) {
              return const EmptyStateView(
                message: 'Nie masz żadnych wiadomości w skrzynce.',
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
