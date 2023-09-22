import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_event.dart';
import 'package:planted/blocs/browseScreenBloc/browse_screen_state.dart';
import 'package:planted/constants/firebase_paths.dart';
import 'package:planted/database_error.dart';
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
          final conversation = await db
              .collection(conversationsPath)
              .where('giver', isEqualTo: event.announcement.giverID)
              .where('taker', isEqualTo: user.uid)
              .where('announcementID', isEqualTo: event.announcement.docID)
              .get();

          final String conversationID;
          final timeStamp = DateTime.timestamp();

          if (conversation.docs.isNotEmpty) {
            final conversationData = conversation.docs[0].data();
            conversationID = conversationData['conversationID'] as String;
          } else {
            conversationID = const Uuid().v4();

            await db.collection(conversationsPath).doc(conversationID).set({
              'conversationID': conversationID,
              'announcementID': event.announcement.docID,
              'giver': event.announcement.giverID,
              'taker': user.uid,
              'timeStamp': timeStamp,
              'messages': [],
            });
          }

          emit(InConversationViewBrowseScreenState(
            isLoading: false,
            user: user,
            announcement: event.announcement,
            conversationID: conversationID,
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
        emit(InConversationViewBrowseScreenState(
          isLoading: true,
          user: user,
          announcement: event.announcement,
          conversationID: event.conversationID,
        ));

        final messageID = const Uuid().v4();
        final timeStamp = DateTime.timestamp();

        try {
          await db
              .collection(conversationsPath)
              .doc(event.conversationID)
              .update({
            'messages': FieldValue.arrayUnion([
              {
                'id': messageID,
                'message': event.message,
                'timeStamp': timeStamp,
                'sender': user.uid,
              },
            ])
          });

          emit(InConversationViewBrowseScreenState(
            isLoading: false,
            user: user,
            announcement: event.announcement,
            conversationID: event.conversationID,
            messageSended: true,
          ));
        } on FirebaseException catch (e) {
          emit(InConversationViewBrowseScreenState(
            isLoading: false,
            user: user,
            announcement: event.announcement,
            conversationID: event.conversationID,
            databaseError: DatabaseError.from(e),
          ));
        }
      },
    );
  }
}