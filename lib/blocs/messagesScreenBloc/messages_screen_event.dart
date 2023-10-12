import 'package:flutter/foundation.dart' show immutable;
import 'package:planted/models/announcement.dart';
import 'package:planted/models/conversation.dart';

@immutable
abstract class MessagesScreenEvent {
  const MessagesScreenEvent();
}

@immutable
class MessagesScreenEventInitialize implements MessagesScreenEvent {
  const MessagesScreenEventInitialize();
}

class MessagesScreenEventGoToConversation implements MessagesScreenEvent {
  final Conversation conversation;
  const MessagesScreenEventGoToConversation({
    required this.conversation,
  });
}

class MessagesScreenEventGoToConversationFromPushMessage
    implements MessagesScreenEvent {
  final String conversationID;
  const MessagesScreenEventGoToConversationFromPushMessage({
    required this.conversationID,
  });
}

@immutable
class MessagesScreenEventGoToListOfConvesations implements MessagesScreenEvent {
  final Announcement announcement;
  const MessagesScreenEventGoToListOfConvesations({
    required this.announcement,
  });
}

@immutable
class MessagesScreenEventSendMessage implements MessagesScreenEvent {
  final Announcement announcement;
  final String conversationID;
  final String message;

  const MessagesScreenEventSendMessage({
    required this.announcement,
    required this.conversationID,
    required this.message,
  });
}

@immutable
class MessagesScreenEventBlockUser implements MessagesScreenEvent {
  final String currentUserID;
  final String userToBlockID;

  const MessagesScreenEventBlockUser({
    required this.currentUserID,
    required this.userToBlockID,
  });
}

@immutable
class MessagesScreenEventGoToReportView implements MessagesScreenEvent {
  final Announcement announcement;
  final Conversation conversation;
  final String userID;
  const MessagesScreenEventGoToReportView({
    required this.announcement,
    required this.conversation,
    required this.userID,
  });
}

@immutable
class MessagesScreenEventBackToConversationFromReportView
    implements MessagesScreenEvent {
  final Conversation conversation;
  final Announcement announcement;
  const MessagesScreenEventBackToConversationFromReportView({
    required this.conversation,
    required this.announcement,
  });
}

@immutable
class MessagesScreenEventSendReport implements MessagesScreenEvent {
  final Announcement announcement;
  final Conversation? conversation;
  final String userID;
  final String reasonForReporting;
  final String additionalInformation;

  const MessagesScreenEventSendReport({
    required this.announcement,
    required this.conversation,
    required this.userID,
    required this.reasonForReporting,
    required this.additionalInformation,
  });
}
