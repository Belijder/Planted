import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_event.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_state.dart';
import 'package:planted/database_error.dart';
import 'package:planted/managers/conectivity_manager.dart';
import 'package:planted/managers/firebase_database_manager.dart';
import 'package:planted/models/conversation.dart';

class BrowseScreenBloc extends Bloc<BrowseScreenEvent, BrowseScreenState> {
  final connectivityManager = ConnectivityManager();
  final databaseManager = FirebaseDatabaseManager();
  BrowseScreenBloc()
      : super(
          const InAnnouncementsListViewBrowseScreenState(
            isLoading: false,
          ),
        ) {
    on<GoToDetailViewBrowseScreenEvent>(
      (event, emit) {
        emit(
          InAnnouncementDetailsBrowseScreenState(
            announcement: event.announcement,
            isLoading: false,
          ),
        );
      },
    );

    on<CancelConversationBrowseScreenEvent>(
      (event, emit) async {
        if (connectivityManager.status == ConnectivityResult.none) {
          emit(
            InAnnouncementDetailsBrowseScreenState(
              announcement: event.announcement,
              isLoading: false,
            ),
          );
          return;
        }

        emit(
          InAnnouncementDetailsBrowseScreenState(
            announcement: event.announcement,
            isLoading: true,
          ),
        );

        try {
          databaseManager.deleteConversation(id: event.conversationID);
          emit(
            InAnnouncementDetailsBrowseScreenState(
              announcement: event.announcement,
              isLoading: false,
            ),
          );
        } on FirebaseException catch (e) {
          emit(
            InAnnouncementDetailsBrowseScreenState(
              announcement: event.announcement,
              isLoading: false,
              databaseError: DatabaseError.from(e),
            ),
          );
        }
      },
    );

    on<GoToListViewBrowseScreenEvent>(
      (event, emit) {
        emit(
          const InAnnouncementsListViewBrowseScreenState(
            isLoading: false,
          ),
        );
      },
    );

    on<GoToConversationViewBrowseScreenEvent>(
      (event, emit) async {
        if (connectivityManager.status == ConnectivityResult.none) {
          emit(
            InAnnouncementDetailsBrowseScreenState(
                announcement: event.announcement,
                isLoading: false,
                databaseError: const DatabaseErrorNetworkRequestFailed()),
          );
          return;
        }

        emit(InAnnouncementDetailsBrowseScreenState(
            announcement: event.announcement, isLoading: true));

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(
            InAnnouncementDetailsBrowseScreenState(
              announcement: event.announcement,
              isLoading: false,
              databaseError: const DatabaseErrorUserNotFound(),
            ),
          );
          return;
        }

        final Conversation conversation;

        try {
          final existingConversation =
              await databaseManager.checkIfConversationExist(
            giverID: event.announcement.giverID,
            takerID: user.uid,
            announcementID: event.announcement.docID,
          );

          if (existingConversation != null) {
            conversation = existingConversation;
          } else {
            conversation = await databaseManager.createNewConversation(
              announcement: event.announcement,
              userID: user.uid,
            );
          }

          emit(InConversationViewBrowseScreenState(
            isLoading: false,
            user: user,
            announcement: event.announcement,
            conversation: conversation,
          ));
        } on FirebaseException catch (e) {
          emit(
            InAnnouncementDetailsBrowseScreenState(
              announcement: event.announcement,
              isLoading: false,
              databaseError: DatabaseError.from(e),
            ),
          );
        }
      },
    );

    on<SendMessageBrowseScreenEvent>(
      (event, emit) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(
            InAnnouncementDetailsBrowseScreenState(
              announcement: event.announcement,
              isLoading: false,
              databaseError: const DatabaseErrorUserNotFound(),
            ),
          );
          return;
        }

        if (connectivityManager.status == ConnectivityResult.none) {
          emit(InConversationViewBrowseScreenState(
            isLoading: false,
            user: user,
            announcement: event.announcement,
            conversation: event.conversation,
            databaseError: const DatabaseErrorNetworkRequestFailed(),
          ));
          return;
        }

        try {
          await databaseManager.sendMessage(
            conversation: event.conversation,
            sender: user.uid,
            message: event.message,
          );

          emit(InConversationViewBrowseScreenState(
            isLoading: false,
            user: user,
            announcement: event.announcement,
            conversation: event.conversation,
            messageSended: true,
          ));
        } on FirebaseException catch (e) {
          emit(InConversationViewBrowseScreenState(
            isLoading: false,
            user: user,
            announcement: event.announcement,
            conversation: event.conversation,
            databaseError: DatabaseError.from(e),
          ));
        }
      },
    );

    on<BlockUserFromConvesationViewBrowseScreenEvent>(
      (event, emit) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(
            InAnnouncementDetailsBrowseScreenState(
              announcement: event.announcement,
              isLoading: false,
              databaseError: const DatabaseErrorUserNotFound(),
            ),
          );
          return;
        }

        if (connectivityManager.status == ConnectivityResult.none) {
          emit(InConversationViewBrowseScreenState(
            isLoading: false,
            user: user,
            announcement: event.announcement,
            conversation: event.conversation,
            databaseError: const DatabaseErrorNetworkRequestFailed(),
          ));
          return;
        }

        await databaseManager.addUserToBlockedUsersList(
          currentUserID: user.uid,
          userToBlockID: event.userToBlockID,
        );

        emit(const InAnnouncementsListViewBrowseScreenState(
            isLoading: false,
            snackbarMessage: 'Użytkownik został zablokowany!'));
      },
    );

    on<BlockUserFromDetailsViewBrowseScreenEvent>(
      (event, emit) async {
        if (connectivityManager.status == ConnectivityResult.none) {
          emit(InAnnouncementDetailsBrowseScreenState(
            announcement: event.announcement,
            isLoading: false,
            databaseError: const DatabaseErrorNetworkRequestFailed(),
          ));
          return;
        }

        emit(InAnnouncementDetailsBrowseScreenState(
          announcement: event.announcement,
          isLoading: true,
        ));

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(
            InAnnouncementDetailsBrowseScreenState(
                announcement: event.announcement,
                isLoading: false,
                databaseError: const DatabaseErrorUserNotFound()),
          );
          return;
        }

        try {
          await databaseManager.addUserToBlockedUsersList(
            currentUserID: user.uid,
            userToBlockID: event.userToBlockID,
          );

          emit(const InAnnouncementsListViewBrowseScreenState(
              isLoading: false,
              snackbarMessage: 'Użytkownik został zablokowany!'));
        } on FirebaseException catch (e) {
          emit(
            InAnnouncementDetailsBrowseScreenState(
                announcement: event.announcement,
                isLoading: false,
                databaseError: DatabaseError.from(e)),
          );
        }
      },
    );
  }
}
