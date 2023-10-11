import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:planted/blocs/auth_error.dart';
import 'package:planted/blocs/database_error.dart';

@immutable
abstract class AuthState extends Equatable {
  final bool isLoading;
  final AuthError? authError;
  final String? snackbarMessage;
  final DatabaseError? databaseError;

  const AuthState(
      {required this.isLoading,
      this.authError,
      this.snackbarMessage,
      this.databaseError});
}

@immutable
class AuthStateInitialState extends AuthState {
  const AuthStateInitialState({
    required super.isLoading,
  });

  @override
  List<Object?> get props => [isLoading];
}

@immutable
class AuthStateLoggedOut extends AuthState {
  const AuthStateLoggedOut({
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
class AuthStateLoggedIn extends AuthState {
  final User user;

  const AuthStateLoggedIn({
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
class AuthStateIsInRegistrationView extends AuthState {
  final String? path;
  const AuthStateIsInRegistrationView({
    required super.isLoading,
    super.authError,
    super.databaseError,
    this.path,
  });

  @override
  List<Object?> get props => [path, isLoading, authError, databaseError];
}

@immutable
class AuthStateIsInConfirmationEmailView extends AuthState {
  const AuthStateIsInConfirmationEmailView({
    required super.isLoading,
    super.authError,
    super.snackbarMessage,
  });

  @override
  List<Object?> get props => [isLoading, authError, snackbarMessage];
}

@immutable
class AuthStateIsInCompleteProfileView extends AuthState {
  final User user;

  const AuthStateIsInCompleteProfileView({
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

extension GetUser on AuthState {
  User? get user {
    final cls = this;
    if (cls is AuthStateLoggedIn) {
      return cls.user;
    } else {
      return null;
    }
  }
}
