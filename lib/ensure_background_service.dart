import 'dart:io';
import 'package:flutter/services.dart';

class EnsureBackgroundService {
  static const MethodChannel _channel =
      MethodChannel('venta_cuba/background_service');

  /// Check if background service is running and restart if needed
  static Future<void> ensureServiceRunning(String userId) async {
    if (!Platform.isAndroid) return;

    try {
      final bool isRunning = await _channel.invokeMethod('isServiceRunning');

      if (!isRunning) {
        await _channel.invokeMethod('startService', {
          'userId': userId,
          'serverUrl': 'https://ntfy.sh',
        });
      } else {}
    } catch (e) {}
  }

  /// Force restart the background service
  static Future<void> restartService(String userId) async {
    if (!Platform.isAndroid) return;

    try {
      // Stop the service first
      await _channel.invokeMethod('stopService');

      // Wait a moment
      await Future.delayed(Duration(seconds: 1));

      // Start it again
      await _channel.invokeMethod('startService', {
        'userId': userId,
        'serverUrl': 'https://ntfy.sh',
      });
    } catch (e) {}
  }
}
