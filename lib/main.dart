import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:planted/app.dart';
import 'package:planted/firebase_options.dart';
import 'package:planted/managers/conectivity_manager.dart';
import 'package:planted/managers/push_notifications_manager.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await PushNotificationManager().setupFlutterNotifications();
  PushNotificationManager().showFlutterNotification(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await PushNotificationManager().setupFlutterNotifications();
  await ConnectivityManager().checkConnectivity();

  runApp(
    const App(),
  );
}
