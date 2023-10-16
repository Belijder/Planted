import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_bloc.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_event.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/images.dart';
import 'package:planted/constants/strings.dart';
import 'package:planted/models/user_profile.dart';
import 'package:planted/screens/views/empty_state_view.dart';
import 'package:planted/styles/box_decoration_styles.dart';
import 'package:planted/styles/text_styles.dart';

class BlockedUsersView extends HookWidget {
  const BlockedUsersView({
    required this.userID,
    super.key,
  });

  final String userID;

  @override
  Widget build(BuildContext context) {
    final blockedUsersStream =
        context.watch<UserProfileScreenBloc>().state.blockedUsersStream;

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
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            AppBarTitleText.blockedUsers,
            style: TextStyles.titleTextStyle(weight: FontWeight.bold),
          ),
        ),
      ),
      body: StreamBuilder<List<UserProfile>>(
          stream: blockedUsersStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const EmptyStateView(
                message: StreamMessageText.blockedUsersError,
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final blockedUsersProfiles = snapshot.data!;

            if (blockedUsersProfiles.isEmpty) {
              return const EmptyStateView(
                message: StreamMessageText.blocedUsersEmpty,
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: blockedUsersProfiles.length,
                  itemBuilder: (context, index) {
                    final userProfile = blockedUsersProfiles.elementAt(index);
                    return Column(
                      children: [
                        Container(
                          height: 40,
                          decoration: backgroundBoxDecoration,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    height: 26,
                                    width: 26,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(13),
                                      child: CachedNetworkImage(
                                        fadeInDuration: Duration.zero,
                                        fadeOutDuration: Duration.zero,
                                        placeholder: (context, url) =>
                                            Image.asset(
                                                ImageName.personPlaceholder),
                                        imageUrl: userProfile.photoURL,
                                        errorWidget: (context, _, __) =>
                                            Image.asset(
                                                ImageName.personPlaceholder),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    userProfile.displayName,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyles.headlineTextStyle(),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<UserProfileScreenBloc>().add(
                                        UserProfileScreenEventUnblockUser(
                                          currentUserID: userID,
                                          idToUnblock: userProfile.userID,
                                        ),
                                      );
                                },
                                style: ElevatedButton.styleFrom(
                                  shadowColor: colorSepia,
                                  elevation: 3,
                                  backgroundColor: colorDarkMossGreen,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Text(
                                    ButtonLabelText.unblock,
                                    style: TextStyles.captionTextStyle(
                                      weight: FontWeight.bold,
                                      color: listTileBackground,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    );
                  },
                ),
              );
            }
          }),
    );
  }
}
