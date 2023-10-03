import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:planted/constants/firebase_paths.dart';
import 'package:planted/enums/announcement_action.dart';
import 'package:planted/models/announcement.dart';
import 'package:planted/models/conversation.dart';
import 'package:planted/models/user_profile.dart';
import 'package:uuid/uuid.dart';

class FirebaseDatabaseManager {
  FirebaseDatabaseManager._private();
  static final FirebaseDatabaseManager _instance =
      FirebaseDatabaseManager._private();
  factory FirebaseDatabaseManager() => _instance;

  final db = FirebaseFirestore.instance;

  Future<TaskSnapshot> putImageInStorage({
    required String childRef,
    required File file,
  }) async {
    try {
      return await FirebaseStorage.instance
          .ref(storageImagesRef)
          .child(childRef)
          .putFile(file);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserProfile> getUserProfile({required String id}) async {
    try {
      return await db
          .collection(profilesPath)
          .doc(id)
          .get()
          .then((snapshot) => UserProfile.fromSnapshot(snapshot));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addAnnouncement({
    required String name,
    required String latinName,
    required int seedCount,
    required String city,
    required String description,
    required String giverID,
    required File imageFile,
  }) async {
    final announcementId = const Uuid().v4();
    final timeStamp = DateTime.timestamp();

    try {
      final task = await putImageInStorage(
        childRef: announcementId,
        file: imageFile,
      );
      final imageURL = await task.ref.getDownloadURL();
      final currentUserInfo = await getUserProfile(id: giverID);

      final docData = {
        'docID': announcementId,
        'status': 0,
        'name': name,
        'latinName': latinName,
        'seedCount': seedCount,
        'city': city,
        'description': description,
        'timeStamp': timeStamp,
        'giverID': giverID,
        'imageURL': imageURL,
        'giverDisplayName': currentUserInfo.displayName,
        'giverPhotoURL': currentUserInfo.photoURL,
      };

      await db.collection(announcemensPath).doc(announcementId).set(docData);
      return;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteConversation({required String id}) async {
    try {
      await db.collection(conversationsPath).doc(id).delete();
      return;
    } catch (e) {
      rethrow;
    }
  }

  Future<Conversation?> checkIfConversationExist({
    required String giverID,
    required String takerID,
    required String announcementID,
  }) async {
    try {
      final conversationSnapshot = await db
          .collection(conversationsPath)
          .where('giver', isEqualTo: giverID)
          .where('taker', isEqualTo: takerID)
          .where('announcementID', isEqualTo: announcementID)
          .get();

      if (conversationSnapshot.docs.isNotEmpty) {
        return Conversation.fromSnapshot(conversationSnapshot.docs[0]);
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Conversation> createNewConversation({
    required Announcement announcement,
    required String userID,
  }) async {
    final conversationID = const Uuid().v4();
    final timeStamp = DateTime.timestamp();
    try {
      final userProfile = await getUserProfile(id: userID);

      await db.collection(conversationsPath).doc(conversationID).set({
        'conversationID': conversationID,
        'announcementID': announcement.docID,
        'announcementName': announcement.name,
        'giver': announcement.giverID,
        'taker': userID,
        'timeStamp': timeStamp,
        'messages': [],
        'giverDisplayName': announcement.giverDisplayName,
        'takerDisplayName': userProfile.displayName,
        'giverPhotoURL': announcement.giverPhotoURL,
        'takerPhotoURL': userProfile.photoURL,
        'giverLastActivity': announcement.timeStamp,
        'takerLastActivity': timeStamp,
      });

      return Conversation(
        announcementID: announcement.docID,
        conversationID: conversationID,
        announcementName: announcement.name,
        giver: announcement.giverID,
        taker: userID,
        timeStamp: Timestamp.fromDate(timeStamp),
        giverDisplayName: announcement.giverDisplayName,
        takerDisplayName: userProfile.displayName,
        giverPhotoURL: announcement.giverPhotoURL,
        takerPhotoURL: userProfile.photoURL,
        messages: const [],
        giverLastActivity: announcement.timeStamp,
        takerLastActivity: Timestamp.fromDate(timeStamp),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendMessage({
    required Conversation conversation,
    required String sender,
    required String message,
  }) async {
    final messageID = const Uuid().v4();
    final timeStamp = DateTime.timestamp();

    final String userActivityField = (sender == conversation.giver)
        ? 'giverLastActivity'
        : 'takerLastActivity';

    try {
      await db
          .collection(conversationsPath)
          .doc(conversation.conversationID)
          .update({
        'timeStamp': timeStamp,
        userActivityField: timeStamp,
        'messages': FieldValue.arrayUnion([
          {
            'id': messageID,
            'message': message.trim(),
            'timeStamp': timeStamp,
            'sender': sender,
          },
        ])
      });

      return;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addUserToBlockedUsersList({
    required String currentUserID,
    required String userToBlockID,
  }) async {
    try {
      await db.collection(profilesPath).doc(currentUserID).update({
        'blockedUsers': FieldValue.arrayUnion([userToBlockID])
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<Announcement> getAnnouncement({
    required String id,
  }) async {
    try {
      return await db
          .collection(announcemensPath)
          .doc(id)
          .get()
          .then((snapshot) => Announcement.fromSnapshot(snapshot));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateLastActivityInConversation({
    required String currentUserID,
    required String giverID,
    required String conversationID,
  }) async {
    final timeStamp = DateTime.timestamp();
    final String userActivityField;
    if (currentUserID == giverID) {
      userActivityField = 'giverLastActivity';
    } else {
      userActivityField = 'takerLastActivity';
    }
    try {
      await db.collection(conversationsPath).doc(conversationID).update({
        userActivityField: timeStamp,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<AnnouncementAction> archiveOrDeleteAnnouncement({
    required String userID,
    required String announcementID,
  }) async {
    try {
      final aggregateQuerySnapshot = await db
          .collection(conversationsPath)
          .where(
            Filter.or(
              Filter('giver', isEqualTo: userID),
              Filter('taker', isEqualTo: userID),
            ),
          )
          .where('announcementID', isEqualTo: announcementID)
          .count()
          .get();

      if (aggregateQuerySnapshot.count > 0) {
        await db
            .collection(announcemensPath)
            .doc(announcementID)
            .update({'status': 3});
        return AnnouncementAction.archived;
      } else {
        await db.collection(announcemensPath).doc(announcementID).delete();
        await FirebaseStorage.instance
            .ref(storageImagesRef)
            .child(announcementID)
            .delete();
        return AnnouncementAction.deleted;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAnnouncement({
    required String announcementID,
  }) async {
    await db.collection(announcemensPath).doc(announcementID).delete();
    await FirebaseStorage.instance
        .ref(storageImagesRef)
        .child(announcementID)
        .delete();
  }

  Future<void> unblockUser({
    required String currentUserID,
    required String userToUnblockID,
  }) async {
    await db.collection(profilesPath).doc(currentUserID).update({
      'blockedUsers': FieldValue.arrayRemove([userToUnblockID])
    });
  }

  Future<String> getPathToLegalTerms({required String documentID}) async {
    return await db
        .collection(legaltermsPath)
        .doc(documentID)
        .get()
        .then((snapshot) => snapshot.data()?['path'] as String);
  }
}
