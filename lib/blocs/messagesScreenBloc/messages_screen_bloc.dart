import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_event.dart';
import 'package:planted/blocs/messagesScreenBloc/messages_screen_state.dart';
import 'package:planted/constants/firebase_paths.dart';
import 'package:planted/database_error.dart';
import 'package:planted/models/announcement.dart';
import 'package:planted/models/conversation.dart';
import 'package:planted/models/user_profile.dart';
import 'package:uuid/uuid.dart';

class MessagesScreenBloc
    extends Bloc<MessagesScreenEvent, MessagesScreenState> {
  final db = FirebaseFirestore.instance;
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

          final messageID = const Uuid().v4();
          final timeStamp = DateTime.timestamp();

          try {
            await db
                .collection(conversationsPath)
                .doc(event.conversationID)
                .update({
              'timeStamp': timeStamp,
              'takerLastActivity': timeStamp,
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
                databaseError: DatabaseError.from(e)));
          }
        } catch (e) {
          emit(const InConversationsListMessagesScreenState(
              isLoading: false, databaseError: DatabaseErrorUnknown()));
        }
      },
    );
  }
}
