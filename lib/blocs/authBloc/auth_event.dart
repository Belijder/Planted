import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

@immutable
class AppEventInitialize implements AuthEvent {
  const AppEventInitialize();
}

@immutable
class AuthEventGoToRegisterView implements AuthEvent {
  const AuthEventGoToRegisterView();
}

@immutable
class AuthEventGoToLoginView implements AuthEvent {
  const AuthEventGoToLoginView();
}

@immutable
class AuthEventGoToCompleteProfileView implements AuthEvent {
  const AuthEventGoToCompleteProfileView();
}

@immutable
class AuthEventSendResetPassword implements AuthEvent {
  final String email;

  const AuthEventSendResetPassword({
    required this.email,
  });
}

@immutable
class AuthEventRegister implements AuthEvent {
  final String email;
  final String password;
  final String confirmPassword;
  final bool areLegalTermsAccepted;

  const AuthEventRegister(
      {required this.email,
      required this.password,
      required this.confirmPassword,
      required this.areLegalTermsAccepted});
}

@immutable
class AuthEventLogIn implements AuthEvent {
  final String email;
  final String password;

  const AuthEventLogIn({
    required this.email,
    required this.password,
  });
}

@immutable
class AuthEventLogOut implements AuthEvent {
  const AuthEventLogOut();
}

@immutable
class AuthEventDeleteAccount implements AuthEvent {
  final String password;
  const AuthEventDeleteAccount({required this.password});
}

@immutable
class AuthEventResentVerificationMail implements AuthEvent {
  const AuthEventResentVerificationMail();
}

@immutable
class AuthEventCompletingUserProfile implements AuthEvent {
  final String displayName;
  final String? imagePath;

  const AuthEventCompletingUserProfile({
    required this.displayName,
    required this.imagePath,
  });
}

@immutable
class AuthEventAnnouncemmentFieldsCleaned implements AuthEvent {
  const AuthEventAnnouncemmentFieldsCleaned();
}

@immutable
class AuthEventOpenLegalTerms implements AuthEvent {
  final String documentID;
  const AuthEventOpenLegalTerms({required this.documentID});
}
