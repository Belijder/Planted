import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_bloc.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_event.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_state.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_bloc.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_event.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_state.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/enums.dart';
import 'package:planted/constants/strings.dart';
import 'package:planted/models/announcement.dart';
import 'package:planted/models/conversation.dart';
import 'package:planted/screens/messages/incoming_message.dart';
import 'package:planted/screens/messages/outgoing_message.dart';
import 'package:planted/screens/views/empty_state_view.dart';
import 'package:planted/styles/text_styles.dart';

enum MessagesPopUpMenuItem { blocUser, reportUser }

class ConversationView extends HookWidget {
  final String currentUserID;
  final Announcement announcement;
  final Conversation conversation;
  final Stream<Conversation>? conversationStream;
  final ParentScreen parentScreen;
  const ConversationView({
    required this.currentUserID,
    required this.announcement,
    required this.conversation,
    required this.conversationStream,
    required this.parentScreen,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final messageController = useTextEditingController();
    final scrollController = useScrollController();
    final messagesCount = useState(0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorEggsheel,
        leading: IconButton(
          onPressed: () {
            returnToParent(
              context: context,
              messagesCount: messagesCount.value,
            );
          },
          icon: const Icon(Icons.arrow_back),
          style: IconButton.styleFrom(
            shadowColor: colorSepia.withAlpha(50),
          ),
          color: colorSepia,
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  currentUserID == conversation.giver
                      ? conversation.takerDisplayName
                      : conversation.giverDisplayName,
                  style: TextStyles.titleTextStyle(weight: FontWeight.bold)),
              Text(
                'Roślina: ${announcement.name}, odbór: ${announcement.city}',
                style: TextStyles.captionTextStyle(weight: FontWeight.w300),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        actions: [
          PopupMenuButton<MessagesPopUpMenuItem>(
            onSelected: (value) {
              switch (value) {
                case MessagesPopUpMenuItem.blocUser:
                  final String userIDtoBlock =
                      currentUserID == conversation.giver
                          ? conversation.taker
                          : conversation.giver;

                  blockUser(
                    context: context,
                    userIDtoBlock: userIDtoBlock,
                  );
                case MessagesPopUpMenuItem.reportUser:
                  goToReportView(
                    context: context,
                  );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<MessagesPopUpMenuItem>(
                value: MessagesPopUpMenuItem.blocUser,
                child: Text(
                  ButtonLabelText.blockUser,
                  style: TextStyles.bodyTextStyle(color: colorRedKenyanCopper),
                ),
              ),
              PopupMenuItem<MessagesPopUpMenuItem>(
                value: MessagesPopUpMenuItem.reportUser,
                child: Text(
                  ButtonLabelText.reportUser,
                  style: TextStyles.bodyTextStyle(color: colorRedKenyanCopper),
                ),
              ),
            ],
          )
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          if (parentScreen == ParentScreen.browseScreen)
            BlocListener<BrowseScreenBloc, BrowseScreenState>(
              listener: (context, browseScreenState) {
                if (browseScreenState is BrowseScreenStateInConversationView) {
                  if (browseScreenState.messageSended == true) {
                    messageController.clear();
                    scrollController
                        .jumpTo(scrollController.position.minScrollExtent);
                  }
                }
              },
            ),
          if (parentScreen == ParentScreen.messagesScreen)
            BlocListener<MessagesScreenBloc, MessagesScreenState>(
              listener: (context, messageScreenState) {
                if (messageScreenState is MessagesScreenStateInConversation) {
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
              child: StreamBuilder<Conversation>(
                  stream: conversationStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError || snapshot.data == null) {
                      return const EmptyStateView(
                        message: StreamMessageText.messagesError,
                      );
                    }

                    final conversation = snapshot.data!;
                    final messages = conversation.messages.reversed;
                    messagesCount.value = messages.length;

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
                          hintText: CustomText.writeMessage,
                          hintStyle: TextStyles.bodyTextStyle(opacity: 0.5),
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
                          sendMessage(
                            context: context,
                            message: messageController.text,
                          );
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

  void returnToParent({
    required BuildContext context,
    required int messagesCount,
  }) {
    switch (parentScreen) {
      case ParentScreen.browseScreen:
        if (messagesCount == 0) {
          context
              .read<BrowseScreenBloc>()
              .add(BrowseScreenEventCancelConversation(
                conversationID: conversation.conversationID,
                announcement: announcement,
              ));
        } else {
          context
              .read<BrowseScreenBloc>()
              .add(BrowseScreenEventGoToDetailView(announcement: announcement));
        }
      case ParentScreen.messagesScreen:
        context
            .read<MessagesScreenBloc>()
            .add(MessagesScreenEventGoToListOfConvesations(
              announcement: announcement,
            ));
    }
  }

  void blockUser({
    required BuildContext context,
    required String userIDtoBlock,
  }) {
    switch (parentScreen) {
      case ParentScreen.browseScreen:
        context
            .read<BrowseScreenBloc>()
            .add(BrowseScreenEventBlockUserFromConvesationView(
              currentUserID: currentUserID,
              userToBlockID: userIDtoBlock,
              announcement: announcement,
              conversation: conversation,
            ));
      case ParentScreen.messagesScreen:
        context.read<MessagesScreenBloc>().add(MessagesScreenEventBlockUser(
              currentUserID: currentUserID,
              userToBlockID: userIDtoBlock,
            ));
    }
  }

  void goToReportView({
    required BuildContext context,
  }) {
    switch (parentScreen) {
      case ParentScreen.browseScreen:
        context
            .read<BrowseScreenBloc>()
            .add(BrowseScreenEventGoToReportViewFromConversation(
              announcement: announcement,
              conversation: conversation,
            ));
      case ParentScreen.messagesScreen:
        context
            .read<MessagesScreenBloc>()
            .add(MessagesScreenEventGoToReportView(
              announcement: announcement,
              conversation: conversation,
              userID: currentUserID,
            ));
    }
  }

  void sendMessage({
    required BuildContext context,
    required String message,
  }) {
    switch (parentScreen) {
      case ParentScreen.browseScreen:
        context.read<BrowseScreenBloc>().add(BrowseScreenEventSendMessage(
              announcement: announcement,
              conversation: conversation,
              message: message,
            ));
      case ParentScreen.messagesScreen:
        context.read<MessagesScreenBloc>().add(MessagesScreenEventSendMessage(
              announcement: announcement,
              conversationID: conversation.conversationID,
              message: message,
            ));
    }
  }
}
