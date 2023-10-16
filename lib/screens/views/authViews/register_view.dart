import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:planted/blocs/authBloc/auth_bloc.dart';
import 'package:planted/blocs/authBloc/auth_event.dart';
import 'package:planted/blocs/authBloc/auth_state.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/firebase_paths.dart';
import 'package:planted/constants/images.dart';
import 'package:planted/constants/strings.dart';
import 'package:planted/styles/create_input_decoration.dart';
import 'package:planted/styles/buttons_styles.dart';
import 'package:planted/styles/text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterView extends HookWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final areLegalTermsAccepted = useState(false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorEggsheel,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, appState) {
          if (appState is AuthStateIsInRegistrationView) {
            final path = appState.path;
            if (path != null) {
              final Uri legalTermsUrl = Uri(scheme: httpsScheme, path: path);
              launchUrl(legalTermsUrl);
            }
            context.read<AuthBloc>().add(const AuthEventGoToRegisterView());
          }
        },
        child: SingleChildScrollView(
          child: Padding(
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
                    Text(
                      CustomText.shareNature,
                      style: TextStyles.titleTextStyle(weight: FontWeight.w300),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          CustomText.creatingAccount,
                          style: TextStyles.headlineTextStyle(
                              weight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: emailController,
                      decoration: createInputDecoration(
                        label: CustomText.emailLabel,
                      ),
                      style: TextStyles.bodyTextStyle(weight: FontWeight.bold),
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
                      style: TextStyles.bodyTextStyle(weight: FontWeight.bold),
                      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      enableSuggestions: false,
                      obscureText: true,
                      obscuringCharacter: obscuringCharacter,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: confirmPasswordController,
                      decoration: createInputDecoration(
                        label: CustomText.confirmPasswordLabel,
                      ),
                      style: TextStyles.bodyTextStyle(weight: FontWeight.bold),
                      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      enableSuggestions: false,
                      obscureText: true,
                      obscuringCharacter: obscuringCharacter,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            areLegalTermsAccepted.value =
                                !areLegalTermsAccepted.value;
                          },
                          child: Icon(
                            areLegalTermsAccepted.value == true
                                ? Icons.check_box_outlined
                                : Icons.check_box_outline_blank_rounded,
                            color: areLegalTermsAccepted.value == true
                                ? colorDarkMossGreen
                                : colorSepia,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: RichText(
                              maxLines: 2,
                              text: TextSpan(
                                  text: LegalStatementText.readAndAccepted,
                                  style: TextStyles.calloutTextStyle(),
                                  children: [
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: () {
                                          context.read<AuthBloc>().add(
                                                  const AuthEventOpenLegalTerms(
                                                documentID: termsOfUseDoc,
                                              ));
                                        },
                                        child: Text(
                                          LegalStatementText.termsOfUse,
                                          style: TextStyles.calloutTextStyle(
                                            weight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const TextSpan(
                                      text: LegalStatementText.and,
                                    ),
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: () {
                                          context.read<AuthBloc>().add(
                                                  const AuthEventOpenLegalTerms(
                                                documentID: privacyPolicyDoc,
                                              ));
                                        },
                                        child: Text(
                                          LegalStatementText.policyPrivacy,
                                          style: TextStyles.calloutTextStyle(
                                            weight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: createFilledButtonStyle(
                            backgroundColor: colorDarkMossGreen),
                        onPressed: () {
                          context.read<AuthBloc>().add(
                                AuthEventRegister(
                                  email: emailController.text,
                                  password: passwordController.text,
                                  confirmPassword:
                                      confirmPasswordController.text,
                                  areLegalTermsAccepted:
                                      areLegalTermsAccepted.value,
                                ),
                              );
                        },
                        child: const Text(ButtonLabelText.register),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                              const AuthEventGoToLoginView(),
                            );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            CustomText.haveAccountQuestion,
                            style: TextStyles.bodyTextStyle(
                                color: colorDarkMossGreen),
                          ),
                          Text(
                            CustomText.logIn,
                            style: TextStyles.bodyTextStyle(
                                color: colorDarkMossGreen,
                                weight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
