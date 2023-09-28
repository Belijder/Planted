import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AppEvent {
  const AppEvent();
}

@immutable
class AppEventInitialize implements AppEvent {
  const AppEventInitialize();
}

@immutable
class AppEventGoToRegisterView implements AppEvent {
  const AppEventGoToRegisterView();
}

@immutable
class AppEventGoToLoginView implements AppEvent {
  const AppEventGoToLoginView();
}

@immutable
class AppEventGoToCompleteProfileView implements AppEvent {
  const AppEventGoToCompleteProfileView();
}

@immutable
class AppEventSendResetPassword implements AppEvent {
  final String email;

  const AppEventSendResetPassword({
    required this.email,
  });
}

@immutable
class AppEventRegister implements AppEvent {
  final String email;
  final String password;
  final String confirmPassword;

  const AppEventRegister({
    required this.email,
    required this.password,
    required this.confirmPassword,
  });
}

@immutable
class AppEventLogIn implements AppEvent {
  final String email;
  final String password;

  const AppEventLogIn({
    required this.email,
    required this.password,
  });
}

@immutable
class AppEventLogOut implements AppEvent {
  const AppEventLogOut();
}

@immutable
class AppEventDeleteAccount implements AppEvent {
  const AppEventDeleteAccount();
}

@immutable
class AppEventResentVerificationMail implements AppEvent {
  const AppEventResentVerificationMail();
}

@immutable
class AppEventCompletingUserProfile implements AppEvent {
  final String displayName;
  final String? imagePath;

  const AppEventCompletingUserProfile({
    required this.displayName,
    required this.imagePath,
  });
}

@immutable
class AppEventReloadUserInfo implements AppEvent {
  const AppEventReloadUserInfo();
}

@immutable
class AppEventAnnouncemmentFieldsCleaned implements AppEvent {
  const AppEventAnnouncemmentFieldsCleaned();
}
