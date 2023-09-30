import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:planted/auth_error.dart';
import 'package:planted/database_error.dart';

@immutable
abstract class AppState {
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
  bool operator ==(other) {
    final otherClass = other;
    if (otherClass is AppStateLoggedIn) {
      return isLoading == otherClass.isLoading &&
          user.uid == otherClass.user.uid;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => Object.hash(user.uid, isLoading);

  @override
  String toString() {
    return 'AppStateLoggedIn, (isLoading: $isLoading, authError: $authError, userUID: ${user.uid})';
  }
}

@immutable
class AppStateIsInRegistrationView extends AppState {
  const AppStateIsInRegistrationView({
    required super.isLoading,
    super.authError,
  });
}

@immutable
class AppStateIsInConfirmationEmailView extends AppState {
  const AppStateIsInConfirmationEmailView({
    required super.isLoading,
    super.authError,
    super.snackbarMessage,
  });
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
