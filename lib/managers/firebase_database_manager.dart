import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:planted/constants/firebase_paths.dart';
import 'package:planted/constants/enums/announcement_action.dart';
import 'package:planted/extensions/time_stamp_extensions.dart';
import 'package:planted/managers/push_notifications_manager.dart';
import 'package:planted/models/announcement.dart';
import 'package:planted/models/conversation.dart';
import 'package:planted/models/report.dart';
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

  Future<bool> isDisplayNameAvaileble({required String displayName}) async {
    try {
      final querySnapshot = await db
          .collection(profilesPath)
          .where('displayName', isEqualTo: displayName)
          .get();

      return querySnapshot.docs.isEmpty;
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

  Future<void> updateFcmTokenIfNeeded(
      {required String userID, required String? fcmToken}) async {
    if (fcmToken == null) {
      return;
    }
    try {
      final userProfile = await getUserProfile(id: userID);

      if (userProfile.fcmToken == fcmToken) {
        return;
      } else {
        await db.collection(profilesPath).doc(userID).update({
          'fcmToken': fcmToken,
        });
      }
    } catch (e) {
      return;
    }
  }

  Future<void> removeFcmToken({
    required String userID,
  }) async {
    try {
      await db.collection(profilesPath).doc(userID).update({
        'fcmToken': '',
      });
    } catch (e) {
      return;
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

  Future<Conversation> getConversation({required String conversationID}) async {
    try {
      return await db
          .collection(conversationsPath)
          .doc(conversationID)
          .get()
          .then((snapshot) => Conversation.fromSnapshot(snapshot));
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

    final cotalkerID = (sender == conversation.giver)
        ? conversation.taker
        : conversation.giver;

    final String userDisplayName = (sender == conversation.giver)
        ? conversation.giverDisplayName
        : conversation.takerDisplayName;

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

      final cotalkerUserProfile = await getUserProfile(id: cotalkerID);
      final token = cotalkerUserProfile.fcmToken;

      await PushNotificationManager().sendPushMessage(
        token: token,
        title: userDisplayName,
        body: message.trim(),
        conversationID: conversation.conversationID,
      );
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

  Future<void> changeStatusOfAnnouncement({
    required String announcementID,
    required int newStatus,
  }) async {
    try {
      await db
          .collection(announcemensPath)
          .doc(announcementID)
          .update({'status': newStatus});
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

  Future<void> sendReport({
    required Announcement announcement,
    required String? conversationID,
    required String reasonForReporting,
    required String additionalInformation,
    required String userID,
  }) async {
    final reportID = const Uuid().v4();
    final timeStamp = DateTime.timestamp();
    final data = {
      'reportID': reportID,
      'reportingPersonID': userID,
      'reportedPersonID': announcement.giverID,
      'reportedPersonDisplayName': announcement.giverDisplayName,
      'conversationID': conversationID ?? '',
      'announcementID': announcement.docID,
      'reasonForReporting': reasonForReporting,
      'additionalInformation': additionalInformation,
      'status': 0,
      'adminResponse': '',
      'reportingDate': timeStamp,
    };
    try {
      await db.collection(reportsPath).doc(reportID).set(data);
      await db.collection(profilesPath).doc(userID).update({
        'userReports': FieldValue.arrayUnion([reportID])
      });
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Announcement>> createAnnouncementsStreamWith(
      {required int status}) {
    return db
        .collection(announcemensPath)
        .where('status', isEqualTo: status)
        .orderBy('timeStamp', descending: true)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((docSnapshot) {
        return Announcement.fromSnapshot(docSnapshot);
      }).toList();
    });
  }

  Stream<List<Report>> createUserReportsStream({
    required String userID,
  }) {
    return db
        .collection(reportsPath)
        .where('reportingPersonID', isEqualTo: userID)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((docSnapshot) {
        return Report.fromSnapshot(docSnapshot);
      }).toList();
    });
  }

  Stream<List<Report>> createReportsStreamFor({
    required int status,
  }) {
    return db
        .collection(reportsPath)
        .where('status', isEqualTo: status)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((docSnapshot) {
        return Report.fromSnapshot(docSnapshot);
      }).toList();
    });
  }

  Stream<List<Conversation>> createConversationsStreamFor(
      {required String userID}) {
    return db
        .collection(conversationsPath)
        .where(
          Filter.or(
            Filter('giver', isEqualTo: userID),
            Filter('taker', isEqualTo: userID),
          ),
        )
        .orderBy('timeStamp', descending: true)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((docSnapshot) {
        return Conversation.fromSnapshot(docSnapshot);
      }).toList();
    });
  }

  Stream<Conversation> createConverationStreamFor(
      {required String conversationID}) {
    return db
        .collection(conversationsPath)
        .doc(conversationID)
        .snapshots()
        .map((docSnapshot) {
      return Conversation.fromSnapshot(docSnapshot);
    });
  }

  Stream<UserProfile>? createUserProfileStremFor({
    required String userID,
  }) {
    try {
      return db
          .collection(profilesPath)
          .doc(userID)
          .snapshots()
          .map((snapshot) => UserProfile.fromSnapshot(snapshot));
    } catch (e) {
      return null;
    }
  }

  Stream<List<Announcement>>? createUsersAnnouncementsStream({
    required String userID,
  }) {
    return db
        .collection(announcemensPath)
        .where('giverID', isEqualTo: userID)
        .orderBy('timeStamp', descending: true)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((docSnapshot) {
        return Announcement.fromSnapshot(docSnapshot);
      }).toList();
    });
  }

  // Check if its used
  Stream<List<String>> createBlockedUsersIDsStream(
      {required String currentUserID}) {
    return db
        .collection(profilesPath)
        .doc(currentUserID)
        .snapshots()
        .map((snapshot) => UserProfile.fromSnapshot(snapshot))
        .map((userProfile) => userProfile.blockedUsers);
  }

  Future<List<UserProfile>> getBlockedUsersProfiles(
      {required List<String> blockedUsersIDs}) async {
    try {
      final profileFutures = blockedUsersIDs.map((userId) {
        return getUserProfile(id: userId);
      }).toList();

      final profiles = await Future.wait(profileFutures);

      return profiles;
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<UserProfile>> createBlockedUsersProfilesStream(
      {required String currentUserID}) {
    final blockedUserIdsStream =
        createBlockedUsersIDsStream(currentUserID: currentUserID);

    return blockedUserIdsStream.asyncMap((blockedUserIds) async {
      final profiles =
          await getBlockedUsersProfiles(blockedUsersIDs: blockedUserIds);
      return profiles;
    });
  }

  Stream<Iterable<Conversation>> getUnreadConversationsIDsStreamFor(
      String userID) {
    return db
        .collection(conversationsPath)
        .where(
          Filter.or(
            Filter('giver', isEqualTo: userID),
            Filter('taker', isEqualTo: userID),
          ),
        )
        .orderBy('timeStamp', descending: true)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((docSnapshot) {
        return Conversation.fromSnapshot(docSnapshot);
      }).where((element) {
        if (element.giver == userID) {
          return element.giverLastActivity.isEarlierThan(element.timeStamp);
        } else {
          return element.takerLastActivity.isEarlierThan(element.timeStamp);
        }
      });
    });
  }
}
