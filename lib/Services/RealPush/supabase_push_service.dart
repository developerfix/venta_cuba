import 'package:venta_cuba/Services/RealPush/platform_push_service.dart';

/// Push Service Wrapper
/// 
/// This service provides a simplified interface for push notifications.
/// Uses platform-specific implementations:
/// - iOS: Firebase Cloud Messaging
/// - Android: ntfy.sh for Cuba compatibility
class SupabasePushService {
  // Removed Supabase dependency - using platform-specific push services
  
  /// Initialize the push service with user ID
  static Future<void> initialize(String userId) async {
    try {
      print('🔔 Initializing Push Service for user: $userId');
      
      // Initialize the platform-specific push service
      await PlatformPushService.initialize(userId);
      
      print('✅ Push Service initialized successfully');
    } catch (e) {
      print('❌ Error initializing Push Service: $e');
    }
  }
  
  /// Stop listening for push notifications
  static Future<void> stopListening() async {
    try {
      print('🔔 Stopping Push Service...');
      
      // Dispose the platform-specific push service
      await PlatformPushService.stopListening();
      
      print('✅ Push Service stopped successfully');
    } catch (e) {
      print('❌ Error stopping Push Service: $e');
    }
  }
  
  /// Send a chat notification to a user
  static Future<void> sendChatNotification({
    required String recipientUserId,
    required String senderName,
    required String message,
    required String messageType,
    required String chatId,
  }) async {
    try {
      // Send via platform-specific service
      await PlatformPushService.sendChatNotification(
        recipientUserId: recipientUserId,
        senderName: senderName,
        message: message,
        messageType: messageType,
        chatId: chatId,
      );
      
      print('✅ Chat notification sent successfully');
    } catch (e) {
      print('❌ Error sending chat notification: $e');
    }
  }
  
  /// Set chat screen status to prevent notifications when chat is open (Android)
  static void setChatScreenStatus({required bool isOpen, String? chatId}) {
    print('testing 🔴 SUPABASE PUSH: setChatScreenStatus called - isOpen: $isOpen, chatId: $chatId');
    PlatformPushService.setChatScreenStatus(isOpen: isOpen, chatId: chatId);
  }
  
  /// Get FCM token for iOS users
  static Future<String?> getFCMToken() async {
    return await PlatformPushService.getFCMToken();
  }
  
  // All Supabase storage methods removed - using only real-time notifications
}
