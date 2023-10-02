import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:planted/auth_error.dart';
import 'package:planted/database_error.dart';

@immutable
abstract class AppState extends Equatable {
  final bool isLoading;
  final AuthError? authError;
  final String? snackbarMessage;
  final DatabaseError? databaseError;

  const AppState(
      {required this.isLoading,
      this.authError,
      this.snackbarMessage,
      this.databaseError});
}

@immutable
class AppStateInitialState extends AppState {
  const AppStateInitialState({
    required super.isLoading,
  });

  @override
  List<Object?> get props => [isLoading];
}

@immutable
class AppStateLoggedOut extends AppState {
  const AppStateLoggedOut({
    required super.isLoading,
    super.authError,
    super.snackbarMessage,
  });

  @override
  String toString() {
    return 'AppStateLoggedOut, (isLoading; $isLoading, authError: $authError)';
  }

  @override
  List<Object?> get props => [isLoading, authError, snackbarMessage];
}

@immutable
class AppStateLoggedIn extends AppState {
  final User user;

  const AppStateLoggedIn({
    required super.isLoading,
    super.authError,
    super.databaseError,
    super.snackbarMessage,
    required this.user,
  });

  @override
  String toString() {
    return 'AppStateLoggedIn, (isLoading: $isLoading, authError: $authError, userUID: ${user.uid})';
  }

  @override
  List<Object?> get props =>
      [isLoading, authError, databaseError, snackbarMessage, user];
}

@immutable
class AppStateIsInRegistrationView extends AppState {
  final String? path;
  const AppStateIsInRegistrationView({
    required super.isLoading,
    super.authError,
    super.databaseError,
    this.path,
  });

  @override
  List<Object?> get props => [path, isLoading, authError, databaseError];
}

@immutable
class AppStateIsInConfirmationEmailView extends AppState {
  const AppStateIsInConfirmationEmailView({
    required super.isLoading,
    super.authError,
    super.snackbarMessage,
  });

  @override
  List<Object?> get props => [isLoading, authError, snackbarMessage];
}

@immutable
class AppStateIsInCompleteProfileView extends AppState {
  final User user;

  const AppStateIsInCompleteProfileView({
    required super.isLoading,
    super.authError,
    super.snackbarMessage,
    super.databaseError,
    required this.user,
  });

  @override
  List<Object?> get props =>
      [user, isLoading, authError, snackbarMessage, databaseError];
}

extension GetUser on AppState {
  User? get user {
    final cls = this;
    if (cls is AppStateLoggedIn) {
      return cls.user;
    } else {
      return null;
    }
  }
}
