import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_event.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_state.dart';
import 'package:planted/constants/firebase_paths.dart';
import 'package:planted/database_error.dart';

class UserProfileScreenBloc
    extends Bloc<UserProfileScreenEvent, UserProfileScreenState> {
  final db = FirebaseFirestore.instance;
  UserProfileScreenBloc()
      : super(
          const UserProfileScreenStateInUserProfileView(
            isLoading: false,
          ),
        ) {
    on<UserProfileScreenEventGoToUsersAnnouncementsView>(
      (event, emit) {
        emit(const UserProfileScreenStateInUsersAnnouncementsView(
            isLoading: false));
      },
    );

    on<UserProfileScreenEventGoToBlockedUsersView>(
      (event, emit) {
        emit(const UserProfileScreenStateInBlockedUsersView(isLoading: false));
      },
    );

    on<UserProfileScreenEventGoToUserProfileView>(
      (event, emit) {
        emit(const UserProfileScreenStateInUserProfileView(isLoading: false));
      },
    );

    on<UserProfileScreenEventArchiveAnnouncement>(
      (event, emit) async {
        emit(const UserProfileScreenStateInUsersAnnouncementsView(
            isLoading: true));

        try {
          final aggregateQuerySnapshot = await db
              .collection(conversationsPath)
              .where(
                Filter.or(
                  Filter('giver', isEqualTo: event.userID),
                  Filter('taker', isEqualTo: event.userID),
                ),
              )
              .where('announcementID', isEqualTo: event.documentID)
              .count()
              .get();

          if (aggregateQuerySnapshot.count > 0) {
            await db
                .collection(announcemensPath)
                .doc(event.documentID)
                .update({'status': 3});
          } else {
            await db
                .collection(announcemensPath)
                .doc(event.documentID)
                .delete();
            await FirebaseStorage.instance
                .ref('images')
                .child(event.documentID)
                .delete();
          }

          emit(
            UserProfileScreenStateInUsersAnnouncementsView(
                isLoading: false,
                snackbarMessage: aggregateQuerySnapshot.count == 0
                    ? 'Ogłoszenie zostało usunięte!'
                    : 'Ogłoszenie zostało zarchiwizowane!'),
          );
        } on FirebaseException catch (e) {
          emit(
            UserProfileScreenStateInUsersAnnouncementsView(
              isLoading: false,
              databaseError: DatabaseError.from(e),
            ),
          );
        }
      },
    );
    on<UserProfileScreenEventDeleteAnnouncement>((event, emit) async {
      emit(const UserProfileScreenStateInUsersAnnouncementsView(
          isLoading: true));

      try {
        await db.collection(announcemensPath).doc(event.documentID).delete();
        await FirebaseStorage.instance
            .ref('images')
            .child(event.documentID)
            .delete();

        emit(
          const UserProfileScreenStateInUsersAnnouncementsView(
            isLoading: false,
            snackbarMessage: 'Ogłoszenie zostało usunięte!',
          ),
        );
      } on FirebaseException catch (e) {
        emit(
          UserProfileScreenStateInUsersAnnouncementsView(
            isLoading: false,
            databaseError: DatabaseError.from(e),
          ),
        );
      }
    });
  }
}
