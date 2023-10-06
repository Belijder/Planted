import 'package:flutter/material.dart' show immutable;
import 'package:planted/database_error.dart';
import 'package:planted/models/announcement.dart';
import 'package:planted/models/conversation.dart';

@immutable
abstract class BrowseScreenState {
  final bool isLoading;
  final DatabaseError? databaseError;
  final String? snackbarMessage;

  const BrowseScreenState(
      {required this.isLoading, this.databaseError, this.snackbarMessage});
}

@immutable
class InAnnouncementsListViewBrowseScreenState extends BrowseScreenState {
  const InAnnouncementsListViewBrowseScreenState({
    required super.isLoading,
    super.snackbarMessage,
  });
}

@immutable
class InAnnouncementDetailsBrowseScreenState extends BrowseScreenState {
  final Announcement announcement;
  const InAnnouncementDetailsBrowseScreenState({
    required this.announcement,
    super.databaseError,
    super.snackbarMessage,
    required super.isLoading,
  });
}

@immutable
class InConversationViewBrowseScreenState extends BrowseScreenState {
  final String userID;
  final Announcement announcement;
  final Conversation conversation;
  final bool messageSended;

  const InConversationViewBrowseScreenState({
    required super.isLoading,
    super.databaseError,
    super.snackbarMessage,
    required this.userID,
    required this.announcement,
    required this.conversation,
    this.messageSended = false,
  });
}

@immutable
class InReportViewBrowseScreenState extends BrowseScreenState {
  final String userID;
  final Announcement announcement;
  final Conversation? conversation;

  const InReportViewBrowseScreenState({
    required super.isLoading,
    super.databaseError,
    required this.userID,
    required this.announcement,
    required this.conversation,
  });
}
