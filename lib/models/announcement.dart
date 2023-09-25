import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' show immutable;

@immutable
class Announcement {
  final String city;
  final String description;
  final String docID;
  final String giverID;
  final String latinName;
  final String name;
  final int seedCount;
  final Timestamp timeStamp;
  final String imageURL;
  final String giverDisplayName;
  final String giverPhotoURL;
  final bool isActiv;

  const Announcement({
    required this.city,
    required this.description,
    required this.docID,
    required this.giverID,
    required this.latinName,
    required this.name,
    required this.seedCount,
    required this.timeStamp,
    required this.imageURL,
    required this.giverDisplayName,
    required this.giverPhotoURL,
    required this.isActiv,
  });

  factory Announcement.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Announcement(
      city: data['city'],
      description: data['description'] ?? "Brak dodatkowego opisu",
      docID: data['docID'],
      giverID: data['giverID'],
      latinName: data['latinName'],
      name: data['name'],
      seedCount: data['seedCount'],
      timeStamp: data['timeStamp'],
      imageURL: data['imageURL'],
      giverDisplayName: data['giverDisplayName'],
      giverPhotoURL: data['giverPhotoURL'],
      isActiv: data['isActiv'],
    );
  }
}
