import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_event.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_state.dart';
import 'package:planted/constants/firebase_paths.dart';
import 'package:planted/database_error.dart';
import 'package:planted/managers/conectivity_manager.dart';
import 'package:planted/models/announcement.dart';
import 'package:planted/models/conversation.dart';
import 'package:planted/models/user_profile.dart';
import 'package:uuid/uuid.dart';

class MessagesScreenBloc
    extends Bloc<MessagesScreenEvent, MessagesScreenState> {
  final db = FirebaseFirestore.instance;
  final connectivityManager = ConnectivityManager();

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

        final timeStamp = DateTime.timestamp();

        try {
          final announcement = await db
              .collection(announcemensPath)
              .doc(event.conversation.announcementID)
              .get()
              .then((snapshot) => Announcement.fromSnapshot(snapshot));

          final userProfile = await db
              .collection(profilesPath)
              .doc(user.uid)
              .get()
              .then((snapshot) => UserProfile.fromSnapshot(snapshot));

          final String userActivityField;
          if (userProfile.userID == event.conversation.giver) {
            userActivityField = 'giverLastActivity';
          } else {
            userActivityField = 'takerLastActivity';
          }

          await db
              .collection(conversationsPath)
              .doc(event.conversation.conversationID)
              .update({
            userActivityField: timeStamp,
          });

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

          final messageID = const Uuid().v4();
          final timeStamp = DateTime.timestamp();

          try {
            final String userActivityField;
            if (userProfile.userID == conversation.giver) {
              userActivityField = 'giverLastActivity';
            } else {
              userActivityField = 'takerLastActivity';
            }

            await db
                .collection(conversationsPath)
                .doc(event.conversationID)
                .update({
              'timeStamp': timeStamp,
              userActivityField: timeStamp,
              'messages': FieldValue.arrayUnion([
                {
                  'id': messageID,
                  'message': event.message.trim(),
                  'timeStamp': timeStamp,
                  'sender': userProfile.userID,
                },
              ])
            });

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
              isLoading: false, databaseError: DatabaseErrorUnknown()));
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
        await db.collection(profilesPath).doc(event.currentUserID).update({
          'blockedUsers': FieldValue.arrayUnion([event.userToBlockID])
        });

        emit(const InConversationsListMessagesScreenState(
            isLoading: false,
            snackbarMessage: 'Użytkownik został zablokowany!'));
      },
    );
  }
}
