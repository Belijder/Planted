import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:flutter/foundation.dart' show immutable;

const Map<String, DatabaseError> databaseErrorMapping = {
  'cancelled': DatabaseErrorCancelled(),
  'unknown': DatabaseErrorUnknown(),
  'permission-denied': DatabaseErrorPermissionDenied(),
  'aborted': DatabaseErrorAborted(),
};

@immutable
abstract class DatabaseError {
  final String dialogTitle;
  final String dialogText;

  const DatabaseError({
    required this.dialogTitle,
    required this.dialogText,
  });

  factory DatabaseError.from(FirebaseException exception) =>
      databaseErrorMapping[exception.code.toLowerCase().trim()] ??
      DatabaseErrorNonHandled(exception: exception);
}

@immutable
class DatabaseErrorNonHandled extends DatabaseError {
  final FirebaseException exception;
  DatabaseErrorNonHandled({required this.exception})
      : super(
          dialogTitle: 'Wystąpił błąd',
          dialogText: 'Kod błędu: ${exception.code}',
        );
}

@immutable
class DatabaseErrorCancelled extends DatabaseError {
  const DatabaseErrorCancelled()
      : super(
          dialogTitle: 'Operacja anulowana',
          dialogText: 'Operacja została przerwana. Spróbuj ponownie.',
        );
}

@immutable
class DatabaseErrorUnknown extends DatabaseError {
  const DatabaseErrorUnknown()
      : super(
          dialogTitle: 'Coś poszło nie tak :(',
          dialogText:
              'Wygląda na to że wystapił jakiś błąd. Sprawdz połączenie z internetem i spróbuj ponownie.',
        );
}

@immutable
class DatabaseErrorPermissionDenied extends DatabaseError {
  const DatabaseErrorPermissionDenied()
      : super(
          dialogTitle: 'Odmowa pozwolenia',
          dialogText:
              'Wygląda na to że nie masz pozwolenia na wykonanie tej operacji.',
        );
}

@immutable
class DatabaseErrorAborted extends DatabaseError {
  const DatabaseErrorAborted()
      : super(
          dialogTitle: 'Odmowa pozwolenia',
          dialogText:
              'Wygląda na to że nie masz pozwolenia na wykonanie tej operacji.',
        );
}
