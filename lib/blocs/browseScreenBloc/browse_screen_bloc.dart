import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_event.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_state.dart';
import 'package:planted/blocs/database_error.dart';
import 'package:planted/constants/strings.dart';
import 'package:planted/managers/conectivity_manager.dart';
import 'package:planted/managers/firebase_database_manager.dart';
import 'package:planted/models/announcement.dart';
import 'package:planted/models/conversation.dart';

class BrowseScreenBloc extends Bloc<BrowseScreenEvent, BrowseScreenState> {
  final connectivityManager = ConnectivityManager();
  final databaseManager = FirebaseDatabaseManager();
  final StreamController<List<Announcement>> reportStreamController =
      StreamController<List<Announcement>>();

  BrowseScreenBloc()
      : super(
          const BrowseScreenStateInitial(
            scrollViewOffset: 0.0,
            isLoading: true,
          ),
        ) {
    on<BrowseScreenEventInitialize>(
      (event, emit) {
        final userID = FirebaseAuth.instance.currentUser?.uid ?? '';
        emit(BrowseScreenStateInAnnouncementsListView(
          userProfileStream:
              databaseManager.createUserProfileStremFor(userID: userID),
          isLoading: false,
          scrollViewOffset: state.scrollViewOffset,
          announcementsStream:
              databaseManager.createAnnouncementsStreamWith(status: 1),
        ));
      },
    );

    on<BrowseScreenEventGoToDetailView>(
      (event, emit) {
        emit(
          BrowseScreenStateInAnnouncementDetails(
            announcement: event.announcement,
            isLoading: false,
            scrollViewOffset: event.scrollViewOffset ?? state.scrollViewOffset,
          ),
        );
      },
    );

    on<BrowseScreenEventCancelConversation>(
      (event, emit) async {
        if (connectivityManager.status == ConnectivityResult.none) {
          emit(
            BrowseScreenStateInAnnouncementDetails(
              scrollViewOffset: state.scrollViewOffset,
              announcement: event.announcement,
              isLoading: false,
            ),
          );
          return;
        }

        emit(
          BrowseScreenStateInAnnouncementDetails(
            scrollViewOffset: state.scrollViewOffset,
            announcement: event.announcement,
            isLoading: true,
          ),
        );

        try {
          databaseManager.deleteConversation(id: event.conversationID);
          emit(
            BrowseScreenStateInAnnouncementDetails(
              scrollViewOffset: state.scrollViewOffset,
              announcement: event.announcement,
              isLoading: false,
            ),
          );
        } on FirebaseException catch (e) {
          emit(
            BrowseScreenStateInAnnouncementDetails(
              scrollViewOffset: state.scrollViewOffset,
              announcement: event.announcement,
              isLoading: false,
              databaseError: DatabaseError.from(e),
            ),
          );
        }
      },
    );

    on<BrowseScreenEventGoToListView>(
      (event, emit) {
        final userID = FirebaseAuth.instance.currentUser?.uid ?? '';

        emit(
          BrowseScreenStateInAnnouncementsListView(
            userProfileStream:
                databaseManager.createUserProfileStremFor(userID: userID),
            announcementsStream:
                databaseManager.createAnnouncementsStreamWith(status: 1),
            scrollViewOffset: state.scrollViewOffset,
            isLoading: false,
          ),
        );
      },
    );

    on<BrowseScreenEventGoToConversationView>(
      (event, emit) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(BrowseScreenStateInAnnouncementDetails(
            scrollViewOffset: state.scrollViewOffset,
            announcement: event.announcement,
            isLoading: false,
            databaseError: const DatabaseErrorUserNotFound(),
          ));
          return;
        }

        if (user.uid == event.announcement.giverID) {
          emit(BrowseScreenStateInAnnouncementDetails(
            scrollViewOffset: state.scrollViewOffset,
            announcement: event.announcement,
            isLoading: false,
            databaseError: const DatabaseErrorSameUserAsGiver(),
          ));
          return;
        }

        if (connectivityManager.status == ConnectivityResult.none) {
          emit(
            BrowseScreenStateInAnnouncementDetails(
                scrollViewOffset: state.scrollViewOffset,
                announcement: event.announcement,
                isLoading: false,
                databaseError: const DatabaseErrorNetworkRequestFailed()),
          );
          return;
        }

        emit(BrowseScreenStateInAnnouncementDetails(
          scrollViewOffset: state.scrollViewOffset,
          announcement: event.announcement,
          isLoading: true,
        ));

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

          emit(BrowseScreenStateInConversationView(
            conversationDetailsStream:
                databaseManager.createConverationStreamFor(
                    conversationID: conversation.conversationID),
            scrollViewOffset: state.scrollViewOffset,
            isLoading: false,
            userID: user.uid,
            announcement: event.announcement,
            conversation: conversation,
          ));
        } on FirebaseException catch (e) {
          emit(
            BrowseScreenStateInAnnouncementDetails(
              scrollViewOffset: state.scrollViewOffset,
              announcement: event.announcement,
              isLoading: false,
              databaseError: DatabaseError.from(e),
            ),
          );
        }
      },
    );

    on<BrowseScreenEventSendMessage>(
      (event, emit) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(
            BrowseScreenStateInAnnouncementDetails(
              scrollViewOffset: state.scrollViewOffset,
              announcement: event.announcement,
              isLoading: false,
              databaseError: const DatabaseErrorUserNotFound(),
            ),
          );
          return;
        }

        if (connectivityManager.status == ConnectivityResult.none) {
          emit(BrowseScreenStateInConversationView(
            conversationDetailsStream: state.conversationDetailsStream,
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

          emit(BrowseScreenStateInConversationView(
            conversationDetailsStream: state.conversationDetailsStream,
            scrollViewOffset: state.scrollViewOffset,
            isLoading: false,
            userID: user.uid,
            announcement: event.announcement,
            conversation: event.conversation,
            messageSended: true,
          ));
        } on FirebaseException catch (e) {
          emit(BrowseScreenStateInConversationView(
            conversationDetailsStream: state.conversationDetailsStream,
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

    on<BrowseScreenEventBlockUserFromConvesationView>(
      (event, emit) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(
            BrowseScreenStateInAnnouncementDetails(
              scrollViewOffset: state.scrollViewOffset,
              announcement: event.announcement,
              isLoading: false,
              databaseError: const DatabaseErrorUserNotFound(),
            ),
          );
          return;
        }

        if (connectivityManager.status == ConnectivityResult.none) {
          emit(BrowseScreenStateInConversationView(
            conversationDetailsStream: state.conversationDetailsStream,
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

        emit(BrowseScreenStateInAnnouncementsListView(
          userProfileStream:
              databaseManager.createUserProfileStremFor(userID: user.uid),
          announcementsStream:
              databaseManager.createAnnouncementsStreamWith(status: 1),
          scrollViewOffset: state.scrollViewOffset,
          isLoading: false,
          snackbarMessage: SnackbarMessageContent.userBlocked,
        ));
      },
    );

    on<BrowseScreenEventBlockUserFromDetailsView>(
      (event, emit) async {
        if (connectivityManager.status == ConnectivityResult.none) {
          emit(BrowseScreenStateInAnnouncementDetails(
            scrollViewOffset: state.scrollViewOffset,
            announcement: event.announcement,
            isLoading: false,
            databaseError: const DatabaseErrorNetworkRequestFailed(),
          ));
          return;
        }

        emit(BrowseScreenStateInAnnouncementDetails(
          scrollViewOffset: state.scrollViewOffset,
          announcement: event.announcement,
          isLoading: true,
        ));

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(
            BrowseScreenStateInAnnouncementDetails(
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

          emit(BrowseScreenStateInAnnouncementsListView(
            userProfileStream:
                databaseManager.createUserProfileStremFor(userID: user.uid),
            announcementsStream:
                databaseManager.createAnnouncementsStreamWith(status: 1),
            scrollViewOffset: state.scrollViewOffset,
            isLoading: false,
            snackbarMessage: SnackbarMessageContent.userBlocked,
          ));
        } on FirebaseException catch (e) {
          emit(
            BrowseScreenStateInAnnouncementDetails(
                scrollViewOffset: state.scrollViewOffset,
                announcement: event.announcement,
                isLoading: false,
                databaseError: DatabaseError.from(e)),
          );
        }
      },
    );

    on<BrowseScreenEventGoToReportViewFromAnnouncement>(
      (event, emit) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(
            BrowseScreenStateInAnnouncementDetails(
                scrollViewOffset: state.scrollViewOffset,
                announcement: event.announcement,
                isLoading: false,
                databaseError: const DatabaseErrorUserNotFound()),
          );
          return;
        }

        emit(BrowseScreenStateInReportView(
          scrollViewOffset: state.scrollViewOffset,
          isLoading: false,
          userID: user.uid,
          announcement: event.announcement,
          conversation: null,
        ));
      },
    );

    on<BrowseScreenEventGoToReportViewFromConversation>(
      (event, emit) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(
            BrowseScreenStateInAnnouncementDetails(
                scrollViewOffset: state.scrollViewOffset,
                announcement: event.announcement,
                isLoading: false,
                databaseError: const DatabaseErrorUserNotFound()),
          );
          return;
        }

        emit(BrowseScreenStateInReportView(
          scrollViewOffset: state.scrollViewOffset,
          isLoading: false,
          userID: user.uid,
          announcement: event.announcement,
          conversation: event.conversation,
        ));
      },
    );

    on<BrowseScreenEventSendReport>(
      (event, emit) async {
        if (connectivityManager.status == ConnectivityResult.none) {
          emit(BrowseScreenStateInReportView(
            scrollViewOffset: state.scrollViewOffset,
            isLoading: false,
            userID: event.userID,
            announcement: event.announcement,
            conversation: event.conversation,
            databaseError: const DatabaseErrorNetworkRequestFailed(),
          ));
          return;
        }

        emit(BrowseScreenStateInReportView(
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
            emit(BrowseScreenStateInAnnouncementDetails(
                scrollViewOffset: state.scrollViewOffset,
                announcement: event.announcement,
                isLoading: false,
                snackbarMessage: SnackbarMessageContent.reportSended));
          } else {
            emit(BrowseScreenStateInConversationView(
              conversationDetailsStream:
                  databaseManager.createConverationStreamFor(
                      conversationID: event.conversation!.conversationID),
              scrollViewOffset: state.scrollViewOffset,
              isLoading: false,
              userID: event.userID,
              announcement: event.announcement,
              conversation: event.conversation!,
              snackbarMessage: SnackbarMessageContent.reportSended,
            ));
          }
        } on FirebaseException catch (e) {
          if (event.conversation == null) {
            emit(BrowseScreenStateInAnnouncementDetails(
              scrollViewOffset: state.scrollViewOffset,
              announcement: event.announcement,
              isLoading: false,
              databaseError: DatabaseError.from(e),
            ));
          } else {
            emit(BrowseScreenStateInConversationView(
              conversationDetailsStream:
                  databaseManager.createConverationStreamFor(
                      conversationID: event.conversation!.conversationID),
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
