import 'package:flutter/foundation.dart' show immutable;
import 'package:planted/blocs/database_error.dart';
import 'package:planted/models/announcement.dart';
import 'package:planted/models/conversation.dart';
import 'package:planted/models/user_profile.dart';

@immutable
abstract class MessagesScreenState {
  final bool isLoading;
  final DatabaseError? databaseError;
  final String? snackbarMessage;
  final Stream<List<Conversation>>? conversationsListStream;
  final Stream<Conversation>? conversationDetailsStream;
  final Stream<UserProfile>? userProfileStream;

  const MessagesScreenState({
    required this.isLoading,
    required this.databaseError,
    this.snackbarMessage,
    this.conversationsListStream,
    this.conversationDetailsStream,
    this.userProfileStream,
  });
}

@immutable
class MessagesScreenStateInitial extends MessagesScreenState {
  const MessagesScreenStateInitial({
    required super.isLoading,
    super.databaseError,
  });
}

@immutable
class MessagesScreenStateInConversationsList extends MessagesScreenState {
  const MessagesScreenStateInConversationsList({
    required super.isLoading,
    super.databaseError,
    super.snackbarMessage,
    required super.conversationsListStream,
    required super.userProfileStream,
  });
}

@immutable
class MessagesScreenStateInConversation extends MessagesScreenState {
  final Conversation conversation;
  final Announcement announcement;
  final UserProfile userProfile;
  final bool messageSended;

  const MessagesScreenStateInConversation({
    required super.isLoading,
    super.databaseError,
    super.snackbarMessage,
    required super.conversationDetailsStream,
    required this.conversation,
    required this.announcement,
    required this.userProfile,
    this.messageSended = false,
  });
}

@immutable
class MessagesScreenStateInReportView extends MessagesScreenState {
  final String userID;
  final Announcement announcement;
  final Conversation? conversation;

  const MessagesScreenStateInReportView({
    required super.isLoading,
    super.databaseError,
    required this.userID,
    required this.announcement,
    required this.conversation,
  });
}

extension GetAnnouncement on MessagesScreenState {
  Announcement? get announcement {
    final cls = this;
    if (cls is MessagesScreenStateInConversation) {
      return cls.announcement;
    } else {
      return null;
    }
  }
}

extension GetConversation on MessagesScreenState {
  Conversation? get conversation {
    final cls = this;
    if (cls is MessagesScreenStateInConversation) {
      return cls.conversation;
    } else {
      return null;
    }
  }
}

extension GetProfile on MessagesScreenState {
  UserProfile? get userProfile {
    final cls = this;
    if (cls is MessagesScreenStateInConversation) {
      return cls.userProfile;
    } else {
      return null;
    }
  }
}
