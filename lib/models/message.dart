import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' show immutable;

@immutable
class Message {
  final String id;
  final String message;
  final String sender;
  final Timestamp timeStamp;

  const Message({
    required this.id,
    required this.message,
    required this.sender,
    required this.timeStamp,
  });

  factory Message.fromMap(Map<String, dynamic> data) {
    return Message(
      id: data['id'],
      message: data['message'],
      sender: data['sender'],
      timeStamp: data['timeStamp'],
    );
  }
}
