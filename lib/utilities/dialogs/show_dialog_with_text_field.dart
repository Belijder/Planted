import 'package:flutter/material.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/strings.dart';
import 'package:planted/styles/create_input_decoration.dart';
import 'package:planted/styles/buttons_styles.dart';
import 'package:planted/styles/text_styles.dart';

enum ConfirmationDialogType { email, password }

Future<String?> showDialogWithTextField({
  required BuildContext context,
  required String title,
  required String content,
  required ConfirmationDialogType dialogType,
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
              decoration: createInputDecoration(
                label: dialogType == ConfirmationDialogType.email
                    ? CustomText.emailLabel
                    : CustomText.passwordLabel,
              ),
              style: textStyle15BoldSepia,
              onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              keyboardType: dialogType == ConfirmationDialogType.email
                  ? TextInputType.emailAddress
                  : TextInputType.text,
              autocorrect: false,
              enableSuggestions: false,
              obscureText:
                  dialogType == ConfirmationDialogType.email ? false : true,
              obscuringCharacter: obscuringCharacter,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: createFilledButtonStyle(
                  backgroundColor: colorRedKenyanCopper),
              onPressed: () {
                Navigator.of(context).pop(emailController.text);
              },
              child: const Text(
                ButtonLabelText.confirm,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: createOutlinedButtonStyle(
                foregroundColor: colorSepia,
                borderColor: colorSepia,
              ),
              onPressed: () {
                Navigator.of(context).pop();
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
