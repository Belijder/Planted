import 'package:flutter/foundation.dart' show immutable;
import 'package:planted/database_error.dart';
import 'package:planted/models/announcement.dart';
import 'package:planted/models/conversation.dart';
import 'package:planted/models/user_profile.dart';

@immutable
abstract class MessagesScreenState {
  final bool isLoading;
  final DatabaseError? databaseError;
  final String? snackbarMessage;

  const MessagesScreenState({
    required this.isLoading,
    required this.databaseError,
    this.snackbarMessage,
  });
}

@immutable
class InConversationsListMessagesScreenState extends MessagesScreenState {
  const InConversationsListMessagesScreenState({
    required super.isLoading,
    super.databaseError,
    super.snackbarMessage,
  });
}

@immutable
class InConversationMessagesScreenState extends MessagesScreenState {
  final Conversation conversation;
  final Announcement announcement;
  final UserProfile userProfile;
  final bool messageSended;

  const InConversationMessagesScreenState({
    required super.isLoading,
    super.databaseError,
    required this.conversation,
    required this.announcement,
    required this.userProfile,
    this.messageSended = false,
  });
}

extension GetAnnouncement on MessagesScreenState {
  Announcement? get announcement {
    final cls = this;
    if (cls is InConversationMessagesScreenState) {
      return cls.announcement;
    } else {
      return null;
    }
  }
}

extension GetConversation on MessagesScreenState {
  Conversation? get conversation {
    final cls = this;
    if (cls is InConversationMessagesScreenState) {
      return cls.conversation;
    } else {
      return null;
    }
  }
}

extension GetProfile on MessagesScreenState {
  UserProfile? get userProfile {
    final cls = this;
    if (cls is InConversationMessagesScreenState) {
      return cls.userProfile;
    } else {
      return null;
    }
  }
}
