import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' show immutable;
import 'package:planted/models/message.dart';

@immutable
class Conversation {
  final String announcementID;
  final String conversationID;
  final String giver;
  final String taker;
  final Timestamp timeStamp;
  final List<Message> messages;

  const Conversation({
    required this.announcementID,
    required this.conversationID,
    required this.giver,
    required this.taker,
    required this.timeStamp,
    required this.messages,
  });

  factory Conversation.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    final List<dynamic> messageList = data['messages'] ?? [];

    return Conversation(
      announcementID: data['announcementID'],
      conversationID: data['conversationID'],
      giver: data['giver'],
      taker: data['taker'],
      timeStamp: data['timeStamp'],
      messages: messageList.map((messageData) {
        return Message.fromMap(messageData);
      }).toList(),
    );
  }
}
