import 'package:flutter/material.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/helpers/create_input_decoration.dart';
import 'package:planted/styles/buttons_styles.dart';
import 'package:planted/styles/text_styles.dart';

Future<String?> showDialogWithTextField({
  required BuildContext context,
  required String title,
  required String content,
}) {
  final emailController = TextEditingController();
  return showDialog<String>(
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              content,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: emailController,
              decoration: createInputDecoration(label: 'Email'),
              style: formTextStyle,
              onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: false,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: filledButtonStyle,
              onPressed: () {
                Navigator.of(context).pop(emailController.text);
              },
              child: const Text(
                'Potwierdź',
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: outlinedButtonStyle,
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Anuluj',
              ),
            ),
          ),
        ],
      );
    },
  );
}
