import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:planted/database_error.dart';
import 'package:planted/models/announcement.dart';
import 'package:planted/models/report.dart';

@immutable
abstract class UserProfileScreenState extends Equatable {
  final bool isLoading;
  final DatabaseError? databaseError;
  final String? snackbarMessage;
  final Stream<List<Announcement>>? announcementsStream;
  final Stream<List<Report>>? reportsStream;

  const UserProfileScreenState({
    required this.isLoading,
    this.databaseError,
    this.snackbarMessage,
    this.announcementsStream,
    this.reportsStream,
  });

  @override
  List<Object?> get props => [isLoading, databaseError, snackbarMessage];
}

@immutable
class UserProfileScreenStateInUserProfileView extends UserProfileScreenState {
  final String? path;
  const UserProfileScreenStateInUserProfileView({
    required super.isLoading,
    super.databaseError,
    super.snackbarMessage,
    this.path,
  });

  @override
  List<Object?> get props => [isLoading, databaseError, snackbarMessage, path];
}

@immutable
class UserProfileScreenStateInUsersAnnouncementsView
    extends UserProfileScreenState {
  const UserProfileScreenStateInUsersAnnouncementsView({
    required super.isLoading,
    super.databaseError,
    super.snackbarMessage,
  });
}

@immutable
class UserProfileScreenStateInBlockedUsersView extends UserProfileScreenState {
  const UserProfileScreenStateInBlockedUsersView({
    required super.isLoading,
    super.databaseError,
    super.snackbarMessage,
  });
}

@immutable
class UserProfileScreenStateInAdministratorPanel
    extends UserProfileScreenState {
  final int initialTabBarIndex;
  const UserProfileScreenStateInAdministratorPanel({
    required super.announcementsStream,
    required super.reportsStream,
    super.databaseError,
    required this.initialTabBarIndex,
    required super.isLoading,
  });
}

@immutable
class UserProfileScreenStateInUserReportsView extends UserProfileScreenState {
  const UserProfileScreenStateInUserReportsView({
    required super.reportsStream,
    super.databaseError,
    required super.isLoading,
  });
}
