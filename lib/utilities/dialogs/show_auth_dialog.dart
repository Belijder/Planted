import 'package:flutter/material.dart';
import 'package:planted/auth_error.dart';
import 'package:planted/utilities/dialogs/show_generic_dialog.dart';

Future<void> showAuthError({
  required BuildContext context,
  required AuthError authError,
}) {
  return showGenericDialog<void>(
    context: context,
    title: authError.dialogTitle,
    content: authError.dialogText,
    optionBuilder: () => {
      'OK': true,
    },
  );
}
