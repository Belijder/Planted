import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:planted/blocs/browseBloc/browse_screen_bloc.dart';
import 'package:planted/blocs/browseBloc/browse_screen_event.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/constants/firebase_paths.dart';
import 'package:planted/models/announcement.dart';
import 'package:planted/screens/browse/announcements_list_tile.dart';

class AnnouncementListView extends HookWidget {
  const AnnouncementListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final announcementsStream = useMemoized(() {
      return FirebaseFirestore.instance
          .collection(announcemensPath)
          .where('isActiv', isEqualTo: true)
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
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: announcementsStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print('🔵 ${snapshot.error}');
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
              return ListView.builder(
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      context.read<BrowseScreenBloc>().add(
                            GoToDetailViewBrowseScreenEvent(
                              announcement: announcements.elementAt(index),
                            ),
                          );
                    },
                    child: AnnouncementListTile(
                        announcement: announcements.elementAt(index)),
                  );
                },
              );
            }),
      ),
    );
  }
}
