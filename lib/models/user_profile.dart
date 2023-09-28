import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
class UserProfile {
  final String displayName;
  final String photoURL;
  final String userID;
  final List<String> blockedUsers;

  const UserProfile({
    required this.displayName,
    required this.photoURL,
    required this.userID,
    required this.blockedUsers,
  });

  factory UserProfile.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserProfile(
      displayName: data['displayName'],
      photoURL: data['photoURL'] ?? '',
      userID: data['userID'],
      blockedUsers: List<String>.from(data['blockedUsers'] ?? []),
    );
  }
}
