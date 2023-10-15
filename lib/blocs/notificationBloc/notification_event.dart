import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart' show immutable;

@immutable
abstract class NotificationEvent {
  const NotificationEvent();
}

@immutable
class NewNotificationArrivedEvent implements NotificationEvent {
  final RemoteMessage message;
  const NewNotificationArrivedEvent({required this.message});
}

@immutable
class NotificationInitializeEvent implements NotificationEvent {
  const NotificationInitializeEvent();
}

@immutable
class StartMonitoring implements NotificationEvent {
  const StartMonitoring();
}
