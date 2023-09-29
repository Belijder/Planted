import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_bloc.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_event.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/firebase_paths.dart';
import 'package:planted/models/announcement.dart';
import 'package:planted/models/user_profile.dart';
import 'package:planted/screens/browse/announcements_list_tile.dart';

class AnnouncementListView extends HookWidget {
  const AnnouncementListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final userID = FirebaseAuth.instance.currentUser?.uid;
    final userProfileStream = useMemoized(() {
      return FirebaseFirestore.instance
          .collection(profilesPath)
          .doc(userID)
          .snapshots();
    }, [key]);

    final announcementsStream = useMemoized(() {
      return FirebaseFirestore.instance
          .collection(announcemensPath)
          .where('status', isEqualTo: 1)
          .orderBy('timeStamp', descending: true)
          .snapshots();
    }, [key]);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text(
              'Przeglądaj',
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
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: userProfileStream,
          builder: (context, snapshot) {
            final List<String> blockedUsers;
            UserProfile? userProfile;
            try {
              userProfile = UserProfile.fromSnapshot(snapshot.data!);
            } catch (_) {
              userProfile = null;
            }
            blockedUsers = userProfile?.blockedUsers ?? [];

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: announcementsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text(
                      'Nie udało się pobrać ogłoszeń. Sprawdz połączenie z internetem i spróbuj ponownie za chwilę.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorSepia, fontSize: 10),
                    ));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final announcements = snapshot.data!.docs
                      .map((doc) => Announcement.fromSnapshot(doc));

                  final filteredAnnouncements = announcements.where(
                      (element) => !blockedUsers.contains(element.giverID));

                  if (filteredAnnouncements.isEmpty) {
                    return Center(
                      child: Text(
                        'Nie ma żadnych dostępnych ogłoszeń. Sprawdź ponownie za jakiś czas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colorSepia.withAlpha(150),
                          fontSize: 15,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: filteredAnnouncements.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          context.read<BrowseScreenBloc>().add(
                                GoToDetailViewBrowseScreenEvent(
                                  announcement:
                                      filteredAnnouncements.elementAt(index),
                                ),
                              );
                        },
                        child: AnnouncementListTile(
                            announcement:
                                filteredAnnouncements.elementAt(index)),
                      );
                    },
                  );
                });
          },
        ),
      ),
    );
  }
}
