import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_event.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_state.dart';
import 'package:planted/constants/firebase_paths.dart';
import 'package:planted/database_error.dart';
import 'package:planted/models/conversation.dart';
import 'package:planted/models/user_profile.dart';
import 'package:uuid/uuid.dart';

class BrowseScreenBloc extends Bloc<BrowseScreenEvent, BrowseScreenState> {
  final db = FirebaseFirestore.instance;

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
        emit(
          InAnnouncementDetailsBrowseScreenState(
            announcement: event.announcement,
            isLoading: true,
          ),
        );
        try {
          await db
              .collection(conversationsPath)
              .doc(event.conversationID)
              .delete();
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

        try {
          final conversationSnapshot = await db
              .collection(conversationsPath)
              .where('giver', isEqualTo: event.announcement.giverID)
              .where('taker', isEqualTo: user.uid)
              .where('announcementID', isEqualTo: event.announcement.docID)
              .get();

          final Conversation conversation;
          final timeStamp = DateTime.timestamp();

          final snapshot =
              await db.collection(profilesPath).doc(user.uid).get();
          final userProfile = UserProfile.fromSnapshot(snapshot);

          if (conversationSnapshot.docs.isNotEmpty) {
            conversation =
                Conversation.fromSnapshot(conversationSnapshot.docs[0]);
          } else {
            final conversationID = const Uuid().v4();

            await db.collection(conversationsPath).doc(conversationID).set({
              'conversationID': conversationID,
              'announcementID': event.announcement.docID,
              'announcementName': event.announcement.name,
              'giver': event.announcement.giverID,
              'taker': user.uid,
              'timeStamp': timeStamp,
              'messages': [],
              'giverDisplayName': event.announcement.giverDisplayName,
              'takerDisplayName': userProfile.displayName,
              'giverPhotoURL': event.announcement.giverPhotoURL,
              'takerPhotoURL': userProfile.photoURL,
              'giverLastActivity': event.announcement.timeStamp,
              'takerLastActivity': timeStamp,
            });

            conversation = await db
                .collection(conversationsPath)
                .doc(conversationID)
                .get()
                .then((snapshot) => Conversation.fromSnapshot(snapshot));
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

        final messageID = const Uuid().v4();
        final timeStamp = DateTime.timestamp();

        try {
          await db
              .collection(conversationsPath)
              .doc(event.conversation.conversationID)
              .update({
            'timeStamp': timeStamp,
            'takerLastActivity': timeStamp,
            'messages': FieldValue.arrayUnion([
              {
                'id': messageID,
                'message': event.message.trim(),
                'timeStamp': timeStamp,
                'sender': user.uid,
              },
            ])
          });

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
        await db.collection(profilesPath).doc(event.currentUserID).update({
          'blockedUsers': FieldValue.arrayUnion([event.userToBlockID])
        });

        emit(const InAnnouncementsListViewBrowseScreenState(
            isLoading: false,
            snackbarMessage: 'Użytkownik został zablokowany!'));
      },
    );

    on<BlockUserFromDetailsViewBrowseScreenEvent>(
      (event, emit) async {
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
          await db.collection(profilesPath).doc(user.uid).update({
            'blockedUsers': FieldValue.arrayUnion([event.userToBlockID])
          });

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
