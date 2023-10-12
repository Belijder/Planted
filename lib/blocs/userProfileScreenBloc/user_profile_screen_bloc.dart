import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/database_error.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_event.dart';
import 'package:planted/blocs/userProfileScreenBloc/user_profile_screen_state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:planted/constants/enums/admin_announcement_action.dart';
import 'package:planted/constants/enums/announcement_action.dart';
import 'package:planted/managers/conectivity_manager.dart';
import 'package:planted/managers/firebase_database_manager.dart';

class UserProfileScreenBloc
    extends Bloc<UserProfileScreenEvent, UserProfileScreenState> {
  final connectivityManager = ConnectivityManager();
  final databaseManager = FirebaseDatabaseManager();
  final String userID;

  UserProfileScreenBloc({required this.userID})
      : super(
          const UserProfileScreenStateInitial(
            isLoading: false,
          ),
        ) {
    final userProfileStream =
        databaseManager.createUserProfileStremFor(userID: userID);

    on<UserProfileScreenEventInitialize>(
      (event, emit) {
        emit(UserProfileScreenStateInUserProfileView(
          isLoading: false,
          userProfileStream: userProfileStream,
        ));
      },
    );

    on<UserProfileScreenEventGoToUsersAnnouncementsView>(
      (event, emit) {
        emit(UserProfileScreenStateInUsersAnnouncementsView(
            announcementsStream:
                databaseManager.createUsersAnnouncementsStream(userID: userID),
            isLoading: false));
      },
    );

    on<UserProfileScreenEventGoToBlockedUsersView>(
      (event, emit) {
        emit(UserProfileScreenStateInBlockedUsersView(
            isLoading: false,
            blockedUsersStream: databaseManager
                .createBlockedUsersProfilesStream(currentUserID: userID)));
      },
    );

    on<UserProfileScreenEventGoToUserProfileView>(
      (event, emit) {
        emit(UserProfileScreenStateInUserProfileView(
          isLoading: false,
          userProfileStream: userProfileStream,
        ));
      },
    );

    on<UserProfileScreenEventArchiveAnnouncement>(
      (event, emit) async {
        if (connectivityManager.status == ConnectivityResult.none) {
          emit(UserProfileScreenStateInUsersAnnouncementsView(
            announcementsStream: state.announcementsStream,
            isLoading: false,
            databaseError: const DatabaseErrorNetworkRequestFailed(),
          ));
          return;
        }

        emit(UserProfileScreenStateInUsersAnnouncementsView(
            announcementsStream: state.announcementsStream, isLoading: true));

        try {
          final announcementStatus =
              await databaseManager.archiveOrDeleteAnnouncement(
            userID: event.userID,
            announcementID: event.documentID,
          );

          emit(
            UserProfileScreenStateInUsersAnnouncementsView(
                announcementsStream: state.announcementsStream,
                isLoading: false,
                snackbarMessage:
                    announcementStatus == AnnouncementAction.deleted
                        ? 'Ogłoszenie zostało usunięte!'
                        : 'Ogłoszenie zostało zarchiwizowane!'),
          );
        } on FirebaseException catch (e) {
          emit(
            UserProfileScreenStateInUsersAnnouncementsView(
              announcementsStream: state.announcementsStream,
              isLoading: false,
              databaseError: DatabaseError.from(e),
            ),
          );
        }
      },
    );

    on<UserProfileScreenEventDeleteAnnouncement>((event, emit) async {
      if (connectivityManager.status == ConnectivityResult.none) {
        emit(UserProfileScreenStateInUsersAnnouncementsView(
          announcementsStream: state.announcementsStream,
          isLoading: false,
          databaseError: const DatabaseErrorNetworkRequestFailed(),
        ));
        return;
      }

      emit(UserProfileScreenStateInUsersAnnouncementsView(
          announcementsStream: state.announcementsStream, isLoading: true));

      try {
        await databaseManager.deleteAnnouncement(
            announcementID: event.documentID);

        emit(
          UserProfileScreenStateInUsersAnnouncementsView(
            announcementsStream: state.announcementsStream,
            isLoading: false,
            snackbarMessage: 'Ogłoszenie zostało usunięte!',
          ),
        );
      } on FirebaseException catch (e) {
        emit(
          UserProfileScreenStateInUsersAnnouncementsView(
            announcementsStream: state.announcementsStream,
            isLoading: false,
            databaseError: DatabaseError.from(e),
          ),
        );
      }
    });

    on<UserProfileScreenEventUnblockUser>(
      (event, emit) async {
        if (connectivityManager.status == ConnectivityResult.none) {
          emit(UserProfileScreenStateInBlockedUsersView(
            blockedUsersStream: state.blockedUsersStream,
            isLoading: false,
            databaseError: const DatabaseErrorNetworkRequestFailed(),
          ));
          return;
        }

        emit(UserProfileScreenStateInBlockedUsersView(
          isLoading: true,
          blockedUsersStream: state.blockedUsersStream,
        ));

        try {
          await databaseManager.unblockUser(
            currentUserID: event.currentUserID,
            userToUnblockID: event.idToUnblock,
          );

          emit(UserProfileScreenStateInBlockedUsersView(
            blockedUsersStream: state.blockedUsersStream,
            isLoading: false,
            snackbarMessage: 'Użytkownik został odblokowany!',
          ));
        } on FirebaseException catch (e) {
          emit(UserProfileScreenStateInUserProfileView(
            userProfileStream: userProfileStream,
            isLoading: false,
            databaseError: DatabaseError.from(e),
          ));
        }
      },
    );

    on<UserProfileScreenEventOpenLegalTerms>(
      (event, emit) async {
        if (connectivityManager.status == ConnectivityResult.none) {
          emit(UserProfileScreenStateInUserProfileView(
            userProfileStream: userProfileStream,
            isLoading: false,
            databaseError: const DatabaseErrorNetworkRequestFailed(),
          ));
          return;
        }

        emit(UserProfileScreenStateInUserProfileView(
          isLoading: false,
          userProfileStream: userProfileStream,
        ));

        try {
          final path = await databaseManager.getPathToLegalTerms(
            documentID: event.documentID,
          );

          emit(UserProfileScreenStateInUserProfileView(
            userProfileStream: userProfileStream,
            isLoading: false,
            path: path,
          ));
        } on FirebaseException catch (e) {
          emit(UserProfileScreenStateInUserProfileView(
            userProfileStream: userProfileStream,
            isLoading: false,
            databaseError: DatabaseError.from(e),
          ));
        }
      },
    );
    on<UserProfileScreenEventGoToAdministratorPanelView>(
      (event, emit) {
        if (!event.userProfile.isAdmin) {
          emit(UserProfileScreenStateInUserProfileView(
            userProfileStream: userProfileStream,
            isLoading: false,
            databaseError: const DatabaseErrorPermissionDenied(),
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
            userProfileStream: userProfileStream,
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
