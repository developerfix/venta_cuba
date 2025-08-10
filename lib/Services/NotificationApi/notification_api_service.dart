import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:venta_cuba/api/api_client.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';

class NotificationApiService {
  static final NotificationApiService _instance = NotificationApiService._internal();
  factory NotificationApiService() => _instance;
  NotificationApiService._internal();

  final String baseUrl = 'https://ventacuba.co/api';
  
  /// Send chat notification through Laravel backend
  Future<bool> sendChatNotification({
    required String userId,
    required String senderName,
    required String message,
    required String messageType,
    required String chatId,
    required String senderId,
  }) async {
    try {
      final authController = Get.find<AuthController>();
      final token = authController.user?.accessToken;
      
      if (token == null) {
        print('❌ No auth token available');
        return false;
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': userId,
          'sender_name': senderName,
          'message': message,
          'message_type': messageType,
          'chat_id': chatId,
          'sender_id': senderId,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Notification sent successfully: ${data['notification_id']}');
        return true;
      } else {
        print('❌ Failed to send notification: ${response.statusCode}');
        print('❌ Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending notification: $e');
      return false;
    }
  }
  
  /// Send bulk notification through Laravel backend
  Future<bool> sendBulkNotification({
    required List<String> userIds,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      final authController = Get.find<AuthController>();
      final token = authController.user?.accessToken;
      
      if (token == null) {
        print('❌ No auth token available');
        return false;
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/bulk'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_ids': userIds,
          'title': title,
          'message': message,
          'data': data ?? {},
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Bulk notification sent to ${data['recipients']} users');
        return true;
      } else {
        print('❌ Failed to send bulk notification: ${response.statusCode}');
        print('❌ Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending bulk notification: $e');
      return false;
    }
  }
}

// Usage example in chat_page.dart:
/*
// Replace the direct OneSignal/Firebase notification sending with:
await NotificationApiService().sendChatNotification(
  userId: widget.remoteUid!,
  senderName: "${authCont.user?.firstName} ${authCont.user?.lastName}",
  message: message,
  messageType: messageType,
  chatId: widget.chatId ?? '',
  senderId: authCont.user!.userId.toString(),
);
*/
