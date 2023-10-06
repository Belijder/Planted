import 'package:flutter/material.dart' show immutable;
import 'package:planted/database_error.dart';
import 'package:planted/models/announcement.dart';
import 'package:planted/models/conversation.dart';

@immutable
abstract class BrowseScreenState {
  final bool isLoading;
  final DatabaseError? databaseError;
  final String? snackbarMessage;
  final double scrollViewOffset;

  const BrowseScreenState({
    required this.isLoading,
    this.databaseError,
    this.snackbarMessage,
    required this.scrollViewOffset,
  });
}

@immutable
class InAnnouncementsListViewBrowseScreenState extends BrowseScreenState {
  const InAnnouncementsListViewBrowseScreenState({
    required super.isLoading,
    required super.scrollViewOffset,
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
    required super.scrollViewOffset,
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
    required super.scrollViewOffset,
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
    required super.scrollViewOffset,
    super.databaseError,
    required this.userID,
    required this.announcement,
    required this.conversation,
  });
}
