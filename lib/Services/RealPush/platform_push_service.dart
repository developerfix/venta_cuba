import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ntfy_push_service.dart';
import '../Supabase/supabase_service.dart';
import '../../Notification/firebase_messaging.dart';

/// Simplified Platform Push Service for Cross-Platform Notifications
class PlatformPushService {
  static String? _currentUserId;
  static bool _isChatScreenOpen = false;
  static String? _currentChatId;

  /// Initialize push service for current platform
  static Future<void> initialize(String userId) async {
    try {
      print(
          '🔔 Initializing Push Service for user: $userId on ${Platform.isAndroid ? "Android" : "iOS"}');
      _currentUserId = userId;

      if (Platform.isIOS) {
        await _initializeIOSPush(userId);
      } else if (Platform.isAndroid) {
        await _initializeAndroidPush(userId);
      }

      print('✅ Push Service initialized successfully');
    } catch (e) {
      print('❌ Error initializing Push Service: $e');
      // Don't rethrow - handle gracefully
    }
  }

  /// Initialize iOS with FCM - FIXED VERSION
  static Future<void> _initializeIOSPush(String userId) async {
    try {
      print('🍎 Starting iOS push initialization for user: $userId');

      final messaging = FirebaseMessaging.instance;

      // Request permissions first
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        print(
            '❌ iOS push notification permissions denied: ${settings.authorizationStatus}');
        return;
      }

      print('🍎 Waiting for APNS token registration...');
      // Wait a bit longer for APNS token to be registered
      await Future.delayed(Duration(seconds: 3));

      // Get FCM token with proper retry logic
      String? token = await _getIOSTokenWithRetry(messaging);

      if (token != null && token.isNotEmpty) {
        // Save token to Supabase
        await _saveTokenToSupabase(userId, token, 'ios');

        // Configure foreground presentation
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      } else {
        print('⚠️ Could not get FCM token for iOS user: $userId');
        // Try again in background
        _retryIOSTokenInBackground(userId);
      }
    } catch (e) {
      print('❌ Error initializing iOS push: $e');
      // Try again in background
      _retryIOSTokenInBackground(userId);
    }
  }

  /// Get iOS token with proper retry logic using Stack Overflow solution
  static Future<String?> _getIOSTokenWithRetry(
      FirebaseMessaging messaging) async {
    String? token;
    String errorDetails = '';

    // Check APNS token first (Stack Overflow solution)
    print('🔔 Checking APNS token availability...');
    String? apnsToken = await messaging.getAPNSToken();
    
    if (apnsToken != null) {
      print('✅ APNS token available immediately: ${apnsToken.substring(0, 20)}...');
      // Try to get FCM token now
      try {
        token = await messaging.getToken();
        if (token != null) {
          print('✅ Got FCM token with APNS ready: ${token.substring(0, 20)}...');
          return token;
        }
      } catch (e) {
        print('⚠️ FCM token failed despite APNS ready: $e');
        errorDetails = 'FCM failed with APNS ready: $e';
      }
    } else {
      print('⚠️ APNS token not ready, waiting...');
      // Wait and try again (Stack Overflow approach)
      await Future.delayed(Duration(seconds: 3));
      
      apnsToken = await messaging.getAPNSToken();
      if (apnsToken != null) {
        print('✅ APNS token available after delay: ${apnsToken.substring(0, 20)}...');
        try {
          token = await messaging.getToken();
          if (token != null) {
            print('✅ Got FCM token after APNS delay: ${token.substring(0, 20)}...');
            return token;
          }
        } catch (e) {
          print('⚠️ FCM token failed after APNS delay: $e');
          errorDetails = 'FCM failed after APNS delay: $e';
        }
      } else {
        print('⚠️ APNS token still not ready after delay');
        errorDetails = 'APNS token not available after delay';
      }
    }

    // Final retry loop if above approaches failed
    print('🔄 Entering retry loop for APNS token...');
    for (int i = 0; i < 5; i++) {
      try {
        apnsToken = await messaging.getAPNSToken();
        if (apnsToken != null) {
          print('✅ APNS token available on retry ${i + 1}: ${apnsToken.substring(0, 20)}...');
          
          // Try FCM token with APNS ready
          token = await messaging.getToken();
          if (token != null) {
            print('✅ Got FCM token on retry ${i + 1}: ${token.substring(0, 20)}...');
            return token;
          }
        }
      } catch (e) {
        errorDetails += '\nRetry ${i + 1}: $e';
        print('⚠️ Retry ${i + 1}/5 failed: $e');
      }

      if (i < 4) {
        await Future.delayed(Duration(milliseconds: 1000 + (i * 500)));
      }
    }

    // If we get here, everything failed
    final msg = 'Failed to get FCM token after all attempts. Details: $errorDetails';
    print('❌ $msg');
    _showErrorDialog("FCM Token Error", msg);
    throw Exception(msg);
  }

  /// Simple error dialog using GetX
  static void _showErrorDialog(String title, String message) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  /// Save token to Supabase with error handling
  static Future<void> _saveTokenToSupabase(
      String userId, String token, String platform) async {
    try {
      final supabase = SupabaseService.instance;
      bool success = await supabase.saveDeviceTokenWithPlatform(
        userId: userId,
        token: token,
        platform: platform,
      );

      if (success) {
        print(
            '✅ $platform token saved to Supabase: ${token.substring(0, 20)}... for user: $userId');
      } else {
        print('❌ Failed to save $platform token to Supabase for user: $userId');
        // Retry once after delay
        await Future.delayed(Duration(seconds: 2));
        await supabase.saveDeviceTokenWithPlatform(
          userId: userId,
          token: token,
          platform: platform,
        );
      }
    } catch (e) {
      print('❌ Error saving token to Supabase: $e');
    }
  }

  /// Retry iOS token in background
  static void _retryIOSTokenInBackground(String userId) {
    Future.delayed(Duration(seconds: 3), () async {
      try {
        print('🔄 Retrying iOS token fetch in background for user: $userId');

        final messaging = FirebaseMessaging.instance;
        String? token = await _getIOSTokenWithRetry(messaging);

        if (token != null) {
          await _saveTokenToSupabase(userId, token, 'ios');
        } else {
          // Try one more time after another delay
          await Future.delayed(Duration(seconds: 5));
          token = await messaging.getToken();
          if (token != null) {
            await _saveTokenToSupabase(userId, token, 'ios');
          }
        }
      } catch (e) {
        print('❌ Background iOS token retry failed: $e');
      }
    });
  }

  /// Initialize Android with ntfy
  static Future<void> _initializeAndroidPush(String userId) async {
    try {
      // Initialize ntfy service first
      await NtfyPushService.initialize(userId: userId);

      // Save Android platform info to Supabase with ntfy topic
      final ntfyTopic = 'venta_cuba_user_$userId';
      await _saveTokenToSupabase(userId, ntfyTopic, 'android');

      print(
          '✅ Android ntfy service initialized with topic: $ntfyTopic for user: $userId');
    } catch (e) {
      print('❌ Error initializing Android push: $e');
    }
  }

  /// Send chat notification to recipient (Cross-platform)
  static Future<void> sendChatNotification({
    required String recipientUserId,
    required String senderName,
    required String message,
    required String messageType,
    required String chatId,
    String? senderId,
  }) async {
    try {
      print('🔔 === CROSS-PLATFORM NOTIFICATION ===');
      print('🔔 From: ${senderId ?? _currentUserId} To: $recipientUserId');

      // Don't send notification to yourself
      if (recipientUserId == (senderId ?? _currentUserId)) {
        print('🔔 Skipping self-notification');
        return;
      }

      // Get recipient's device info from Supabase
      final supabaseService = SupabaseService.instance;

      // First try to get the device token directly
      final recipientToken =
          await supabaseService.getDeviceToken(recipientUserId);
      print(
          '🔔 Recipient token retrieved: ${recipientToken?.substring(0, 30) ?? "NULL"}...');

      // Determine platform based on token pattern
      String? recipientPlatform;
      if (recipientToken != null && recipientToken.isNotEmpty) {
        if (recipientToken.startsWith('venta_cuba_user_') ||
            recipientToken.startsWith('ntfy_user_')) {
          recipientPlatform = 'android';
        } else if (recipientToken.length > 50) {
          // FCM tokens are typically long strings
          recipientPlatform = 'ios';
        }
      }

      // If platform detection failed, try to get it explicitly
      if (recipientPlatform == null) {
        recipientPlatform =
            await supabaseService.getUserPlatform(recipientUserId);
      }

      print('🔔 Detected platform: ${recipientPlatform ?? "UNKNOWN"}');
      print(
          '🔔 Token pattern: ${recipientToken?.substring(0, 20) ?? "NO TOKEN"}...');

      // Send notification based on platform
      if (recipientPlatform == 'ios' &&
          recipientToken != null &&
          !recipientToken.startsWith('venta_cuba_user_') &&
          !recipientToken.startsWith('ntfy_user_')) {
        // iOS: Use FCM
        print('🍎 Sending FCM notification to iOS user');

        final fcmService = FCM();
        final success = await fcmService.sendNotificationFCM(
          userId: recipientUserId,
          remoteId: senderId ?? _currentUserId ?? '',
          name: senderName,
          deviceToken: recipientToken,
          title: senderName,
          body: _formatMessageBody(message, messageType),
          type: 'message',
          chatId: chatId,
        );

        if (success) {
          print('✅ FCM notification sent successfully to iOS user');
        } else {
          print('❌ FCM notification failed for iOS user');
        }
      } else {
        // Android: Use ntfy (default for Android or unknown)
        print('🤖 Sending ntfy notification to Android user');

        final success = await NtfyPushService.sendNotification(
          recipientUserId: recipientUserId,
          title: senderName,
          body: _formatMessageBody(message, messageType),
          clickAction: 'myapp://chat/$chatId',
          data: {
            'chatId': chatId,
            'senderId': senderId ?? _currentUserId ?? '',
            'type': 'chat'
          },
        );

        if (success) {
          print('✅ ntfy notification sent successfully to Android user');
        } else {
          print('❌ ntfy notification failed for Android user');
        }
      }
    } catch (e, stackTrace) {
      print('❌ Error in sendChatNotification: $e');
      print('❌ Stack trace: $stackTrace');
    }
  }

  /// Format message body based on type
  static String _formatMessageBody(String message, String messageType) {
    switch (messageType) {
      case 'image':
        return '📷 Photo';
      case 'video':
        return '📹 Video';
      case 'file':
        return '📎 File';
      case 'audio':
        return '🎵 Audio';
      default:
        return message.length > 100
            ? '${message.substring(0, 97)}...'
            : message;
    }
  }

  /// Set chat screen status
  static void setChatScreenStatus({required bool isOpen, String? chatId}) {
    _isChatScreenOpen = isOpen;
    _currentChatId = chatId;

    if (Platform.isAndroid) {
      NtfyPushService.setChatScreenStatus(isOpen: isOpen, chatId: chatId);
    }
  }

  /// Get FCM token (iOS only) - SIMPLIFIED VERSION
  static Future<String?> getFCMToken() async {
    try {
      if (Platform.isIOS) {
        final messaging = FirebaseMessaging.instance;
        return await _getIOSTokenWithRetry(messaging);
      }
      return null;
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Stop listening
  static Future<void> stopListening() async {
    if (Platform.isAndroid) {
      await NtfyPushService.dispose();
    }
    _currentUserId = null;
    _isChatScreenOpen = false;
    _currentChatId = null;
  }

  /// Re-register device token (for token refresh)
  static Future<void> refreshDeviceToken(String userId) async {
    try {
      print('🔔 Refreshing device token for user: $userId');

      if (Platform.isIOS) {
        await _initializeIOSPush(userId);
      } else {
        await _initializeAndroidPush(userId);
      }

      print('✅ Device token refreshed');
    } catch (e) {
      print('❌ Error refreshing device token: $e');
    }
  }
}
