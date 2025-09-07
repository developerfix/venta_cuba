// Safe SharedPreferences initialization method
import 'dart:async';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:venta_cuba/main.dart';

Future<void> initializeSharedPreferences() async {
  late SharedPreferences prefs;
  // First try using global instance
  if (globalPrefs != null) {
    prefs = globalPrefs!;
    print('✅ SharedPreferences initialized from global instance');
    return;
  }

  int retries = 5; // Increased retries for real devices
  while (retries > 0) {
    try {
      // Add a delay before initialization to ensure platform channels are ready
      if (Platform.isIOS) {
        await Future.delayed(Duration(milliseconds: 500 * (6 - retries)));
      }

      prefs = await SharedPreferences.getInstance().timeout(
        Duration(seconds: 20), // Increased timeout for real devices
        onTimeout: () => throw TimeoutException(
            'SharedPreferences initialization timed out',
            Duration(seconds: 20)),
      );

      // More robust connection test
      try {
        // Force a reload to ensure connection
        await prefs.reload();
        // Try to read a value
        prefs.getString('test');
      } catch (e) {
        try {
          // If read fails, try to set and remove a test value
          await prefs.setBool('init_test', true);
          await prefs.remove('init_test');
        } catch (writeError) {
          // If both read and write fail, try to get instance again
          prefs = await SharedPreferences.getInstance();
          await prefs.reload();
        }
      }

      print('✅ SharedPreferences initialized successfully');
      // Update global instance
      globalPrefs = prefs;
      return;
    } catch (e) {
      retries--;
      print(
          '⚠️ SharedPreferences initialization failed, retries left: $retries, error: $e');
      if (retries > 0) {
        // Exponential backoff with longer delays for iOS
        int delayMs = Platform.isIOS
            ? 2000 * (6 - retries) // Much longer delays for iOS real devices
            : 1000 * (6 - retries);
        await Future.delayed(Duration(milliseconds: delayMs));
      } else {
        // Last resort: try to initialize without any operations
        try {
          prefs = await SharedPreferences.getInstance();
          globalPrefs = prefs;
          print('⚠️ SharedPreferences initialized in fallback mode');
          return;
        } catch (fallbackError) {
          throw Exception(
              'Failed to initialize SharedPreferences after all attempts: $e');
        }
      }
    }
  }
}
