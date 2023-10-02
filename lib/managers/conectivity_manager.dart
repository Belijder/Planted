import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityManager {
  late ConnectivityResult status;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  // Private constructor
  ConnectivityManager._private() {
    status = ConnectivityResult.none;
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      status = result;
    });
  }
  // Singleton instance
  static final ConnectivityManager _instance = ConnectivityManager._private();

  // Factory constructor to provide access to the Singleton instance
  factory ConnectivityManager() => _instance;

  Future<void> checkConnectivity() async {
    status = await Connectivity().checkConnectivity();
  }

  void dispose() {
    _connectivitySubscription.cancel();
  }
}
