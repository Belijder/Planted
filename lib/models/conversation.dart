import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' show immutable;
import 'package:planted/models/message.dart';

@immutable
class Conversation {
  final String announcementID;
  final String conversationID;
  final String announcementName;
  final String giver;
  final String taker;
  final Timestamp timeStamp;
  final String giverDisplayName;
  final String takerDisplayName;
  final String giverPhotoURL;
  final String takerPhotoURL;
  final Timestamp giverLastActivity;
  final Timestamp takerLastActivity;
  final List<Message> messages;

  const Conversation({
    required this.announcementID,
    required this.conversationID,
    required this.announcementName,
    required this.giver,
    required this.taker,
    required this.timeStamp,
    required this.giverDisplayName,
    required this.takerDisplayName,
    required this.giverPhotoURL,
    required this.takerPhotoURL,
    required this.messages,
    required this.giverLastActivity,
    required this.takerLastActivity,
  });

  factory Conversation.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    final List<dynamic> messageList = data['messages'] ?? [];

    return Conversation(
      announcementID: data['announcementID'],
      conversationID: data['conversationID'],
      announcementName: data['announcementName'],
      giver: data['giver'],
      taker: data['taker'],
      timeStamp: data['timeStamp'],
      giverDisplayName: data['giverDisplayName'],
      takerDisplayName: data['takerDisplayName'],
      giverPhotoURL: data['giverPhotoURL'],
      takerPhotoURL: data['takerPhotoURL'],
      giverLastActivity: data['giverLastActivity'],
      takerLastActivity: data['takerLastActivity'],
      messages: messageList.map((messageData) {
        return Message.fromMap(messageData);
      }).toList(),
    );
  }
}
