import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/addScreenBloc/add_screen_event.dart';
import 'package:planted/blocs/addScreenBloc/add_screen_state.dart';
import 'package:planted/blocs/database_error.dart';
import 'package:planted/constants/strings.dart';
import 'package:planted/helpers/compress_image.dart';
import 'package:planted/managers/conectivity_manager.dart';
import 'package:planted/managers/firebase_database_manager.dart';

class AddScreenBloc extends Bloc<AddScreenEvent, AddScreenState> {
  final connectivityManager = ConnectivityManager();
  final databaseManager = FirebaseDatabaseManager();

  AddScreenBloc()
      : super(
          const AddScreenState(
            isLoading: false,
          ),
        ) {
    on<AddNewAnnouncementAddScreenEvent>(
      (event, emit) async {
        if (connectivityManager.status == ConnectivityResult.none) {
          emit(
            const AddScreenState(
                isLoading: false,
                databaseError: DatabaseErrorNetworkRequestFailed()),
          );
          return;
        }

        emit(const AddScreenState(isLoading: true));

        final file = File(event.imagePath);

        try {
          final compressedFile = await compressImage(file.path, 30);
          final File fileToPut;

          if (compressedFile != null) {
            fileToPut = File(compressedFile.path);
          } else {
            fileToPut = file;
          }

          await databaseManager.addAnnouncement(
            name: event.name,
            latinName: event.latinName,
            seedCount: event.seedCount,
            city: event.city,
            description: event.description,
            giverID: event.user.uid,
            imageFile: fileToPut,
          );

          emit(
            const AddScreenState(
                isLoading: false,
                shouldCleanFields: true,
                snackbarMessage: SnackbarMessageContent.announcementAdded),
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
