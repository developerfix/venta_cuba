import 'dart:io';
import 'package:flutter/services.dart';

class EnsureBackgroundService {
  static const MethodChannel _channel = MethodChannel('venta_cuba/background_service');

  /// Check if background service is running and restart if needed
  static Future<void> ensureServiceRunning(String userId) async {
    if (!Platform.isAndroid) return;

    try {
      final bool isRunning = await _channel.invokeMethod('isServiceRunning');

      if (!isRunning) {
        print('🔄 Background service not running, starting it...');
        await _channel.invokeMethod('startService', {
          'userId': userId,
          'serverUrl': 'https://ntfy.sh',
        });
      } else {
        print('✅ Background service is already running');
      }
    } catch (e) {
      print('❌ Error checking background service: $e');
    }
  }

  /// Force restart the background service
  static Future<void> restartService(String userId) async {
    if (!Platform.isAndroid) return;

    try {
      print('🔄 Restarting background service...');

      // Stop the service first
      await _channel.invokeMethod('stopService');

      // Wait a moment
      await Future.delayed(Duration(seconds: 1));

      // Start it again
      await _channel.invokeMethod('startService', {
        'userId': userId,
        'serverUrl': 'https://ntfy.sh',
      });

      print('✅ Background service restarted');
    } catch (e) {
      print('❌ Error restarting background service: $e');
    }
  }
}