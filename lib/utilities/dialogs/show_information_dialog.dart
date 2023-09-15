import 'package:flutter/material.dart';
import 'package:planted/utilities/dialogs/show_generic_dialog.dart';

Future<void> showInformationDialog({
  required BuildContext context,
  required String title,
  required String content,
}) {
  return showGenericDialog<void>(
    context: context,
    title: title,
    content: content,
    optionBuilder: () => {
      'OK': true,
    },
  );
}
