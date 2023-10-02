import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:planted/app.dart';
import 'package:planted/firebase_options.dart';
import 'package:planted/managers/conectivity_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await ConnectivityManager().checkConnectivity();

  runApp(
    const App(),
  );
}
