import 'package:flutter/foundation.dart' show immutable;
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;

const Map<String, AuthError> authErrorMapping = {
  'user-not-found': AuthErrorUserNotFound(),
  'weak-password': AuthErrorWeakPassword(),
  'invalid-email': AuthErrorInvalidEmail(),
  'operation-not-allowed': AuthErrorOperationNotAllowed(),
  'email-already-in-use': AuthErrorEmailAlreadyInUse(),
  'requires-recent-login': AuthErrorEmailAlreadyInUse(),
  'no-current-user': AuthErrorNoCurrentUser(),
  'too-many-requests': AuthErrorTooManyRequests(),
  'wrong-password': AuthErrorWrongPassword(),
};

@immutable
abstract class AuthError {
  final String dialogTitle;
  final String dialogText;

  const AuthError({
    required this.dialogTitle,
    required this.dialogText,
  });

  factory AuthError.from(FirebaseAuthException exception) =>
      authErrorMapping[exception.code.toLowerCase().trim()] ??
      AuthErrorUnknown(exception: exception);
}

@immutable
class AuthErrorUnknown extends AuthError {
  final FirebaseAuthException exception;
  AuthErrorUnknown({
    required this.exception,
  }) : super(
          dialogTitle: 'Błąd uwierzytelnienia',
          dialogText:
              'Nieznany błąd uwierzytelniania. Kod błędu: ${exception.code}',
        );
}

// auth/no-current-user
@immutable
class AuthErrorNoCurrentUser extends AuthError {
  const AuthErrorNoCurrentUser()
      : super(
          dialogTitle: 'Brak bieżącego użytkownika!',
          dialogText:
              'Nie znaleziono żadnego bieżącego użytkownika posiadającego te informacje!',
        );
}

// auth/requires-recent-login
@immutable
class AuthErrorRequiresRecentLogin extends AuthError {
  const AuthErrorRequiresRecentLogin()
      : super(
          dialogTitle: 'Wymagane odnowienie logowania',
          dialogText:
              'Aby wykonać tę operację, musisz się wylogować i zalogować ponownie.',
        );
}

// auth/operation-not-allowed
@immutable
class AuthErrorOperationNotAllowed extends AuthError {
  const AuthErrorOperationNotAllowed()
      : super(
          dialogTitle: 'Operacja niedozwolona',
          dialogText: 'W tej chwili nie możesz zarejestrować się tą metodą!',
        );
}

// auth/user-not-found
@immutable
class AuthErrorUserNotFound extends AuthError {
  const AuthErrorUserNotFound()
      : super(
          dialogTitle: 'Użytkownik nieznaleziony',
          dialogText:
              'Podanego użytkownika nie znaleziono na serwerze! Upewnij się, że podałeś dobry email, lub spróbuj się zarejestrować.',
        );
}

// auth/week-password
@immutable
class AuthErrorWeakPassword extends AuthError {
  const AuthErrorWeakPassword()
      : super(
          dialogTitle: 'Hasło zbyt słabe',
          dialogText:
              'Wybierz silniejsze hasło składające się z większej liczby znaków!',
        );
}

// auth/invalid-email
@immutable
class AuthErrorInvalidEmail extends AuthError {
  const AuthErrorInvalidEmail()
      : super(
          dialogTitle: 'Niepoprawny email',
          dialogText:
              'Sprawdź dokładnie podany przez Ciebie adres email i spróbuj ponownie.',
        );
}

// auth/email-already-in-use
@immutable
class AuthErrorEmailAlreadyInUse extends AuthError {
  const AuthErrorEmailAlreadyInUse()
      : super(
          dialogTitle: 'Email jest już w użyciu',
          dialogText:
              'Wybierz inny adres e-mail, na który chcesz się zarejestrować, lub spróbuj się zalogować.',
        );
}

// auth/too-many-requests
@immutable
class AuthErrorTooManyRequests extends AuthError {
  const AuthErrorTooManyRequests()
      : super(
          dialogTitle: 'Zbyt wiele prób',
          dialogText:
              'Wygląda na to, że próbowałem wykonać tę czynność zbyt wiele razy. Poczekaj chwilę, zanim spróbujesz ponownie.',
        );
}

@immutable
class AuthErrorPasswordAreNotIdentical extends AuthError {
  const AuthErrorPasswordAreNotIdentical()
      : super(
          dialogTitle: 'Hasła nie są identyczne',
          dialogText:
              'Upewnij się, że wpisane przez ciebie hasłą są identyczne i spróbuj ponownie.',
        );
}

@immutable
class AuthErrorWrongPassword extends AuthError {
  const AuthErrorWrongPassword()
      : super(
          dialogTitle: 'Złe hasło',
          dialogText:
              'Podane przez Ciebie hasło jest nieprawidłowe. Wpisz prawidłowe hasło i spróbuj ponownie.',
        );
}

@immutable
class AuthErrorFieldsAreEmpty extends AuthError {
  const AuthErrorFieldsAreEmpty()
      : super(
          dialogTitle: 'Znaleziono puste pola',
          dialogText:
              'Aby móc wykonać tę akcję musisz wypełnić wszystkie pola formularza.',
        );
}

@immutable
class AuthErrorLegalTermsNotAccepted extends AuthError {
  const AuthErrorLegalTermsNotAccepted()
      : super(
          dialogTitle: 'Nie zaakceptowano warunków prawnych',
          dialogText:
              'Aby móc się zarejestrować musisz zaznaczyć, że zapoznałeś się i zaakceptowałeś regulamin oraz politykę prywatności.',
        );
}
