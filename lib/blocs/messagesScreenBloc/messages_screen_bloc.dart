import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/database_error.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_event.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_state.dart';
import 'package:planted/managers/conectivity_manager.dart';
import 'package:planted/managers/firebase_database_manager.dart';
import 'package:planted/models/announcement.dart';
import 'package:planted/models/conversation.dart';
import 'package:planted/models/user_profile.dart';

class MessagesScreenBloc
    extends Bloc<MessagesScreenEvent, MessagesScreenState> {
  final connectivityManager = ConnectivityManager();
  final databaseManager = FirebaseDatabaseManager();
  final String userID;

  MessagesScreenBloc({required this.userID})
      : super(
          const MessagesScreenStateInitial(
            isLoading: true,
          ),
        ) {
    final conversationsListStream =
        databaseManager.createConversationsStreamFor(userID: userID);

    late Stream<Conversation> convesationStream;

    on<MessagesScreenEventInitialize>(
      (event, emit) {
        emit(MessagesScreenStateInConversationsList(
          isLoading: false,
          conversationsListStream: conversationsListStream,
        ));
      },
    );

    on<MessagesScreenEventGoToListOfConvesations>(
      (event, emit) {
        emit(MessagesScreenStateInConversationsList(
          isLoading: false,
          conversationsListStream: conversationsListStream,
        ));
      },
    );

    on<MessagesScreenEventGoToConversation>(
      (event, emit) async {
        if (connectivityManager.status == ConnectivityResult.none) {
          emit(MessagesScreenStateInConversationsList(
            isLoading: false,
            databaseError: const DatabaseErrorNetworkRequestFailed(),
            conversationsListStream: conversationsListStream,
          ));
          return;
        }

        emit(MessagesScreenStateInConversationsList(
          isLoading: true,
          conversationsListStream: conversationsListStream,
        ));

        try {
          final announcement = await databaseManager.getAnnouncement(
              id: event.conversation.announcementID);

          final userProfile = await databaseManager.getUserProfile(id: userID);

          await databaseManager.updateLastActivityInConversation(
            currentUserID: userID,
            giverID: announcement.giverID,
            conversationID: event.conversation.conversationID,
          );

          convesationStream = databaseManager.createConverationStreamFor(
            conversationID: event.conversation.conversationID,
          );

          emit(MessagesScreenStateInConversation(
            conversationDetailsStream: convesationStream,
            isLoading: false,
            conversation: event.conversation,
            announcement: announcement,
            userProfile: userProfile,
          ));
        } on FirebaseException catch (e) {
          emit(
            MessagesScreenStateInConversationsList(
              isLoading: false,
              databaseError: DatabaseError.from(e),
              conversationsListStream: conversationsListStream,
            ),
          );
        }
      },
    );

    on<MessagesScreenEventSendMessage>(
      (event, emit) async {
        final Announcement announcement;
        final UserProfile userProfile;
        final Conversation conversation;

        try {
          announcement = state.announcement!;
          userProfile = state.userProfile!;
          conversation = state.conversation!;

          if (connectivityManager.status == ConnectivityResult.none) {
            emit(MessagesScreenStateInConversation(
              conversationDetailsStream: convesationStream,
              isLoading: false,
              conversation: conversation,
              announcement: announcement,
              userProfile: userProfile,
              databaseError: const DatabaseErrorNetworkRequestFailed(),
            ));
          }

          try {
            await databaseManager.sendMessage(
              conversation: conversation,
              sender: userProfile.userID,
              message: event.message.trim(),
            );

            emit(MessagesScreenStateInConversation(
              conversationDetailsStream: convesationStream,
              isLoading: false,
              conversation: conversation,
              announcement: announcement,
              userProfile: userProfile,
              messageSended: true,
            ));
          } on FirebaseException catch (e) {
            emit(MessagesScreenStateInConversation(
              conversationDetailsStream: convesationStream,
              isLoading: false,
              conversation: conversation,
              announcement: announcement,
              userProfile: userProfile,
              databaseError: DatabaseError.from(e),
            ));
          }
        } catch (e) {
          emit(MessagesScreenStateInConversationsList(
            isLoading: false,
            databaseError: const DatabaseErrorUnknown(),
            conversationsListStream: conversationsListStream,
          ));
        }
      },
    );

    on<MessagesScreenEventBlockUser>(
      (event, emit) async {
        if (connectivityManager.status == ConnectivityResult.none) {
          emit(MessagesScreenStateInConversation(
            conversationDetailsStream: convesationStream,
            isLoading: false,
            conversation: state.conversation!,
            announcement: state.announcement!,
            userProfile: state.userProfile!,
            databaseError: const DatabaseErrorNetworkRequestFailed(),
          ));
        }

        await databaseManager.addUserToBlockedUsersList(
          currentUserID: event.currentUserID,
          userToBlockID: event.userToBlockID,
        );

        emit(MessagesScreenStateInConversationsList(
          isLoading: false,
          snackbarMessage: 'Użytkownik został zablokowany!',
          conversationsListStream: conversationsListStream,
        ));
      },
    );

    on<MessagesScreenEventGoToConversationFromPushMessage>(
      (event, emit) async {
        if (connectivityManager.status == ConnectivityResult.none) {
          emit(MessagesScreenStateInConversationsList(
            isLoading: false,
            databaseError: const DatabaseErrorNetworkRequestFailed(),
            conversationsListStream: conversationsListStream,
          ));
          return;
        }

        emit(MessagesScreenStateInConversationsList(
          isLoading: true,
          conversationsListStream: conversationsListStream,
        ));

        try {
          final conversation = await databaseManager.getConversation(
              conversationID: event.conversationID);

          final announcement = await databaseManager.getAnnouncement(
              id: conversation.announcementID);

          final userProfile = await databaseManager.getUserProfile(id: userID);

          await databaseManager.updateLastActivityInConversation(
            currentUserID: userID,
            giverID: announcement.giverID,
            conversationID: conversation.conversationID,
          );

          emit(MessagesScreenStateInConversation(
            conversationDetailsStream: convesationStream,
            isLoading: false,
            conversation: conversation,
            announcement: announcement,
            userProfile: userProfile,
          ));
        } on FirebaseException catch (e) {
          emit(
            MessagesScreenStateInConversationsList(
              isLoading: false,
              databaseError: DatabaseError.from(e),
              conversationsListStream: conversationsListStream,
            ),
          );
        }
      },
    );

    on<MessagesScreenEventGoToReportView>(
      (event, emit) {
        emit(MessagesScreenStateInReportView(
          isLoading: false,
          userID: event.userID,
          announcement: event.announcement,
          conversation: event.conversation,
        ));
      },
    );

    on<MessagesScreenEventBackToConversationFromReportView>(
      (event, emit) async {
        final userProfile = await databaseManager.getUserProfile(id: userID);

        emit(MessagesScreenStateInConversation(
          conversationDetailsStream: convesationStream,
          isLoading: false,
          conversation: event.conversation,
          announcement: event.announcement,
          userProfile: userProfile,
        ));
      },
    );

    on<MessagesScreenEventSendReport>(
      (event, emit) async {
        if (connectivityManager.status == ConnectivityResult.none) {
          emit(MessagesScreenStateInReportView(
            isLoading: false,
            userID: event.userID,
            announcement: event.announcement,
            conversation: event.conversation,
            databaseError: const DatabaseErrorNetworkRequestFailed(),
          ));
          return;
        }

        try {
          await databaseManager.sendReport(
              announcement: event.announcement,
              conversationID: event.conversation?.conversationID ?? '',
              reasonForReporting: event.reasonForReporting,
              additionalInformation: event.additionalInformation,
              userID: event.userID);

          final userProfile =
              await databaseManager.getUserProfile(id: event.userID);

          if (event.conversation != null) {
            emit(MessagesScreenStateInConversation(
              conversationDetailsStream: convesationStream,
              isLoading: false,
              conversation: event.conversation!,
              announcement: event.announcement,
              userProfile: userProfile,
              snackbarMessage: 'Zgłoszenie zostało wysłane!',
            ));
          } else {
            emit(MessagesScreenStateInConversationsList(
              isLoading: false,
              snackbarMessage: 'Zgłoszenie zostało wysłane!',
              conversationsListStream: conversationsListStream,
            ));
          }
        } on FirebaseException catch (e) {
          emit(MessagesScreenStateInReportView(
            isLoading: false,
            userID: event.userID,
            announcement: event.announcement,
            conversation: event.conversation,
            databaseError: DatabaseError.from(e),
          ));
        }
      },
    );
  }
}
