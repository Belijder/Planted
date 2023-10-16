import 'package:flutter/material.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/styles/buttons_styles.dart';
import 'package:planted/styles/text_styles.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionBuilder,
}) {
  final options = optionBuilder();
  return showDialog<T?>(
    context: context,
    builder: (context) {
      return AlertDialog(
        actionsAlignment: MainAxisAlignment.center,
        titleTextStyle: TextStyles.titleTextStyle(weight: FontWeight.bold),
        contentTextStyle: TextStyles.bodyTextStyle(),
        title: Text(
          title,
          textAlign: TextAlign.center,
        ),
        content: Text(
          content,
          textAlign: TextAlign.center,
        ),
        actions: options.keys.map((optionTitle) {
          final value = options[optionTitle];
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: filledButtonStyle,
              onPressed: () {
                if (value != null) {
                  Navigator.of(context).pop(value);
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                optionTitle,
              ),
            ),
          );
        }).toList(),
      );
    },
  );
}
