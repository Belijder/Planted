import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:planted/blocs/authBloc/auth_bloc.dart';
import 'package:planted/blocs/authBloc/auth_event.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/images.dart';
import 'package:planted/constants/strings.dart';
import 'package:planted/styles/create_input_decoration.dart';
import 'package:planted/styles/buttons_styles.dart';
import 'package:planted/styles/text_styles.dart';
import 'package:planted/utilities/dialogs/show_dialog_with_text_field.dart';

class LoginView extends HookWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorEggsheel,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            Column(
              children: [
                const Row(
                  children: [
                    Text(
                      CustomText.loggingIn,
                      style: TextStyle(
                        color: colorSepia,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  decoration: createInputDecoration(
                    label: CustomText.emailLabel,
                  ),
                  style: textStyle15BoldSepia,
                  onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  enableSuggestions: false,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  decoration: createInputDecoration(
                    label: CustomText.passwordLabel,
                  ),
                  style: textStyle15BoldSepia,
                  onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  enableSuggestions: false,
                  obscureText: true,
                  obscuringCharacter: obscuringCharacter,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: filledButtonStyle,
                    onPressed: () {
                      context.read<AuthBloc>().add(
                            AuthEventLogIn(
                              email: emailController.text,
                              password: passwordController.text,
                            ),
                          );
                    },
                    child: const Text(ButtonLabelText.logIn),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthEventGoToRegisterView(),
                        );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        CustomText.dontHaveAccountQuestion,
                        style: TextStyle(
                          color: colorDarkMossGreen,
                        ),
                      ),
                      Text(
                        CustomText.register,
                        style: TextStyle(
                            color: colorDarkMossGreen,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CustomText.dontRememberPasswordQuestion,
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
                      showDialogWithTextField(
                        context: context,
                        title: DialogTitleText.passwordReseting,
                        content: DialogContentText.passwordReseting,
                        dialogType: ConfirmationDialogType.email,
                      ).then((email) {
                        if (email != null) {
                          context
                              .read<AuthBloc>()
                              .add(AuthEventSendResetPassword(email: email));
                        }
                      });
                    },
                    style: outlinedButtonStyle,
                    child: const Text(ButtonLabelText.resetPassword),
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
