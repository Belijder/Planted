import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_event.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_state.dart';
import 'package:planted/database_error.dart';
import 'package:planted/managers/conectivity_manager.dart';
import 'package:planted/managers/firebase_database_manager.dart';
import 'package:planted/models/announcement.dart';
import 'package:planted/models/conversation.dart';
import 'package:planted/models/user_profile.dart';

class MessagesScreenBloc
    extends Bloc<MessagesScreenEvent, MessagesScreenState> {
  final connectivityManager = ConnectivityManager();
  final databaseManager = FirebaseDatabaseManager();

  MessagesScreenBloc()
      : super(
          const InConversationsListMessagesScreenState(
            isLoading: false,
          ),
        ) {
    on<GoToListOfConvesationsMessagesScreenEvent>(
      (event, emit) {
        emit(const InConversationsListMessagesScreenState(
          isLoading: false,
        ));
      },
    );

    on<GoToConversationMessagesScreenEvent>(
      (event, emit) async {
        if (connectivityManager.status == ConnectivityResult.none) {
          emit(const InConversationsListMessagesScreenState(
            isLoading: false,
            databaseError: DatabaseErrorNetworkRequestFailed(),
          ));
          return;
        }

        emit(const InConversationsListMessagesScreenState(isLoading: true));

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(
            const InConversationsListMessagesScreenState(
              isLoading: false,
              databaseError: DatabaseErrorUserNotFound(),
            ),
          );
          return;
        }

        try {
          final announcement = await databaseManager.getAnnouncement(
              id: event.conversation.announcementID);

          final userProfile =
              await databaseManager.getUserProfile(id: user.uid);

          await databaseManager.updateLastActivityInConversation(
            currentUserID: user.uid,
            giverID: announcement.giverID,
            conversationID: event.conversation.conversationID,
          );

          emit(InConversationMessagesScreenState(
            isLoading: false,
            conversation: event.conversation,
            announcement: announcement,
            userProfile: userProfile,
          ));
        } on FirebaseException catch (e) {
          emit(
            InConversationsListMessagesScreenState(
              isLoading: false,
              databaseError: DatabaseError.from(e),
            ),
          );
        }
      },
    );

    on<SendMessageMessagesScreenEvent>(
      (event, emit) async {
        final Announcement announcement;
        final UserProfile userProfile;
        final Conversation conversation;

        try {
          announcement = state.announcement!;
          userProfile = state.userProfile!;
          conversation = state.conversation!;

          if (connectivityManager.status == ConnectivityResult.none) {
            emit(InConversationMessagesScreenState(
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

            emit(InConversationMessagesScreenState(
              isLoading: false,
              conversation: conversation,
              announcement: announcement,
              userProfile: userProfile,
              messageSended: true,
            ));
          } on FirebaseException catch (e) {
            emit(InConversationMessagesScreenState(
              isLoading: false,
              conversation: conversation,
              announcement: announcement,
              userProfile: userProfile,
              databaseError: DatabaseError.from(e),
            ));
          }
        } catch (e) {
          emit(const InConversationsListMessagesScreenState(
            isLoading: false,
            databaseError: DatabaseErrorUnknown(),
          ));
        }
      },
    );

    on<BlockUserMessagesScreenEvent>(
      (event, emit) async {
        if (connectivityManager.status == ConnectivityResult.none) {
          emit(InConversationMessagesScreenState(
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

        emit(const InConversationsListMessagesScreenState(
            isLoading: false,
            snackbarMessage: 'Użytkownik został zablokowany!'));
      },
    );

    on<GoToConversationFromPushMessageMessagesScreenEvent>(
      (event, emit) async {
        if (connectivityManager.status == ConnectivityResult.none) {
          emit(const InConversationsListMessagesScreenState(
            isLoading: false,
            databaseError: DatabaseErrorNetworkRequestFailed(),
          ));
          return;
        }

        emit(const InConversationsListMessagesScreenState(isLoading: true));

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(
            const InConversationsListMessagesScreenState(
              isLoading: false,
              databaseError: DatabaseErrorUserNotFound(),
            ),
          );
          return;
        }

        try {
          final conversation = await databaseManager.getConversation(
              conversationID: event.conversationID);

          final announcement = await databaseManager.getAnnouncement(
              id: conversation.announcementID);

          final userProfile =
              await databaseManager.getUserProfile(id: user.uid);

          await databaseManager.updateLastActivityInConversation(
            currentUserID: user.uid,
            giverID: announcement.giverID,
            conversationID: conversation.conversationID,
          );

          emit(InConversationMessagesScreenState(
            isLoading: false,
            conversation: conversation,
            announcement: announcement,
            userProfile: userProfile,
          ));
        } on FirebaseException catch (e) {
          emit(
            InConversationsListMessagesScreenState(
              isLoading: false,
              databaseError: DatabaseError.from(e),
            ),
          );
        }
      },
    );
  }
}
