import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:planted/blocs/authBloc/auth_bloc.dart';
import 'package:planted/blocs/authBloc/auth_event.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_bloc.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_event.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_state.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/firebase_paths.dart';
import 'package:planted/helpers/send_email_to_owner.dart';
import 'package:planted/models/user_profile.dart';
import 'package:planted/styles/buttons_styles.dart';
import 'package:planted/styles/text_styles.dart';
import 'package:planted/utilities/dialogs/show_dialog_with_text_field.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfileView extends HookWidget {
  const UserProfileView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final InAppReview inAppReview = InAppReview.instance;
    final userProfileStream =
        context.watch<UserProfileScreenBloc>().state.userProfileStream;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text(
              'Twoje konto',
              style: TextStyle(
                  color: colorSepia,
                  fontSize: 30.0,
                  fontWeight: FontWeight.w800),
            ),
          ],
        ),
        backgroundColor: colorEggsheel,
        automaticallyImplyLeading: false,
      ),
      body: BlocListener<UserProfileScreenBloc, UserProfileScreenState>(
        listener: (context, userProfileScreenState) {
          if (userProfileScreenState
              is UserProfileScreenStateInUserProfileView) {
            final path = userProfileScreenState.path;
            if (path != null) {
              final Uri legalTermsUrl = Uri(scheme: 'https', path: path);
              launchUrl(legalTermsUrl);
            }
            context
                .read<UserProfileScreenBloc>()
                .add(const UserProfileScreenEventGoToUserProfileView());
          }
        },
        child: StreamBuilder<UserProfile>(
            stream: userProfileStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                context.read<AuthBloc>().add(const AuthEventLogOut());
              }

              final userProfile = snapshot.data!;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: CachedNetworkImage(
                              imageUrl: userProfile.photoURL,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                              errorWidget: (context, _, __) =>
                                  Image.asset('assets/images/person.png'),
                              placeholder: (context, _) =>
                                  Image.asset('assets/images/person.png'),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: RichText(
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                text: 'Witaj, ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w300,
                                    color: colorDarkMossGreen,
                                    fontSize: 30),
                                children: [
                                  TextSpan(
                                      text: userProfile.displayName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: colorSepia)),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 30),
                      Column(
                        children: [
                          if (userProfile.isAdmin)
                            Column(
                              children: [
                                UserProfileActionButton(
                                    title: 'Panel Administratora',
                                    onPressed: () {
                                      context.read<UserProfileScreenBloc>().add(
                                          UserProfileScreenEventGoToAdministratorPanelView(
                                              initialTabBarIndex: 0,
                                              userProfile: userProfile));
                                    }),
                                const SizedBox(height: 20),
                              ],
                            ),
                          UserProfileActionButton(
                              title: 'Twoje ogłoszenia',
                              onPressed: () {
                                context.read<UserProfileScreenBloc>().add(
                                    const UserProfileScreenEventGoToUsersAnnouncementsView());
                              }),
                          const SizedBox(height: 20),
                          if (userProfile.blockedUsers.isNotEmpty)
                            Column(
                              children: [
                                UserProfileActionButton(
                                    title: 'Zablokowani użytkownicy',
                                    onPressed: () {
                                      context.read<UserProfileScreenBloc>().add(
                                          const UserProfileScreenEventGoToBlockedUsersView());
                                    }),
                                const SizedBox(height: 10),
                              ],
                            ),
                          if (userProfile.userReports.isNotEmpty)
                            Column(
                              children: [
                                UserProfileActionButton(
                                    title: 'Twoje zgłoszenia',
                                    onPressed: () {
                                      context.read<UserProfileScreenBloc>().add(
                                          UserProfileScreenEventGoToUserReportsView(
                                              userID: userProfile.userID));
                                    }),
                                const SizedBox(height: 10),
                              ],
                            ),
                          const SizedBox(height: 10),
                          UserProfileActionButton(
                              title: 'Oceń aplikację',
                              onPressed: () {
                                inAppReview.openStoreListing(
                                    appStoreId: 'com.jakubzajda.planted');
                              }),
                          const SizedBox(height: 10),
                          UserProfileActionButton(
                              title: 'Skontaktuj się z nami',
                              onPressed: () {
                                sendEmailToOwner();
                              }),
                          const SizedBox(height: 20),
                          UserProfileActionButton(
                            title: 'Polityka Prywatności',
                            onPressed: () {
                              context.read<UserProfileScreenBloc>().add(
                                    const UserProfileScreenEventOpenLegalTerms(
                                      documentID: privacyPolicyDoc,
                                    ),
                                  );
                            },
                          ),
                          const SizedBox(height: 10),
                          UserProfileActionButton(
                            title: 'Regulamin',
                            onPressed: () {
                              context.read<UserProfileScreenBloc>().add(
                                    const UserProfileScreenEventOpenLegalTerms(
                                      documentID: termsOfUseDoc,
                                    ),
                                  );
                            },
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<AuthBloc>().add(
                                      const AuthEventLogOut(),
                                    );
                              },
                              style: createFilledButtonStyle(
                                  backgroundColor: colorRedKenyanCopper),
                              child: const Text('Wyloguj się'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: colorRedKenyanCopper,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                showDialogWithTextField(
                                  context: context,
                                  title: 'Usuwanie konta',
                                  content:
                                      'Aby usunąć konto, musisz podać hasło ustalone podczas zakładania konta. Pamiętaj, że usunięcie konta wiąże się z zarchiwizowaniem wszystkich twoich ogłoszeń oraz konwersacji. Tej operacji nie będzie można cofnąć. Po usunięciu konta nie będziesz w stanie odzyskać dostępu do swoich konwersacji oraz ogłoszeń.',
                                  dialogType: ConfirmationDialogType.password,
                                ).then((password) {
                                  if (password != null && password.isNotEmpty) {
                                    context.read<AuthBloc>().add(
                                        AuthEventDeleteAccount(
                                            password: password));
                                  }
                                });
                              },
                              child: const Text('Usuń konto'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}

typedef OnPressed = void Function();

class UserProfileActionButton extends StatelessWidget {
  const UserProfileActionButton({
    required this.title,
    required this.onPressed,
    super.key,
  });

  final String title;
  final OnPressed onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          onPressed();
        },
        style: createFilledButtonStyle(backgroundColor: listTileBackground),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: textStyle15BoldSepia,
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: colorSepia,
            )
          ],
        ),
      ),
    );
  }
}
