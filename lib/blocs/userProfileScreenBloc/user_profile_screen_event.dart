import 'package:flutter/material.dart' show immutable;

@immutable
abstract class UserProfileScreenEvent {
  const UserProfileScreenEvent();
}

@immutable
class UserProfileScreenEventGoToUsersAnnouncementsView
    implements UserProfileScreenEvent {
  const UserProfileScreenEventGoToUsersAnnouncementsView();
}

@immutable
class UserProfileScreenEventGoToBlockedUsersView
    implements UserProfileScreenEvent {
  const UserProfileScreenEventGoToBlockedUsersView();
}

@immutable
class UserProfileScreenEventGoToUserProfileView
    implements UserProfileScreenEvent {
  const UserProfileScreenEventGoToUserProfileView();
}

@immutable
class UserProfileScreenEventDeleteAnnouncement
    implements UserProfileScreenEvent {
  final String documentID;
  const UserProfileScreenEventDeleteAnnouncement({required this.documentID});
}

@immutable
class UserProfileScreenEventArchiveAnnouncement
    implements UserProfileScreenEvent {
  final String documentID;
  final String userID;
  const UserProfileScreenEventArchiveAnnouncement({
    required this.documentID,
    required this.userID,
  });
}

@immutable
class UserProfileScreenEventUnblockUser implements UserProfileScreenEvent {
  final String currentUserID;
  final String idToUnblock;

  const UserProfileScreenEventUnblockUser({
    required this.currentUserID,
    required this.idToUnblock,
  });
}
