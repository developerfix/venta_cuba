import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'ntfy_push_service.dart';
import '../Supabase/supabase_service.dart';
import '../../Notification/firebase_messaging.dart';

/// Simplified Platform Push Service
class PlatformPushService {
  static String? _currentUserId;
  static bool _isChatScreenOpen = false;
  static String? _currentChatId;

  /// Initialize push service for current platform
  static Future<void> initialize(String userId) async {
    try {
      print('🔔 Initializing Push Service for user: $userId on ${Platform.isAndroid ? "Android" : "iOS"}');
      _currentUserId = userId;

      if (Platform.isIOS) {
        await _initializeIOSPush(userId);
      } else if (Platform.isAndroid) {
        await _initializeAndroidPush(userId);
      }

      print('✅ Push Service initialized successfully');
    } catch (e) {
      print('❌ Error initializing Push Service: $e');
    }
  }

  /// Initialize iOS with FCM
  static Future<void> _initializeIOSPush(String userId) async {
    try {
      final messaging = FirebaseMessaging.instance;
      
      // Request permissions
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get FCM token
        final token = await messaging.getToken();
        
        if (token != null) {
          // Save token to Supabase with iOS platform
          final supabase = SupabaseService.instance;
          await supabase.saveDeviceTokenWithPlatform(
            userId: userId,
            token: token,
            platform: 'ios',
          );
          print('✅ iOS FCM token saved for user: $userId');
        }

        // Configure foreground presentation
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      print('❌ Error initializing iOS push: $e');
    }
  }

  /// Initialize Android with ntfy
  static Future<void> _initializeAndroidPush(String userId) async {
    try {
      // Save Android platform info to Supabase
      final supabase = SupabaseService.instance;
      await supabase.saveDeviceTokenWithPlatform(
        userId: userId,
        token: 'ntfy_user_$userId', // Using ntfy topic as identifier
        platform: 'android',
      );
      
      // Initialize ntfy service
      await NtfyPushService.initialize(userId: userId);
      
      print('✅ Android ntfy service initialized for user: $userId');
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
  }) async {
    try {
      print('🔔 Sending cross-platform notification to user: $recipientUserId');
      
      // Get recipient's platform from Supabase
      final supabaseService = SupabaseService.instance;
      final recipientPlatform = await supabaseService.getUserPlatform(recipientUserId);
      
      print('🔔 Recipient platform: $recipientPlatform');
      
      if (recipientPlatform == 'ios') {
        // Send FCM notification for iOS recipients
        print('🍎 Sending FCM notification to iOS user: $recipientUserId');
        
        final recipientToken = await supabaseService.getDeviceToken(recipientUserId);
        
        if (recipientToken != null && 
            recipientToken.isNotEmpty && 
            !recipientToken.startsWith('ntfy_user_') &&
            recipientToken != 'cuba-friendly-token') {
          
          final fcmService = FCM();
          await fcmService.sendNotificationFCM(
            userId: recipientUserId,
            remoteId: _currentUserId ?? '',
            name: senderName,
            deviceToken: recipientToken,
            title: senderName,
            body: _formatMessageBody(message, messageType),
            type: 'message',
            chatId: chatId,
          );
          print('✅ FCM notification sent to iOS user: $recipientUserId');
        } else {
          print('⚠️ No valid FCM token found for iOS user: $recipientUserId');
        }
      } else {
        // Send ntfy notification for Android recipients (default)
        print('🤖 Sending ntfy notification to Android user: $recipientUserId');
        
        await NtfyPushService.sendNotification(
          recipientUserId: recipientUserId,
          title: senderName,
          body: _formatMessageBody(message, messageType),
          clickAction: 'myapp://chat/$chatId',
          data: {'chatId': chatId, 'type': 'chat'},
        );
        print('✅ ntfy notification sent to Android user: $recipientUserId');
      }
    } catch (e) {
      print('❌ Error sending cross-platform chat notification: $e');
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
      default:
        return message.length > 100 ? '${message.substring(0, 100)}...' : message;
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

  /// Get FCM token (iOS only)
  static Future<String?> getFCMToken() async {
    try {
      if (Platform.isIOS) {
        final messaging = FirebaseMessaging.instance;
        final token = await messaging.getToken();
        print('🔔 Retrieved FCM token: ${token?.substring(0, 20)}...');
        return token;
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
  }
}
