import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/authBloc/auth_bloc.dart';
import 'package:planted/blocs/authBloc/auth_event.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/images.dart';
import 'package:planted/constants/strings.dart';
import 'package:planted/styles/buttons_styles.dart';
import 'package:planted/styles/text_styles.dart';

class ConfrimEmailView extends StatelessWidget {
  const ConfrimEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorEggsheel,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 40,
                      child: Image.asset(ImageName.plantedLogo),
                    ),
                    const Text(
                      CustomText.shareNature,
                      style: TextStyle(
                          color: colorSepia,
                          fontWeight: FontWeight.w300,
                          fontSize: 18),
                    )
                  ],
                ),
                const SizedBox(height: 30),
                const Text(CustomText.confirmEmail, style: titleTextStyle),
                const SizedBox(height: 20),
                const Text(
                  CustomText.confirmEmailSentence1,
                  style: TextStyle(
                    color: colorSepia,
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  CustomText.confirmEmailSentence2,
                  style: TextStyle(
                    color: colorSepia,
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CustomText.isConfirmed,
                      style: TextStyle(
                        color: colorSepia.withAlpha(100),
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.read<AuthBloc>().add(const AuthEventLogOut());
                        },
                        style: outlinedButtonStyle,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text(ButtonLabelText.logIn),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CustomText.linkDidntRecivedQuestion,
                  style: TextStyle(
                    color: colorSepia.withAlpha(100),
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      context
                          .read<AuthBloc>()
                          .add(const AuthEventResentVerificationMail());
                    },
                    style: outlinedButtonStyle,
                    child: const Text(ButtonLabelText.resendLink),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
