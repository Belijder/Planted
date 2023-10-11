import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_event.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_state.dart';
import 'package:planted/blocs/database_error.dart';
import 'package:planted/managers/conectivity_manager.dart';
import 'package:planted/managers/firebase_database_manager.dart';
import 'package:planted/models/conversation.dart';

class BrowseScreenBloc extends Bloc<BrowseScreenEvent, BrowseScreenState> {
  final connectivityManager = ConnectivityManager();
  final databaseManager = FirebaseDatabaseManager();
  BrowseScreenBloc()
      : super(
          const InAnnouncementsListViewBrowseScreenState(
            scrollViewOffset: 0.0,
            isLoading: false,
          ),
        ) {
    on<GoToDetailViewBrowseScreenEvent>(
      (event, emit) {
        emit(
          InAnnouncementDetailsBrowseScreenState(
            announcement: event.announcement,
            isLoading: false,
            scrollViewOffset: event.scrollViewOffset ?? state.scrollViewOffset,
          ),
        );
      },
    );

    on<CancelConversationBrowseScreenEvent>(
      (event, emit) async {
        if (connectivityManager.status == ConnectivityResult.none) {
          emit(
            InAnnouncementDetailsBrowseScreenState(
              scrollViewOffset: state.scrollViewOffset,
              announcement: event.announcement,
              isLoading: false,
            ),
          );
          return;
        }

        emit(
          InAnnouncementDetailsBrowseScreenState(
            scrollViewOffset: state.scrollViewOffset,
            announcement: event.announcement,
            isLoading: true,
          ),
        );

        try {
          databaseManager.deleteConversation(id: event.conversationID);
          emit(
            InAnnouncementDetailsBrowseScreenState(
              scrollViewOffset: state.scrollViewOffset,
              announcement: event.announcement,
              isLoading: false,
            ),
          );
        } on FirebaseException catch (e) {
          emit(
            InAnnouncementDetailsBrowseScreenState(
              scrollViewOffset: state.scrollViewOffset,
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
          InAnnouncementsListViewBrowseScreenState(
            scrollViewOffset: state.scrollViewOffset,
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
                scrollViewOffset: state.scrollViewOffset,
                announcement: event.announcement,
                isLoading: false,
                databaseError: const DatabaseErrorNetworkRequestFailed()),
          );
          return;
        }

        emit(InAnnouncementDetailsBrowseScreenState(
            scrollViewOffset: state.scrollViewOffset,
            announcement: event.announcement,
            isLoading: true));

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(
            InAnnouncementDetailsBrowseScreenState(
              scrollViewOffset: state.scrollViewOffset,
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
            scrollViewOffset: state.scrollViewOffset,
            isLoading: false,
            userID: user.uid,
            announcement: event.announcement,
            conversation: conversation,
          ));
        } on FirebaseException catch (e) {
          emit(
            InAnnouncementDetailsBrowseScreenState(
              scrollViewOffset: state.scrollViewOffset,
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
              scrollViewOffset: state.scrollViewOffset,
              announcement: event.announcement,
              isLoading: false,
              databaseError: const DatabaseErrorUserNotFound(),
            ),
          );
          return;
        }

        if (connectivityManager.status == ConnectivityResult.none) {
          emit(InConversationViewBrowseScreenState(
            scrollViewOffset: state.scrollViewOffset,
            isLoading: false,
            userID: user.uid,
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
            scrollViewOffset: state.scrollViewOffset,
            isLoading: false,
            userID: user.uid,
            announcement: event.announcement,
            conversation: event.conversation,
            messageSended: true,
          ));
        } on FirebaseException catch (e) {
          emit(InConversationViewBrowseScreenState(
            scrollViewOffset: state.scrollViewOffset,
            isLoading: false,
            userID: user.uid,
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
              scrollViewOffset: state.scrollViewOffset,
              announcement: event.announcement,
              isLoading: false,
              databaseError: const DatabaseErrorUserNotFound(),
            ),
          );
          return;
        }

        if (connectivityManager.status == ConnectivityResult.none) {
          emit(InConversationViewBrowseScreenState(
            scrollViewOffset: state.scrollViewOffset,
            isLoading: false,
            userID: user.uid,
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

        emit(InAnnouncementsListViewBrowseScreenState(
            scrollViewOffset: state.scrollViewOffset,
            isLoading: false,
            snackbarMessage: 'Użytkownik został zablokowany!'));
      },
    );

    on<BlockUserFromDetailsViewBrowseScreenEvent>(
      (event, emit) async {
        if (connectivityManager.status == ConnectivityResult.none) {
          emit(InAnnouncementDetailsBrowseScreenState(
            scrollViewOffset: state.scrollViewOffset,
            announcement: event.announcement,
            isLoading: false,
            databaseError: const DatabaseErrorNetworkRequestFailed(),
          ));
          return;
        }

        emit(InAnnouncementDetailsBrowseScreenState(
          scrollViewOffset: state.scrollViewOffset,
          announcement: event.announcement,
          isLoading: true,
        ));

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(
            InAnnouncementDetailsBrowseScreenState(
                scrollViewOffset: state.scrollViewOffset,
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

          emit(InAnnouncementsListViewBrowseScreenState(
              scrollViewOffset: state.scrollViewOffset,
              isLoading: false,
              snackbarMessage: 'Użytkownik został zablokowany!'));
        } on FirebaseException catch (e) {
          emit(
            InAnnouncementDetailsBrowseScreenState(
                scrollViewOffset: state.scrollViewOffset,
                announcement: event.announcement,
                isLoading: false,
                databaseError: DatabaseError.from(e)),
          );
        }
      },
    );

    on<GoToReportViewFromAnnouncementBrowseScreenEvent>(
      (event, emit) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(
            InAnnouncementDetailsBrowseScreenState(
                scrollViewOffset: state.scrollViewOffset,
                announcement: event.announcement,
                isLoading: false,
                databaseError: const DatabaseErrorUserNotFound()),
          );
          return;
        }

        emit(InReportViewBrowseScreenState(
          scrollViewOffset: state.scrollViewOffset,
          isLoading: false,
          userID: user.uid,
          announcement: event.announcement,
          conversation: null,
        ));
      },
    );

    on<GoToReportViewFromConversationBrowseScreenEvent>(
      (event, emit) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(
            InAnnouncementDetailsBrowseScreenState(
                scrollViewOffset: state.scrollViewOffset,
                announcement: event.announcement,
                isLoading: false,
                databaseError: const DatabaseErrorUserNotFound()),
          );
          return;
        }

        emit(InReportViewBrowseScreenState(
          scrollViewOffset: state.scrollViewOffset,
          isLoading: false,
          userID: user.uid,
          announcement: event.announcement,
          conversation: event.conversation,
        ));
      },
    );

    on<SendReportBrowseScreenEvent>(
      (event, emit) async {
        if (connectivityManager.status == ConnectivityResult.none) {
          emit(InReportViewBrowseScreenState(
            scrollViewOffset: state.scrollViewOffset,
            isLoading: false,
            userID: event.userID,
            announcement: event.announcement,
            conversation: event.conversation,
            databaseError: const DatabaseErrorNetworkRequestFailed(),
          ));
          return;
        }

        emit(InReportViewBrowseScreenState(
          scrollViewOffset: state.scrollViewOffset,
          isLoading: true,
          userID: event.userID,
          announcement: event.announcement,
          conversation: event.conversation,
        ));

        try {
          await databaseManager.sendReport(
            announcement: event.announcement,
            conversationID: event.conversation?.conversationID ?? '',
            reasonForReporting: event.reasonForReporting,
            additionalInformation: event.additionalInformation,
            userID: event.userID,
          );
          if (event.conversation == null) {
            emit(InAnnouncementDetailsBrowseScreenState(
              scrollViewOffset: state.scrollViewOffset,
              announcement: event.announcement,
              isLoading: false,
              snackbarMessage: 'Zgłoszenie zostało wysłane!',
            ));
          } else {
            emit(InConversationViewBrowseScreenState(
              scrollViewOffset: state.scrollViewOffset,
              isLoading: false,
              userID: event.userID,
              announcement: event.announcement,
              conversation: event.conversation!,
              snackbarMessage: 'Zgłoszenie zostało wysłane!',
            ));
          }
        } on FirebaseException catch (e) {
          if (event.conversation == null) {
            emit(InAnnouncementDetailsBrowseScreenState(
              scrollViewOffset: state.scrollViewOffset,
              announcement: event.announcement,
              isLoading: false,
              databaseError: DatabaseError.from(e),
            ));
          } else {
            emit(InConversationViewBrowseScreenState(
              scrollViewOffset: state.scrollViewOffset,
              isLoading: false,
              userID: event.userID,
              announcement: event.announcement,
              conversation: event.conversation!,
              databaseError: DatabaseError.from(e),
            ));
          }
        }
      },
    );
  }
}
