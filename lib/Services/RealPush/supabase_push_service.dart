import 'package:venta_cuba/Services/RealPush/ntfy_push_service.dart';

/// Push Service Wrapper
/// 
/// This service provides a simplified interface for push notifications.
/// Uses ntfy.sh for real-time notifications without persistence.
class SupabasePushService {
  // Removed Supabase dependency - using only ntfy for real-time notifications
  
  /// Initialize the push service with user ID
  static Future<void> initialize(String userId) async {
    try {
      print('🔔 Initializing Push Service for user: $userId');
      
      // Initialize the ntfy push service
      await NtfyPushService.initialize(userId: userId);
      
      print('✅ Push Service initialized successfully');
    } catch (e) {
      print('❌ Error initializing Push Service: $e');
    }
  }
  
  /// Stop listening for push notifications
  static Future<void> stopListening() async {
    try {
      print('🔔 Stopping Push Service...');
      
      // Dispose the ntfy push service
      await NtfyPushService.dispose();
      
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
      // Prepare notification title and body
      final String title = senderName;
      String body = message;
      
      if (messageType == 'image') {
        body = '📷 Photo';
      } else if (messageType == 'video') {
        body = '📹 Video';
      } else if (messageType == 'file') {
        body = '📎 File';
      }
      
      // Send real-time notification via ntfy (no storage)
      await NtfyPushService.sendNotification(
        recipientUserId: recipientUserId,
        title: title,
        body: body,
        clickAction: 'myapp://chat/$chatId',
        data: {
          'chatId': chatId,
          'type': 'chat',
        },
      );
      
      print('✅ Chat notification sent successfully');
    } catch (e) {
      print('❌ Error sending chat notification: $e');
    }
  }
  
  // All Supabase storage methods removed - using only real-time notifications
}
