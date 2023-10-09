import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_bloc.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_event.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/firebase_paths.dart';
import 'package:planted/helpers/get_status_text_from_status.dart';
import 'package:planted/models/announcement.dart';
import 'package:planted/screens/browse/announcements_list_tile.dart';
import 'package:planted/screens/views/empty_state_view.dart';
import 'package:planted/styles/box_decoration_styles.dart';
import 'package:planted/utilities/dialogs/show_confirmation_dialog.dart';

class UsersAnnouncementsView extends HookWidget {
  const UsersAnnouncementsView({required this.userID, super.key});

  final String userID;

  @override
  Widget build(BuildContext context) {
    final announcementsStream = useMemoized(() {
      return FirebaseFirestore.instance
          .collection(announcemensPath)
          .where('giverID', isEqualTo: userID)
          .orderBy('timeStamp', descending: true)
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
            'Twoje ogłoszenia',
            style: TextStyle(
              color: colorSepia,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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

          final announcements =
              snapshot.data!.docs.map((doc) => Announcement.fromSnapshot(doc));

          if (announcements.isEmpty) {
            return const EmptyStateView(
                message: 'Nie dodałeś jeszcze żadnych ogłoszeń.');
          } else {
            return ListOfUsersAnnoucements(
                announcements: announcements, userID: userID);
          }
        },
      ),
    );
  }
}

class ListOfUsersAnnoucements extends StatelessWidget {
  const ListOfUsersAnnoucements({
    super.key,
    required this.announcements,
    required this.userID,
  });

  final Iterable<Announcement> announcements;
  final String userID;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListView.builder(
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          final announcement = announcements.elementAt(index);

          return Column(
            children: [
              Stack(
                children: [
                  AnnouncementListTile(announcement: announcement),
                  if (announcement.status != 1)
                    AnnouncementListTileOverlay(
                        announcementStatus: announcement.status),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                  decoration: backgroundBoxDecoration,
                  height: 36,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        getStatusTextFrom(announcement.status),
                        if (announcement.status != 3)
                          TextButton(
                            onPressed: () {
                              showConfirmationDialog(
                                      context: context,
                                      title: 'Jesteś pewien?',
                                      content:
                                          'Tej operacji nie będzie można cofnąć.')
                                  .then((value) {
                                if (value != null) {
                                  if (announcement.status == 0 ||
                                      announcement.status == 2) {
                                    context.read<UserProfileScreenBloc>().add(
                                          UserProfileScreenEventDeleteAnnouncement(
                                              documentID: announcement.docID),
                                        );
                                  } else if (announcement.status == 1) {
                                    context.read<UserProfileScreenBloc>().add(
                                          UserProfileScreenEventArchiveAnnouncement(
                                            documentID: announcement.docID,
                                            userID: userID,
                                          ),
                                        );
                                  }
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              shadowColor: colorSepia,
                              elevation: 3,
                              backgroundColor: colorRedKenyanCopper,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'Usuń',
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
                ),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          );
        },
      ),
    );
  }
}

class AnnouncementListTileOverlay extends StatelessWidget {
  const AnnouncementListTileOverlay({
    required this.announcementStatus,
    super.key,
  });

  final int announcementStatus;

  IconData? get _icon {
    switch (announcementStatus) {
      case 0:
        return Icons.remove_red_eye_rounded;
      case 2:
        return Icons.highlight_remove_rounded;
      case 3:
        return null;
      default:
        return Icons.remove_red_eye_rounded;
    }
  }

  Color? get _color {
    switch (announcementStatus) {
      case 0:
        return colorSepia.withOpacity(0.35);
      case 2:
        return colorRedKenyanCopper.withOpacity(0.35);
      case 3:
        return colorEggsheel.withOpacity(0.5);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: _color,
          ),
          // Overlay color and opacity
          child: Center(
              child: Icon(
            _icon,
            size: 50,
            color: Colors.white.withOpacity(0.70),
          )),
        ),
      ),
    );
  }
}
