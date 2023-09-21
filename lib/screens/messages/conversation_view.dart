import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:planted/blocs/browseBloc/browse_screen_bloc.dart';
import 'package:planted/blocs/browseBloc/browse_screen_event.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/firebase_paths.dart';
import 'package:planted/models/announcement.dart';
import 'package:planted/models/conversation.dart';
import 'package:planted/styles/text_styles.dart';

class ConversationView extends HookWidget {
  final String conversationID;
  final String giverDisplayName;
  final String giverPhotoURL;
  final String announcementID;
  final String currentUserID;
  final Announcement? announcement;
  const ConversationView({
    required this.conversationID,
    required this.giverDisplayName,
    required this.giverPhotoURL,
    required this.announcementID,
    required this.currentUserID,
    this.announcement,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final messageController = useTextEditingController();

    final messagesStream = useMemoized(() {
      return FirebaseFirestore.instance
          .collection(conversationsPath)
          .doc(conversationID)
          .snapshots();
    }, [key]);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorEggsheel,
        leading: Padding(
          padding: const EdgeInsets.only(left: 0.0),
          child: IconButton(
            onPressed: () {
              if (announcement != null) {
                context.read<BrowseScreenBloc>().add(
                    GoToDetailViewBrowseScreenEvent(
                        announcement: announcement!));
              }
            },
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              shadowColor: colorSepia.withAlpha(50),
            ),
            color: colorSepia,
          ),
        ),
        title: const Text(
          'Tytuł rozmowy',
          style: TextStyle(
              color: colorSepia, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: messagesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text(
                      'Nie udało się pobrać Wiadomości. Sprawdz połączenie z internetem i spróbuj ponownie za chwilę.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorSepia, fontSize: 10),
                    ));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final conversation =
                      Conversation.fromSnapshot(snapshot.data!);
                  final messages = conversation.messages;

                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(messages[index].message),
                      );
                    },
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
                      if (announcement != null) {
                        context.read<BrowseScreenBloc>().add(
                            SendMessageBrowseScreenEvent(
                                announcement: announcement!,
                                conversationID: conversationID,
                                message: messageController.text));
                      }
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
