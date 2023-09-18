import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:planted/constants/colors.dart';
import 'package:planted/models/announcement.dart';
import 'package:planted/screens/browse/announcement_list_tile.dart';

class BrowseScreen extends HookWidget {
  const BrowseScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final announcementsStream = useMemoized(() {
      return FirebaseFirestore.instance
          .collection('announcements')
          .orderBy('timeStamp', descending: true)
          .snapshots();
    }, []);

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
                  return AnnouncementListTile(
                      announcement: announcements.elementAt(index));
                },
              );
            }),
      ),
    );
  }
}
