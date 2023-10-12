import 'package:flutter/material.dart' show immutable;
import 'package:planted/blocs/database_error.dart';
import 'package:planted/models/announcement.dart';
import 'package:planted/models/conversation.dart';
import 'package:planted/models/user_profile.dart';

@immutable
abstract class BrowseScreenState {
  final bool isLoading;
  final DatabaseError? databaseError;
  final String? snackbarMessage;
  final Stream<List<Announcement>>? announcementsStream;
  final Stream<Conversation>? conversationDetailsStream;
  final Stream<UserProfile>? userProfileStream;
  final double scrollViewOffset;

  const BrowseScreenState({
    required this.isLoading,
    this.databaseError,
    this.snackbarMessage,
    this.announcementsStream,
    this.conversationDetailsStream,
    this.userProfileStream,
    required this.scrollViewOffset,
  });
}

@immutable
class BrowseScreenStateInitial extends BrowseScreenState {
  const BrowseScreenStateInitial({
    required super.isLoading,
    required super.scrollViewOffset,
  });
}

@immutable
class BrowseScreenStateInAnnouncementsListView extends BrowseScreenState {
  const BrowseScreenStateInAnnouncementsListView({
    required super.isLoading,
    required super.scrollViewOffset,
    required super.announcementsStream,
    required super.userProfileStream,
    super.snackbarMessage,
  });
}

@immutable
class BrowseScreenStateInAnnouncementDetails extends BrowseScreenState {
  final Announcement announcement;
  const BrowseScreenStateInAnnouncementDetails({
    required this.announcement,
    super.databaseError,
    super.snackbarMessage,
    required super.scrollViewOffset,
    required super.isLoading,
  });
}

@immutable
class BrowseScreenStateInConversationView extends BrowseScreenState {
  final String userID;
  final Announcement announcement;
  final Conversation conversation;
  final bool messageSended;

  const BrowseScreenStateInConversationView({
    required super.isLoading,
    required super.scrollViewOffset,
    super.databaseError,
    super.snackbarMessage,
    required super.conversationDetailsStream,
    required this.userID,
    required this.announcement,
    required this.conversation,
    this.messageSended = false,
  });
}

@immutable
class BrowseScreenStateInReportView extends BrowseScreenState {
  final String userID;
  final Announcement announcement;
  final Conversation? conversation;

  const BrowseScreenStateInReportView({
    required super.isLoading,
    required super.scrollViewOffset,
    super.databaseError,
    required this.userID,
    required this.announcement,
    required this.conversation,
  });
}
