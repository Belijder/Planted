import 'package:flutter/foundation.dart' show immutable;
import 'package:planted/models/announcement.dart';
import 'package:planted/models/conversation.dart';

@immutable
abstract class MessagesScreenEvent {
  const MessagesScreenEvent();
}

class GoToConversationMessagesScreenEvent implements MessagesScreenEvent {
  final Conversation conversation;
  const GoToConversationMessagesScreenEvent({
    required this.conversation,
  });
}

@immutable
class GoToListOfConvesationsMessagesScreenEvent implements MessagesScreenEvent {
  final Announcement announcement;
  const GoToListOfConvesationsMessagesScreenEvent({
    required this.announcement,
  });
}

@immutable
class SendMessageMessagesScreenEvent implements MessagesScreenEvent {
  final Announcement announcement;
  final String conversationID;
  final String message;

  const SendMessageMessagesScreenEvent({
    required this.announcement,
    required this.conversationID,
    required this.message,
  });
}
