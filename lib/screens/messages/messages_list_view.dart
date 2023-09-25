import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_bloc.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_event.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/firebase_paths.dart';
import 'package:planted/models/conversation.dart';

class MessagesListView extends HookWidget {
  const MessagesListView({super.key});

  @override
  Widget build(BuildContext context) {
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
              print('🔵 Error: ${snapshot.error}');
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

            if (conversations.isEmpty) {
              return Center(
                child: Text(
                  'Nie masz żadnych wiadomości w skrzynce.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorSepia.withAlpha(150),
                    fontSize: 15,
                  ),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conversation = conversations.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      context.read<MessagesScreenBloc>().add(
                          GoToConversationMessagesScreenEvent(
                              conversation: conversation));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(conversation.conversationID),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
