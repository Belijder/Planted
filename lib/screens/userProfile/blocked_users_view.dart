import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:planted/blocs/authBloc/auth_bloc.dart';
import 'package:planted/blocs/authBloc/auth_event.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_bloc.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_event.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/firebase_paths.dart';
import 'package:planted/constants/images.dart';
import 'package:planted/models/user_profile.dart';
import 'package:planted/screens/views/empty_state_view.dart';
import 'package:planted/styles/box_decoration_styles.dart';

class BlockedUsersView extends HookWidget {
  const BlockedUsersView({
    required this.userID,
    super.key,
  });

  final String userID;

  @override
  Widget build(BuildContext context) {
    final userProfileStream = useMemoized(() {
      return FirebaseFirestore.instance
          .collection(profilesPath)
          .doc(userID)
          .snapshots();
    }, [key]);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorEggsheel,
        leading: IconButton(
          onPressed: () {
            context
                .read<UserProfileScreenBloc>()
                .add(const UserProfileScreenEventGoToUserProfileView());
          },
          icon: const Icon(Icons.arrow_back),
          style: IconButton.styleFrom(
            shadowColor: colorSepia.withAlpha(50),
          ),
          color: colorSepia,
        ),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Zablokowani użytkownicy',
            style: TextStyle(
              color: colorSepia,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: userProfileStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              context.read<AuthBloc>().add(const AuthEventLogOut());
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final userProfile = UserProfile.fromSnapshot(snapshot.data!);

            if (userProfile.blockedUsers.isEmpty) {
              return const EmptyStateView(
                message: 'Nie masz żadnych zablokowanych użytkowników.',
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: userProfile.blockedUsers.length,
                  itemBuilder: (context, index) {
                    final blockedUserID =
                        userProfile.blockedUsers.elementAt(index);

                    return FutureBuilder<UserProfile>(
                      future: FirebaseFirestore.instance
                          .collection(profilesPath)
                          .doc(blockedUserID)
                          .get()
                          .then(
                              (snapshot) => UserProfile.fromSnapshot(snapshot)),
                      builder: (context, snapshot) {
                        final userProfile = snapshot.data;
                        if (userProfile != null) {
                          return Column(
                            children: [
                              Container(
                                height: 40,
                                decoration: backgroundBoxDecoration,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(width: 10),
                                        SizedBox(
                                          height: 26,
                                          width: 26,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(13),
                                            child: CachedNetworkImage(
                                              fadeInDuration: Duration.zero,
                                              fadeOutDuration: Duration.zero,
                                              placeholder: (context, url) =>
                                                  Image.asset(
                                                      personPlaceholder),
                                              imageUrl: userProfile.photoURL,
                                              errorWidget: (context, _, __) =>
                                                  Image.asset(
                                                      personPlaceholder),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          userProfile.displayName,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color: colorSepia, fontSize: 17),
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context
                                            .read<UserProfileScreenBloc>()
                                            .add(
                                                UserProfileScreenEventUnblockUser(
                                              currentUserID: userID,
                                              idToUnblock: userProfile.userID,
                                            ));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shadowColor: colorSepia,
                                        elevation: 3,
                                        backgroundColor: colorDarkMossGreen,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Text(
                                          'Odblokuj',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: listTileBackground,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
                    );
                  },
                ),
              );
            }
          }),
    );
  }
}
