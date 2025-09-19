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

      await _initializePush(userId);
    } catch (e) {
      // Don't rethrow - handle gracefully
    }
  }

  /// Initialize iOS with Cuba-friendly notifications
  static Future<void> _initializeIOSPush(String userId) async {
    try {
      // For iOS without Firebase, use local notifications and generate a unique identifier
      final token =
          'ios_cuba_${userId}_${DateTime.now().millisecondsSinceEpoch}';

      print(
          '🍎 Generated Cuba-friendly iOS token: ${token.substring(0, 20)}...');

      // Save token to Supabase
      await _saveTokenToSupabase(userId, token, 'ios');

      print('✅ iOS Cuba-friendly push initialized for user: $userId');
    } catch (e) {
      print('❌ Error initializing iOS push: $e');
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
        );
      }
    } catch (e) {
      print('❌ Error saving token to Supabase: $e');
    }
  }

  /// Initialize Android with ntfy
  static Future<void> _initializePush(String userId) async {
    try {
      // Initialize ntfy service first
      await NtfyPushService.initialize(userId: userId);

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

      // Send notification using ntfy (works on both iOS and Android)
      print('📱 Sending ntfy notification (Cross-platform)');

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
        print('✅ Cross-platform notification sent successfully');
      } else {
        print('❌ Cross-platform notification failed');
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

    NtfyPushService.setChatScreenStatus(isOpen: isOpen, chatId: chatId);
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

      await _initializePush(userId);

      print('✅ Device token refreshed');
    } catch (e) {
      print('❌ Error refreshing device token: $e');
    }
  }

  /// Cancel notifications for a specific chat
  static Future<void> cancelChatNotifications(String chatId) async {
    try {
      print('🗑️ Canceling notifications for chat: $chatId');

      // Use ntfy service to cancel local notifications
      await NtfyPushService.cancelChatNotifications(chatId);

      print('✅ Chat notifications canceled');
    } catch (e) {
      print('❌ Error canceling chat notifications: $e');
    }
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    try {
      print('🗑️ Canceling all notifications');

      // Use ntfy service to cancel all local notifications
      await NtfyPushService.cancelAllNotifications();

      print('✅ All notifications canceled');
    } catch (e) {
      print('❌ Error canceling all notifications: $e');
    }
  }
}
