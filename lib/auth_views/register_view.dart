import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:planted/blocs/app_bloc.dart/app_bloc.dart';
import 'package:planted/blocs/app_bloc.dart/app_event.dart';
import 'package:planted/blocs/app_bloc.dart/app_state.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/firebase_paths.dart';
import 'package:planted/constants/images.dart';
import 'package:planted/helpers/create_input_decoration.dart';
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
      body: BlocListener<AppBloc, AppState>(
        listener: (context, appState) {
          if (appState is AppStateIsInRegistrationView) {
            final path = appState.path;
            if (path != null) {
              final Uri legalTermsUrl = Uri(scheme: 'https', path: path);
              launchUrl(legalTermsUrl);
            }
            context.read<AppBloc>().add(const AppEventGoToRegisterView());
          }
        },
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
                    child: Image.asset(plantedLogo),
                  ),
                  const Text(
                    'share nature',
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
                        'Zakładanie konta',
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
                    decoration: createInputDecoration(label: 'Email'),
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
                    decoration: createInputDecoration(label: 'Hasło'),
                    style: textStyle15BoldSepia,
                    onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    enableSuggestions: false,
                    obscureText: true,
                    obscuringCharacter: '⦿',
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: createInputDecoration(label: 'Potwierdź hasło'),
                    style: textStyle15BoldSepia,
                    onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    enableSuggestions: false,
                    obscureText: true,
                    obscuringCharacter: '⦿',
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
                                text: 'Zapoznałem się i akceptuję ',
                                style: const TextStyle(
                                    fontSize: 12, color: colorSepia),
                                children: [
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () {
                                        context
                                            .read<AppBloc>()
                                            .add(const AppEventOpenLegalTerms(
                                              documentID: termsOfUseDoc,
                                            ));
                                      },
                                      child: const Text(
                                        'regulamin',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colorSepia,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const TextSpan(text: ' oraz '),
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () {
                                        context
                                            .read<AppBloc>()
                                            .add(const AppEventOpenLegalTerms(
                                              documentID: privacyPolicyDoc,
                                            ));
                                      },
                                      child: const Text(
                                        'poliitykę prywatności.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colorSepia,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
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
                        context.read<AppBloc>().add(
                              AppEventRegister(
                                email: emailController.text,
                                password: passwordController.text,
                                confirmPassword: confirmPasswordController.text,
                                areLegalTermsAccepted:
                                    areLegalTermsAccepted.value,
                              ),
                            );
                      },
                      child: const Text('Zarejestruj się'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      context.read<AppBloc>().add(
                            const AppEventGoToLoginView(),
                          );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Masz już konto? ',
                          style: TextStyle(
                            color: colorDarkMossGreen,
                          ),
                        ),
                        Text(
                          'Zaloguj się!',
                          style: TextStyle(
                              color: colorDarkMossGreen,
                              fontWeight: FontWeight.bold),
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
    );
  }
}
