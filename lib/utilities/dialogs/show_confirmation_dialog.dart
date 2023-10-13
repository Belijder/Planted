import 'package:flutter/material.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/strings.dart';
import 'package:planted/styles/buttons_styles.dart';

Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        actionsAlignment: MainAxisAlignment.center,
        titleTextStyle: const TextStyle(
          color: colorSepia,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        contentTextStyle: const TextStyle(
          color: colorSepia,
          fontSize: 14,
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
        ),
        content: Text(
          content,
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: filledButtonStyle,
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                ButtonLabelText.confirm,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: outlinedButtonStyle,
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                ButtonLabelText.cancel,
              ),
            ),
          ),
        ],
      );
    },
  );
}
