import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/addScreenBloc/add_screen_event.dart';
import 'package:planted/blocs/addScreenBloc/add_screen_state.dart';
import 'package:planted/database_error.dart';
import 'package:planted/helpers/compress_image.dart';
import 'package:uuid/uuid.dart';

class AddScreenBloc extends Bloc<AddScreenEvent, AddScreenState> {
  AddScreenBloc()
      : super(
          const AddScreenState(
            isLoading: false,
          ),
        ) {
    on<AddNewAnnouncementAddScreenEvent>(
      (event, emit) async {
        emit(const AddScreenState(isLoading: true));
        final user = event.user;
        final announcementId = const Uuid().v4();
        final timeStamp = DateTime.timestamp();
        final file = File(event.imagePath);

        try {
          final compressedFile = await compressImage(file.path, 30);
          final File fileToPut;

          if (compressedFile != null) {
            fileToPut = File(compressedFile.path);
          } else {
            fileToPut = file;
          }

          final task = await FirebaseStorage.instance
              .ref('images')
              .child(announcementId)
              .putFile(fileToPut);

          final imageURL = await task.ref.getDownloadURL();

          final db = FirebaseFirestore.instance;

          final currentUserInfo = await db
              .collection('profiles')
              .doc(user.uid)
              .get()
              .then((snapshot) => snapshot.data());

          final docData = {
            'docID': announcementId,
            'name': event.name,
            'latinName': event.latinName,
            'seedCount': event.seedCount,
            'city': event.city,
            'description': event.description,
            'timeStamp': timeStamp,
            'giverID': user.uid,
            'imageURL': imageURL,
            'giverDisplayName': currentUserInfo!['displayName'] ?? 'Unknown',
            'giverPhotoURL': currentUserInfo['photoURL'] ?? '',
            'isActiv': true,
          };

          await db.collection('announcements').doc(announcementId).set(docData);

          emit(
            const AddScreenState(
                isLoading: false,
                shouldCleanFields: true,
                snackbarMessage: 'Ogłoszenie zostało dodane!'),
          );
        } on FirebaseException catch (e) {
          emit(
            AddScreenState(
              isLoading: false,
              databaseError: DatabaseError.from(e),
            ),
          );
        }
      },
    );
  }
}
