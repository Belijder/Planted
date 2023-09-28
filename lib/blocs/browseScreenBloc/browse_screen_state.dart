import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' show immutable;
import 'package:planted/database_error.dart';
import 'package:planted/models/announcement.dart';

@immutable
abstract class BrowseScreenState {
  final bool isLoading;
  final DatabaseError? databaseError;

  const BrowseScreenState({
    required this.isLoading,
    this.databaseError,
  });
}

@immutable
class InAnnouncementsListViewBrowseScreenState extends BrowseScreenState {
  const InAnnouncementsListViewBrowseScreenState({
    required super.isLoading,
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
  final String conversationID;
  final bool messageSended;

  const InConversationViewBrowseScreenState({
    required super.isLoading,
    super.databaseError,
    required this.user,
    required this.announcement,
    required this.conversationID,
    this.messageSended = false,
  });
}
