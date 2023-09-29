import 'package:firebase_auth/firebase_auth.dart';
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
    required super.isLoading,
  });
}

@immutable
class InConversationViewBrowseScreenState extends BrowseScreenState {
  final User user;
  final Announcement announcement;
  final Conversation conversation;
  final bool messageSended;

  const InConversationViewBrowseScreenState({
    required super.isLoading,
    super.databaseError,
    required this.user,
    required this.announcement,
    required this.conversation,
    this.messageSended = false,
  });
}
