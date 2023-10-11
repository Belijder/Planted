import 'package:flutter/material.dart';
import 'package:planted/blocs/database_error.dart';
import 'package:planted/utilities/dialogs/show_generic_dialog.dart';

Future<void> showDatabaseErrorDialog({
  required BuildContext context,
  required DatabaseError databaseError,
}) {
  return showGenericDialog<void>(
    context: context,
    title: databaseError.dialogTitle,
    content: databaseError.dialogText,
    optionBuilder: () => {
      'OK': true,
    },
  );
}
