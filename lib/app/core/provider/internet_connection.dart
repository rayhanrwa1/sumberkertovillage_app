import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../../utils/snackbar_utils.dart';

class TInternetConnection {
  static final Connectivity _connectivity = Connectivity();

  static Future<bool> checkConnection(BuildContext context) async {
    final result = await _connectivity.checkConnectivity();

    if (result == ConnectivityResult.none) {
      TSnackbar.show(
        context,
        message: 'No internet connection',
        type: TSnackbarType.error,
      );
      return false;
    }

    try {
      final lookup = await InternetAddress.lookup('google.com');
      return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
    } catch (_) {
      TSnackbar.show(
        context,
        message:
            'Failed to connect to the server. Check your internet connection.',
        type: TSnackbarType.error,
      );
      return false;
    }
  }

  static Future<void> handleNoInternet(BuildContext context) async {
    final hasConnection = await checkConnection(context);
    if (!hasConnection) {
      // TODO: Navigate to No Internet Screen
      // Get.toNamed(Routes.NOINTERNET);
    }
  }

  static Stream<bool> connectivityStream() {
    return _connectivity.onConnectivityChanged.map(
      (result) => result != ConnectivityResult.none,
    );
  }
}
