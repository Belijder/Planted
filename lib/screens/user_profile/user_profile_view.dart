import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:planted/blocs/app_bloc.dart/app_bloc.dart';
import 'package:planted/blocs/app_bloc.dart/app_event.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_bloc.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_event.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/models/user_profile.dart';
import 'package:planted/styles/text_styles.dart';

class UserProfileView extends HookWidget {
  const UserProfileView({
    required this.userProfileStream,
    super.key,
  });

  final Stream<DocumentSnapshot<Map<String, dynamic>>> userProfileStream;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Twoje konto',
          style: TextStyle(
              color: colorSepia, fontSize: 30.0, fontWeight: FontWeight.w800),
        ),
        backgroundColor: colorEggsheel,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: userProfileStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              context.read<AppBloc>().add(const AppEventLogOut());
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final userProfile = UserProfile.fromSnapshot(snapshot.data!);

            return Padding(
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
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        const UserProfileActionButton(
                          title: 'Twoje ogłoszenia',
                          event:
                              UserProfileScreenEventGoToUsersAnnouncementsView(),
                        ),
                        const SizedBox(height: 10),
                        const UserProfileActionButton(
                          title: 'Zablokowani użytkownicy',
                          event: UserProfileScreenEventGoToBlockedUsersView(),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shadowColor: colorSepia,
                              elevation: 3,
                              backgroundColor: colorRedKenyanCopper,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              context.read<AppBloc>().add(
                                    const AppEventLogOut(),
                                  );
                            },
                            child: const Text('Wyloguj się'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}

class UserProfileActionButton extends StatelessWidget {
  const UserProfileActionButton({
    required this.title,
    required this.event,
    super.key,
  });

  final String title;
  final UserProfileScreenEvent event;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          context.read<UserProfileScreenBloc>().add(event);
        },
        style: ElevatedButton.styleFrom(
          shadowColor: colorSepia,
          elevation: 3,
          backgroundColor: listTileBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
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
