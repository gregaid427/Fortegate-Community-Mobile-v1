// lib/appcore/service/network_service.dart

import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  static Future<bool> hasConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  static Stream<ConnectivityResult> get onConnectivityChanged {
    return Connectivity().onConnectivityChanged;
  }
}