import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'ntfy_push_service.dart';
import 'android_background_service.dart';

/// Platform-specific Push Service
/// 
/// This service provides unified push notifications:
/// - iOS: Uses Firebase Cloud Messaging (FCM) - works in background
/// - Android: Tries Firebase first (background support), falls back to ntfy.sh (foreground only)
/// 
/// IMPORTANT: ntfy.sh WebSocket only works when app is running!
/// For background notifications on Android, use server-side HTTP push to ntfy.sh
class PlatformPushService {
  static bool _isInitialized = false;
  static String? _currentUserId;
  static bool _isChatScreenOpen = false;
  static String? _currentChatId;
  
  /// Initialize the platform-specific push service
  static Future<void> initialize(String userId) async {
    try {
      print('🔔 Initializing Platform Push Service for user: $userId');
      _currentUserId = userId;
      
      if (Platform.isIOS) {
        // Initialize Firebase for iOS
        await _initializeFirebase(userId);
      } else if (Platform.isAndroid) {
        // For older Chinese phones: Use background service + ntfy WebSocket
        print('📱 Detected Android - Starting background ntfy service');
        
        // Start native background service for terminated app notifications
        final backgroundStarted = await AndroidBackgroundService.startService(userId: userId);
        
        if (backgroundStarted) {
          print('✅ Background service started - notifications work when app is terminated');
        } else {
          print('⚠️ Background service failed - falling back to foreground only');
        }
        
        // Also initialize foreground WebSocket for instant notifications when app is open
        await _initializeNtfy(userId);
        
        // Keep background service running for when app gets terminated
        print('📱 App is open - background service will continue running for when app terminates');
      }
      
      _isInitialized = true;
      print('✅ Platform Push Service initialized successfully');
    } catch (e) {
      print('❌ Error initializing Platform Push Service: $e');
    }
  }
  
  /// Initialize Firebase for iOS
  static Future<void> _initializeFirebase(String userId) async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp();
      
      // Request notification permissions
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ ' + 'iOS notification permissions granted'.tr);
        
        // Get FCM token
        final token = await messaging.getToken();
        print('📱 FCM Token: $token');
        
        // Configure foreground notifications
        await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
        
        // Listen for foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        
        // Handle notification taps
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
        
        // Handle background messages
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
        
        print('✅ Firebase initialized for iOS');
      } else {
        print('❌ ' + 'iOS notification permissions denied'.tr);
      }
    } catch (e) {
      print('❌ Error initializing Firebase: $e');
    }
  }
  
  /// Initialize ntfy for Android
  static Future<void> _initializeNtfy(String userId) async {
    try {
      await NtfyPushService.initialize(userId: userId);
      print('✅ ntfy initialized for Android');
    } catch (e) {
      print('❌ Error initializing ntfy: $e');
    }
  }
  
  /// Handle foreground messages on iOS
  static void _handleForegroundMessage(RemoteMessage message) {
    print('📨 Received foreground message: ${message.notification?.title}');
    
    // Don't show notification if chat screen is open and it's the same chat
    if (_isChatScreenOpen && message.data['chatId'] == _currentChatId) {
      print('🔇 Chat screen is open, skipping notification');
      return;
    }
    
    // Show notification
    _showIOSNotification(message);
  }
  
  /// Handle notification tap on iOS
  static void _handleNotificationTap(RemoteMessage message) {
    print('👆 Notification tapped: ${message.data}');
    
    if (message.data['chatId'] != null) {
      final chatId = message.data['chatId'];
      // Navigate to chat screen
      Get.toNamed('/chat', arguments: {'chatId': chatId});
    }
  }
  
  /// Show iOS notification
  static void _showIOSNotification(RemoteMessage message) {
    // iOS handles this automatically, but we can add custom logic here
    print('📱 Showing iOS notification: ${message.notification?.title}');
  }
  
  /// Send a chat notification
  static Future<void> sendChatNotification({
    required String recipientUserId,
    required String senderName,
    required String message,
    required String messageType,
    required String chatId,
    String? fcmToken, // For iOS recipients
  }) async {
    try {
      if (Platform.isIOS && fcmToken != null) {
        // Send via Firebase for iOS
        await _sendFirebaseNotification(
          token: fcmToken,
          title: senderName,
          body: _formatMessageBody(message, messageType),
          data: {
            'chatId': chatId,
            'type': 'chat',
          },
        );
      } else {
        // Send via ntfy for Android
        print('🔴 PLATFORM: Sending ntfy notification with chatId: "$chatId"');
        print('🔴 PLATFORM: Click action will be: "myapp://chat/$chatId"');
        
        await NtfyPushService.sendNotification(
          recipientUserId: recipientUserId,
          title: senderName,
          body: _formatMessageBody(message, messageType),
          clickAction: 'myapp://chat/$chatId',
          data: {
            'chatId': chatId,
            'type': 'chat',
          },
        );
      }
      
      print('✅ Chat notification sent successfully');
    } catch (e) {
      print('❌ Error sending chat notification: $e');
    }
  }
  
  /// Send Firebase notification (iOS)
  static Future<void> _sendFirebaseNotification({
    required String token,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    // Note: This would typically be done from your backend server
    // Here we're just logging what would be sent
    print('🔥 Would send Firebase notification:');
    print('   Token: $token');
    print('   Title: $title');
    print('   Body: $body');
    print('   Data: $data');
    
    // In a real implementation, you would call your backend API
    // which would use Firebase Admin SDK to send the notification
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
        return message;
    }
  }
  
  /// Set chat screen status (to prevent notifications when chat is open)
  static void setChatScreenStatus({required bool isOpen, String? chatId}) {
    print('testing 🔴 PLATFORM PUSH: setChatScreenStatus called - isOpen: $isOpen, chatId: $chatId');
    _isChatScreenOpen = isOpen;
    _currentChatId = chatId;
    
    if (Platform.isAndroid) {
      // Pass the chat screen status to ntfy service
      print('testing 🔴 PLATFORM PUSH: Calling NtfyPushService.setChatScreenStatus');
      NtfyPushService.setChatScreenStatus(isOpen: isOpen, chatId: chatId);
      print('📱 Chat screen ${isOpen ? 'opened' : 'closed'} for chat: $chatId');
    }
  }
  
  /// Get FCM token (iOS only)
  static Future<String?> getFCMToken() async {
    if (Platform.isIOS && _isInitialized) {
      try {
        final token = await FirebaseMessaging.instance.getToken();
        return token;
      } catch (e) {
        print('❌ Error getting FCM token: $e');
        return null;
      }
    }
    return null;
  }
  
  /// Stop listening for push notifications
  static Future<void> stopListening() async {
    try {
      if (Platform.isAndroid) {
        // Stop foreground WebSocket only
        await NtfyPushService.dispose();
        
        // Keep background service running - it will detect app state automatically
        print('📱 App closing - background service will handle notifications');
      }
      
      _isInitialized = false;
      print('✅ Platform Push Service stopped successfully');
    } catch (e) {
      print('❌ Error stopping Platform Push Service: $e');
    }
  }
}

/// Background message handler for Firebase (iOS)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📨 Background message: ${message.notification?.title}');
}