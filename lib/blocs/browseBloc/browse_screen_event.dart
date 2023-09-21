import 'package:flutter/material.dart' show immutable;
import 'package:planted/models/announcement.dart';

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

class GoToConversationViewBrowseScreenEvent implements BrowseScreenEvent {
  final Announcement announcement;
  const GoToConversationViewBrowseScreenEvent({required this.announcement});
}

class StartNewConversationBrowseScreenEvent implements BrowseScreenEvent {
  final Announcement announcement;
  final String message;
  final String conversationID;
  StartNewConversationBrowseScreenEvent({
    required this.announcement,
    required this.conversationID,
    required this.message,
  });
}

class SendMessageBrowseScreenEvent implements BrowseScreenEvent {
  final Announcement announcement;
  final String message;
  final String conversationID;
  SendMessageBrowseScreenEvent({
    required this.announcement,
    required this.conversationID,
    required this.message,
  });
}
