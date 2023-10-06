import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
class UserProfile {
  final String displayName;
  final String photoURL;
  final String userID;
  final List<String> blockedUsers;
  final List<String> userReports;
  final String fcmToken;
  final bool isAdmin;

  const UserProfile({
    required this.displayName,
    required this.photoURL,
    required this.userID,
    required this.blockedUsers,
    required this.userReports,
    required this.isAdmin,
    required this.fcmToken,
  });

  factory UserProfile.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserProfile(
      displayName: data['displayName'],
      photoURL: data['photoURL'] ?? '',
      userID: data['userID'],
      blockedUsers: List<String>.from(data['blockedUsers'] ?? []),
      userReports: List<String>.from(data['userReports'] ?? []),
      isAdmin: data['isAdmin'] ?? false,
      fcmToken: data['fcmToken'] ?? '',
    );
  }
}
