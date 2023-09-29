import 'package:flutter/material.dart' show immutable;
import 'package:planted/models/announcement.dart';
import 'package:planted/models/conversation.dart';

@immutable
abstract class BrowseScreenEvent {
  const BrowseScreenEvent();
}

@immutable
class GoToDetailViewBrowseScreenEvent implements BrowseScreenEvent {
  final Announcement announcement;
  const GoToDetailViewBrowseScreenEvent({required this.announcement});
}

@immutable
class GoToListViewBrowseScreenEvent implements BrowseScreenEvent {
  const GoToListViewBrowseScreenEvent();
}

@immutable
class GoToConversationViewBrowseScreenEvent implements BrowseScreenEvent {
  final Announcement announcement;
  const GoToConversationViewBrowseScreenEvent({required this.announcement});
}

@immutable
class StartNewConversationBrowseScreenEvent implements BrowseScreenEvent {
  final Announcement announcement;
  final String message;
  final String conversationID;
  const StartNewConversationBrowseScreenEvent({
    required this.announcement,
    required this.conversationID,
    required this.message,
  });
}

@immutable
class CancelConversationBrowseScreenEvent implements BrowseScreenEvent {
  final String conversationID;
  final Announcement announcement;

  const CancelConversationBrowseScreenEvent({
    required this.conversationID,
    required this.announcement,
  });
}

@immutable
class SendMessageBrowseScreenEvent implements BrowseScreenEvent {
  final Announcement announcement;
  final String message;
  final Conversation conversation;
  const SendMessageBrowseScreenEvent({
    required this.announcement,
    required this.conversation,
    required this.message,
  });
}

@immutable
class BlockUserFromConvesationViewBrowseScreenEvent
    implements BrowseScreenEvent {
  final String currentUserID;
  final String userToBlockID;

  const BlockUserFromConvesationViewBrowseScreenEvent({
    required this.currentUserID,
    required this.userToBlockID,
  });
}

@immutable
class BlockUserFromDetailsViewBrowseScreenEvent implements BrowseScreenEvent {
  final Announcement announcement;
  final String userToBlockID;

  const BlockUserFromDetailsViewBrowseScreenEvent({
    required this.announcement,
    required this.userToBlockID,
  });
}
