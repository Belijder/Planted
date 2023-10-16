import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_bloc.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_event.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/enums.dart';
import 'package:planted/constants/strings.dart';
import 'package:planted/models/announcement.dart';
import 'package:planted/screens/browse/announcements_list_tile.dart';
import 'package:planted/screens/views/empty_state_view.dart';
import 'package:planted/styles/box_decoration_styles.dart';
import 'package:planted/styles/buttons_styles.dart';

class AnnounementsTabBarView extends HookWidget {
  const AnnounementsTabBarView({super.key});

  @override
  Widget build(BuildContext context) {
    final announcementsStream =
        context.watch<UserProfileScreenBloc>().state.announcementsStream;

    return StreamBuilder<List<Announcement>>(
      stream: announcementsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError || snapshot.data == null) {
          return const EmptyStateView(
            message: StreamMessageText.announcementsError,
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final announcements = snapshot.data!;

        if (announcements.isEmpty) {
          return const EmptyStateView(
              message: StreamMessageText.noAnnouncementsToAccept);
        }

        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements.elementAt(index);
              return Column(
                children: [
                  AnnouncementListTile(announcement: announcement),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Container(
                      decoration: backgroundBoxDecoration,
                      height: 36,
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 36,
                              child: TextButton(
                                  onPressed: () {
                                    context.read<UserProfileScreenBloc>().add(
                                          UserProfileScreenEventChangeStatusOfAnnouncement(
                                            announcementID: announcement.docID,
                                            action:
                                                AdminAnnouncementAction.accept,
                                          ),
                                        );
                                  },
                                  style: createFilledButtonStyle(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      bottomLeft: Radius.circular(20),
                                    ),
                                  ),
                                  child: const Text(ButtonLabelText.accept)),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: TextButton(
                                  onPressed: () {
                                    context.read<UserProfileScreenBloc>().add(
                                          UserProfileScreenEventChangeStatusOfAnnouncement(
                                            announcementID: announcement.docID,
                                            action:
                                                AdminAnnouncementAction.reject,
                                          ),
                                        );
                                  },
                                  style: createFilledButtonStyle(
                                    backgroundColor: colorRedKenyanCopper,
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: const Text(ButtonLabelText.reject)),
                            ),
                          ),
                        ],
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
      },
    );
  }
}
