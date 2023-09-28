import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:planted/blocs/app_bloc.dart/app_bloc.dart';
import 'package:planted/blocs/app_bloc.dart/app_event.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_bloc.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_event.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/firebase_paths.dart';
import 'package:planted/models/user_profile.dart';
import 'package:planted/screens/views/empty_state_view.dart';

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
        title: const Text(
          'Zablokowani użytkownicy',
          style: TextStyle(
            color: colorSepia,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: userProfileStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              context.read<AppBloc>().add(const AppEventLogOut());
            }
            // if (snapshot.connectionState == ConnectionState.waiting) {
            //   return const Center(child: CircularProgressIndicator());
            // }

            final userProfile = UserProfile.fromSnapshot(snapshot.data!);

            if (userProfile.blockedUsers.isEmpty) {
              return const EmptyStateView(
                message: 'Nie masz żadnych zablokowanych użytkowników.',
              );
            } else {
              return ListView.builder(
                itemCount: userProfile.blockedUsers.length,
                itemBuilder: (context, index) {
                  final blockedUserID =
                      userProfile.blockedUsers.elementAt(index);

                  return Text(blockedUserID);
                },
              );
            }
          }),
    );
  }
}
