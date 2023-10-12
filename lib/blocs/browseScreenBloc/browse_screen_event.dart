import 'package:flutter/material.dart' show immutable;
import 'package:planted/models/announcement.dart';
import 'package:planted/models/conversation.dart';

@immutable
abstract class BrowseScreenEvent {
  const BrowseScreenEvent();
}

@immutable
class BrowseScreenEventInitialize implements BrowseScreenEvent {
  const BrowseScreenEventInitialize();
}

@immutable
class BrowseScreenEventGoToDetailView implements BrowseScreenEvent {
  final Announcement announcement;
  final double? scrollViewOffset;
  const BrowseScreenEventGoToDetailView({
    required this.announcement,
    this.scrollViewOffset,
  });
}

@immutable
class BrowseScreenEventGoToListView implements BrowseScreenEvent {
  const BrowseScreenEventGoToListView();
}

@immutable
class BrowseScreenEventGoToConversationView implements BrowseScreenEvent {
  final Announcement announcement;
  const BrowseScreenEventGoToConversationView({required this.announcement});
}

@immutable
class BrowseScreenEventStartNewConversation implements BrowseScreenEvent {
  final Announcement announcement;
  final String message;
  final String conversationID;
  const BrowseScreenEventStartNewConversation({
    required this.announcement,
    required this.conversationID,
    required this.message,
  });
}

@immutable
class BrowseScreenEventCancelConversation implements BrowseScreenEvent {
  final String conversationID;
  final Announcement announcement;

  const BrowseScreenEventCancelConversation({
    required this.conversationID,
    required this.announcement,
  });
}

@immutable
class BrowseScreenEventSendMessage implements BrowseScreenEvent {
  final Announcement announcement;
  final String message;
  final Conversation conversation;
  const BrowseScreenEventSendMessage({
    required this.announcement,
    required this.conversation,
    required this.message,
  });
}

@immutable
class BrowseScreenEventBlockUserFromConvesationView
    implements BrowseScreenEvent {
  final String currentUserID;
  final String userToBlockID;
  final Announcement announcement;
  final Conversation conversation;

  const BrowseScreenEventBlockUserFromConvesationView({
    required this.currentUserID,
    required this.userToBlockID,
    required this.announcement,
    required this.conversation,
  });
}

@immutable
class BrowseScreenEventBlockUserFromDetailsView implements BrowseScreenEvent {
  final Announcement announcement;
  final String userToBlockID;

  const BrowseScreenEventBlockUserFromDetailsView({
    required this.announcement,
    required this.userToBlockID,
  });
}

@immutable
class BrowseScreenEventGoToReportViewFromAnnouncement
    implements BrowseScreenEvent {
  final Announcement announcement;

  const BrowseScreenEventGoToReportViewFromAnnouncement({
    required this.announcement,
  });
}

@immutable
class BrowseScreenEventGoToReportViewFromConversation
    implements BrowseScreenEvent {
  final Announcement announcement;
  final Conversation conversation;

  const BrowseScreenEventGoToReportViewFromConversation({
    required this.announcement,
    required this.conversation,
  });
}

@immutable
class BrowseScreenEventSendReport implements BrowseScreenEvent {
  final Announcement announcement;
  final Conversation? conversation;
  final String userID;
  final String reasonForReporting;
  final String additionalInformation;

  const BrowseScreenEventSendReport({
    required this.announcement,
    required this.conversation,
    required this.userID,
    required this.reasonForReporting,
    required this.additionalInformation,
  });
}
