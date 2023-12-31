import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_bloc.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_event.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/strings.dart';
import 'package:planted/models/announcement.dart';
import 'package:planted/models/user_profile.dart';
import 'package:planted/screens/browse/announcements_list_tile.dart';
import 'package:planted/screens/views/empty_state_view.dart';
import 'package:planted/styles/text_styles.dart';

class AnnouncementListView extends HookWidget {
  const AnnouncementListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final userProfileStream =
        context.watch<BrowseScreenBloc>().state.userProfileStream;
    final announcementsStream =
        context.watch<BrowseScreenBloc>().state.announcementsStream;

    final initialOffset =
        context.read<BrowseScreenBloc>().state.scrollViewOffset;
    final scrollViewController =
        useScrollController(initialScrollOffset: initialOffset);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              AppBarTitleText.browse,
              style: TextStyles.largeTitleTextStyle(weight: FontWeight.w800),
            ),
          ],
        ),
        backgroundColor: colorEggsheel,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: StreamBuilder<UserProfile>(
          stream: userProfileStream,
          builder: (context, snapshot) {
            final List<String> blockedUsers;
            UserProfile? userProfile = snapshot.data;
            blockedUsers = userProfile?.blockedUsers ?? [];

            return StreamBuilder<List<Announcement>>(
              stream: announcementsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError || snapshot.data == null) {
                  return const EmptyStateView(
                    message: StreamMessageText.announcementsError,
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final announcements = snapshot.data!;
                final filteredAnnouncements = announcements.where(
                    (element) => !blockedUsers.contains(element.giverID));

                if (filteredAnnouncements.isEmpty) {
                  return const EmptyStateView(
                    message: StreamMessageText.announcementsError,
                  );
                }
                return ListView.builder(
                  controller: scrollViewController,
                  itemCount: filteredAnnouncements.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        context.read<BrowseScreenBloc>().add(
                              BrowseScreenEventGoToDetailView(
                                scrollViewOffset: scrollViewController.offset,
                                announcement:
                                    filteredAnnouncements.elementAt(index),
                              ),
                            );
                      },
                      child: AnnouncementListTile(
                          announcement: filteredAnnouncements.elementAt(index)),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
