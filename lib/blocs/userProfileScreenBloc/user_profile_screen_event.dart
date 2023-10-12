import 'package:flutter/material.dart' show immutable;
import 'package:planted/constants/enums/admin_announcement_action.dart';
import 'package:planted/models/user_profile.dart';

@immutable
abstract class UserProfileScreenEvent {
  const UserProfileScreenEvent();
}

@immutable
class UserProfileScreenEventInitialize implements UserProfileScreenEvent {
  const UserProfileScreenEventInitialize();
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

@immutable
class UserProfileScreenEventOpenLegalTerms implements UserProfileScreenEvent {
  final String documentID;
  const UserProfileScreenEventOpenLegalTerms({required this.documentID});
}

@immutable
class UserProfileScreenEventGoToAdministratorPanelView
    implements UserProfileScreenEvent {
  final UserProfile userProfile;
  final int initialTabBarIndex;
  const UserProfileScreenEventGoToAdministratorPanelView({
    required this.initialTabBarIndex,
    required this.userProfile,
  });
}

@immutable
class UserProfileScreenEventChangeStatusOfAnnouncement
    implements UserProfileScreenEvent {
  final String announcementID;
  final AdminAnnouncementAction action;

  const UserProfileScreenEventChangeStatusOfAnnouncement({
    required this.announcementID,
    required this.action,
  });
}

@immutable
class UserProfileScreenEventGoToUserReportsView
    implements UserProfileScreenEvent {
  final String userID;
  const UserProfileScreenEventGoToUserReportsView({
    required this.userID,
  });
}
