import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:planted/database_error.dart';

@immutable
abstract class UserProfileScreenState extends Equatable {
  final bool isLoading;
  final DatabaseError? databaseError;
  final String? snackbarMessage;

  const UserProfileScreenState({
    required this.isLoading,
    this.databaseError,
    this.snackbarMessage,
  });

  @override
  List<Object?> get props => [isLoading, databaseError, snackbarMessage];
}

@immutable
class UserProfileScreenStateInUserProfileView extends UserProfileScreenState {
  const UserProfileScreenStateInUserProfileView({
    required super.isLoading,
    super.databaseError,
    super.snackbarMessage,
  });
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
