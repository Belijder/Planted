import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_event.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_state.dart';
import 'package:planted/database_error.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:planted/enums/admin_announcement_action.dart';
import 'package:planted/enums/announcement_action.dart';
import 'package:planted/managers/conectivity_manager.dart';
import 'package:planted/managers/firebase_database_manager.dart';

class UserProfileScreenBloc
    extends Bloc<UserProfileScreenEvent, UserProfileScreenState> {
  final connectivityManager = ConnectivityManager();
  final databaseManager = FirebaseDatabaseManager();

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
        if (connectivityManager.status == ConnectivityResult.none) {
          emit(const UserProfileScreenStateInUsersAnnouncementsView(
            isLoading: false,
            databaseError: DatabaseErrorNetworkRequestFailed(),
          ));
          return;
        }

        emit(const UserProfileScreenStateInUsersAnnouncementsView(
            isLoading: true));

        try {
          final announcementStatus =
              await databaseManager.archiveOrDeleteAnnouncement(
            userID: event.userID,
            announcementID: event.documentID,
          );

          emit(
            UserProfileScreenStateInUsersAnnouncementsView(
                isLoading: false,
                snackbarMessage:
                    announcementStatus == AnnouncementAction.deleted
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
      if (connectivityManager.status == ConnectivityResult.none) {
        emit(const UserProfileScreenStateInUsersAnnouncementsView(
          isLoading: false,
          databaseError: DatabaseErrorNetworkRequestFailed(),
        ));
        return;
      }

      emit(const UserProfileScreenStateInUsersAnnouncementsView(
          isLoading: true));

      try {
        await databaseManager.deleteAnnouncement(
            announcementID: event.documentID);

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

    on<UserProfileScreenEventUnblockUser>(
      (event, emit) async {
        if (connectivityManager.status == ConnectivityResult.none) {
          emit(const UserProfileScreenStateInBlockedUsersView(
            isLoading: false,
            databaseError: DatabaseErrorNetworkRequestFailed(),
          ));
          return;
        }

        emit(const UserProfileScreenStateInBlockedUsersView(isLoading: true));

        try {
          await databaseManager.unblockUser(
            currentUserID: event.currentUserID,
            userToUnblockID: event.idToUnblock,
          );

          emit(const UserProfileScreenStateInBlockedUsersView(
            isLoading: false,
            snackbarMessage: 'Użytkownik został odblokowany!',
          ));
        } on FirebaseException catch (e) {
          emit(UserProfileScreenStateInUserProfileView(
            isLoading: false,
            databaseError: DatabaseError.from(e),
          ));
        }
      },
    );

    on<UserProfileScreenEventOpenLegalTerms>(
      (event, emit) async {
        if (connectivityManager.status == ConnectivityResult.none) {
          emit(const UserProfileScreenStateInUserProfileView(
            isLoading: false,
            databaseError: DatabaseErrorNetworkRequestFailed(),
          ));
          return;
        }

        emit(const UserProfileScreenStateInUserProfileView(isLoading: false));

        try {
          final path = await databaseManager.getPathToLegalTerms(
            documentID: event.documentID,
          );

          emit(UserProfileScreenStateInUserProfileView(
            isLoading: false,
            path: path,
          ));
        } on FirebaseException catch (e) {
          emit(UserProfileScreenStateInUserProfileView(
            isLoading: false,
            databaseError: DatabaseError.from(e),
          ));
        }
      },
    );
    on<UserProfileScreenEventGoToAdministratorPanelView>(
      (event, emit) {
        if (!event.userProfile.isAdmin) {
          emit(const UserProfileScreenStateInUserProfileView(
            isLoading: false,
            databaseError: DatabaseErrorPermissionDenied(),
          ));
        }

        try {
          emit(
            UserProfileScreenStateInAdministratorPanel(
              announcementsStream:
                  databaseManager.createAnnouncementsStreamWith(status: 0),
              reportsStream: databaseManager.createReportsStreamFor(status: 0),
              initialTabBarIndex: event.initialTabBarIndex,
              isLoading: false,
            ),
          );
        } on FirebaseException catch (e) {
          emit(UserProfileScreenStateInUserProfileView(
            isLoading: false,
            databaseError: DatabaseError.from(e),
          ));
        }
      },
    );

    on<UserProfileScreenEventChangeStatusOfAnnouncement>(
      (event, emit) async {
        final newStatus =
            event.action == AdminAnnouncementAction.accept ? 1 : 2;
        try {
          await databaseManager.changeStatusOfAnnouncement(
              announcementID: event.announcementID, newStatus: newStatus);
        } on FirebaseException catch (e) {
          emit(UserProfileScreenStateInAdministratorPanel(
            initialTabBarIndex: 0,
            isLoading: false,
            announcementsStream: state.announcementsStream,
            reportsStream: state.reportsStream,
            databaseError: DatabaseError.from(e),
          ));
        }
      },
    );
    on<UserProfileScreenEventGoToUserReportsView>(
      (event, emit) {
        emit(UserProfileScreenStateInUserReportsView(
          isLoading: false,
          reportsStream: databaseManager.createUserReportsStream(
            userID: event.userID,
          ),
        ));
      },
    );
  }
}
