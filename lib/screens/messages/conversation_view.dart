import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_bloc.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_state.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_bloc.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_state.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/firebase_paths.dart';
import 'package:planted/models/announcement.dart';
import 'package:planted/models/conversation.dart';
import 'package:planted/screens/messages/incoming_message.dart';
import 'package:planted/screens/messages/outgoing_message.dart';
import 'package:planted/styles/text_styles.dart';

typedef SendMessageBlocEvent = void Function({
  required Announcement announcement,
  required String conversationID,
  required String message,
});
typedef ReturnBlocEvent = void Function({
  required Announcement announcement,
});

class ConversationView extends HookWidget {
  final String conversationID;
  final String announcementID;
  final String currentUserID;
  final Announcement announcement;
  final SendMessageBlocEvent sendMessageBlocEvent;
  final ReturnBlocEvent returnBlocEvent;
  const ConversationView({
    required this.conversationID,
    required this.announcementID,
    required this.currentUserID,
    required this.announcement,
    required this.sendMessageBlocEvent,
    required this.returnBlocEvent,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final messageController = useTextEditingController();
    final scrollController = useScrollController();

    final messagesStream = useMemoized(() {
      return FirebaseFirestore.instance
          .collection(conversationsPath)
          .doc(conversationID)
          .snapshots();
    }, [key]);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorEggsheel,
        leading: IconButton(
          onPressed: () {
            returnBlocEvent(announcement: announcement);
          },
          icon: const Icon(Icons.arrow_back),
          style: IconButton.styleFrom(
            shadowColor: colorSepia.withAlpha(50),
          ),
          color: colorSepia,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              announcement.giverDisplayName,
              style: const TextStyle(
                  color: colorSepia, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Roślina: ${announcement.name}, odbór: ${announcement.city}',
              style: const TextStyle(
                  color: colorSepia, fontSize: 10, fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<BrowseScreenBloc, BrowseScreenState>(
            listener: (context, browseScreenState) {
              if (browseScreenState is InConversationViewBrowseScreenState) {
                if (browseScreenState.messageSended == true) {
                  messageController.clear();
                  scrollController
                      .jumpTo(scrollController.position.minScrollExtent);
                }
              }
            },
          ),
          BlocListener<MessagesScreenBloc, MessagesScreenState>(
            listener: (context, messageScreenState) {
              if (messageScreenState is InConversationMessagesScreenState) {
                if (messageScreenState.messageSended == true) {
                  messageController.clear();
                  scrollController
                      .jumpTo(scrollController.position.minScrollExtent);
                }
              }
            },
          ),
        ],
        child: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: messagesStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'Nie udało się pobrać Wiadomości. Sprawdz połączenie z internetem i spróbuj ponownie za chwilę.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colorSepia, fontSize: 10),
                          ),
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final conversation =
                        Conversation.fromSnapshot(snapshot.data!);
                    final messages = conversation.messages.reversed;

                    return GestureDetector(
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: ListView.builder(
                        reverse: true,
                        controller: scrollController,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final sender = messages.elementAt(index).sender;
                          final message = messages.elementAt(index).message;
                          if (sender != currentUserID) {
                            return IncomingMessage(message: message);
                          } else {
                            return OutgoingMessage(message: message);
                          }
                        },
                      ),
                    );
                  }),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                        controller: messageController,
                        decoration: InputDecoration(
                          hintText: 'Napisz wiadomość...',
                          hintStyle: formLabelTextStyle,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: colorDarkMossGreen,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: colorSepia,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        minLines: 1,
                        maxLines: 5,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.newline,
                        textAlignVertical: TextAlignVertical.center,
                        onSubmitted: (text) {}),
                  ),
                  IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: colorDarkMossGreen,
                      ),
                      onPressed: () {
                        if (messageController.text != '') {
                          sendMessageBlocEvent(
                              announcement: announcement,
                              conversationID: conversationID,
                              message: messageController.text);
                        }
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
