import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Utils/funcations.dart';
import 'ntfy_push_service.dart';
import '../Supabase/supabase_service.dart';

/// Simplified Platform Push Service for Cross-Platform Notifications
class PlatformPushService {
  static String? _currentUserId;
  static bool _isChatScreenOpen = false;
  static String? _currentChatId;

  /// Initialize push service for current platform
  static Future<void> initialize(String userId) async {
    try {
      _currentUserId = userId;

      if (Platform.isIOS) {
        await _initializeIOSPush(userId);
      } else if (Platform.isAndroid) {
        await _initializeAndroidPush(userId);
      }
    } catch (e) {
      errorAlertToast('🔥 Platform Push Service initialization failed: $e');
      // Don't rethrow - handle gracefully
    }
  }

  /// Initialize iOS with Cuba-friendly notifications
  static Future<void> _initializeIOSPush(String userId) async {
    try {
      // For iOS without Firebase, use local notifications and generate a unique identifier
      final token = 'ios_cuba_${userId}_${DateTime.now().millisecondsSinceEpoch}';
      
      print('🍎 Generated Cuba-friendly iOS token: ${token.substring(0, 20)}...');
      
      // Save token to Supabase
      await _saveTokenToSupabase(userId, token, 'ios');
      
      print('✅ iOS Cuba-friendly push initialized for user: $userId');
    } catch (e) {
      print('❌ Error initializing iOS push: $e');
      errorAlertToast('❌ Error initializing iOS push: $e');
    }
  }

  /// Generate Cuba-friendly token for iOS
  static String _generateCubaIOSToken(String userId) {
    return 'ios_cuba_${userId}_${DateTime.now().millisecondsSinceEpoch}';
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
        // iOS: Use local notification system (Cuba-friendly)
        print('🍎 Sending Cuba-friendly notification to iOS user');

        // For Cuba, we'll use the ntfy system for iOS as well since Firebase is not available
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
          print('✅ Cuba-friendly notification sent successfully to iOS user');
        } else {
          print('❌ Cuba-friendly notification failed for iOS user');
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

  /// Get notification token (Cuba-friendly)
  static Future<String?> getFCMToken() async {
    try {
      if (Platform.isIOS && _currentUserId != null) {
        return _generateCubaIOSToken(_currentUserId!);
      } else if (_currentUserId != null) {
        return 'venta_cuba_user_$_currentUserId';
      }
      return null;
    } catch (e) {
      print('❌ Error getting notification token: $e');
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
