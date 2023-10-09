import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_bloc.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_event.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/extensions/time_stamp_extensions.dart';
import 'package:planted/helpers/format_timestamp.dart';
import 'package:planted/models/conversation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.currentUserID,
  });

  final Conversation conversation;
  final String? currentUserID;

  @override
  Widget build(BuildContext context) {
    final lastUserActivity = conversation.giver == currentUserID
        ? conversation.giverLastActivity
        : conversation.takerLastActivity;

    final hasUnreadMessages =
        lastUserActivity.isEarlierThan(conversation.timeStamp);

    return GestureDetector(
      onTap: () {
        context.read<MessagesScreenBloc>().add(
            GoToConversationMessagesScreenEvent(conversation: conversation));
      },
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          color: colorEggsheel,
          height: 50,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: CachedNetworkImage(
                  imageUrl: currentUserID == conversation.giver
                      ? conversation.takerPhotoURL
                      : conversation.giverPhotoURL,
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                  errorWidget: (context, _, __) =>
                      Image.asset('assets/images/person.png'),
                  placeholder: (context, _) =>
                      Image.asset('assets/images/person.png'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          currentUserID == conversation.giver
                              ? conversation.takerDisplayName
                              : conversation.giverDisplayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: colorSepia,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            ('(${conversation.announcementName})'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 10,
                              color: colorSepia,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          formatTimestamp(conversation.timeStamp),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: colorSepia,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      conversation.messages.isNotEmpty
                          ? conversation.messages.last.message
                          : '',
                      maxLines: 2,
                      style: TextStyle(
                        fontWeight: hasUnreadMessages
                            ? FontWeight.bold
                            : FontWeight.w300,
                        fontSize: 10,
                        overflow: TextOverflow.ellipsis,
                        color: colorSepia,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
