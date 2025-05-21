import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<InternetConnectionStatus> get onInternetStatusChange;
  Stream<List<ConnectivityResult>> get onConnectivityTypeChange;
  Future<InternetConnectionStatus> get currentInternetStatus;
  Future<List<ConnectivityResult>> get currentConnectivityTypes;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;
  final Connectivity connectivity;

  NetworkInfoImpl(
      {required this.connectionChecker, required this.connectivity});

  @override
  Future<bool> get isConnected async {
    debugPrint("[NetworkInfoImpl] Checking isConnected...");
    final connectivityResultList = await connectivity.checkConnectivity();
    debugPrint("[NetworkInfoImpl] Connectivity types: $connectivityResultList");
    bool hasNetworkInterface =
        !connectivityResultList.contains(ConnectivityResult.none);

    if (!hasNetworkInterface) {
      debugPrint("[NetworkInfoImpl] No network interface. isConnected: false");
      return false;
    }
    final hasInternet = await connectionChecker.hasConnection;
    debugPrint(
        "[NetworkInfoImpl] Has network interface. Actual internet: $hasInternet. isConnected: $hasInternet");
    return hasInternet;
  }

  @override
  Future<InternetConnectionStatus> get currentInternetStatus async {
    debugPrint("[NetworkInfoImpl] Getting currentInternetStatus...");
    final status = await connectionChecker.connectionStatus;
    debugPrint("[NetworkInfoImpl] Current Internet Status: $status");
    return status;
  }

  @override
  Stream<InternetConnectionStatus> get onInternetStatusChange =>
      connectionChecker.onStatusChange;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityTypeChange =>
      connectivity.onConnectivityChanged;

  @override
  Future<List<ConnectivityResult>> get currentConnectivityTypes async {
    debugPrint("[NetworkInfoImpl] Getting currentConnectivityTypes...");
    final types = await connectivity.checkConnectivity();
    debugPrint("[NetworkInfoImpl] Current Connectivity Types: $types");
    return types;
  }
}
