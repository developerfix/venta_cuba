import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Services/push_service.dart';
import 'Controllers/auth_controller.dart';

class PushNotificationTester extends StatelessWidget {
  const PushNotificationTester({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final currentUserId = authController.user?.userId?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Push Notification Tester'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Status',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('User ID: $currentUserId'),
                    Text(
                        'Connection: ${PushService.isConnected ? "✅ Connected" : "❌ Disconnected"}'),
                    if (PushService.connectionDuration != null)
                      Text(
                          'Connected for: ${PushService.connectionDuration!.inSeconds}s'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                print('🧪 Testing self notification...');
                await PushService.sendTestNotification();
                Get.snackbar(
                  'Test Sent',
                  'Check if you received a notification',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              child: Text('Send Test Notification to Self'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                print('🧪 Testing badge with count 5...');
                await PushService.testBadge(count: 5);
                Get.snackbar(
                  'Badge Test',
                  'Badge should show 5',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              child: Text('Test Badge (Count: 5)'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                print('🧹 Clearing badge...');
                await PushService.clearBadgeCount();
                Get.snackbar(
                  'Badge Cleared',
                  'Badge should be 0',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              child: Text('Clear Badge'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                print('🔄 Updating badge from unread messages...');
                await PushService.updateBadgeCount();
                Get.snackbar(
                  'Badge Updated',
                  'Badge updated from database',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              child: Text('Update Badge from Database'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                print('🔄 Reconnecting WebSocket...');
                await PushService.reconnect();
                Get.snackbar(
                  'Reconnecting',
                  'WebSocket reconnection initiated',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              child: Text('Reconnect WebSocket'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                print('🧹 Clearing test notifications...');
                await PushService.clearTestNotifications();
                Get.snackbar(
                  'Cleared',
                  'Test notifications cleared',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              child: Text('Clear Test Notifications'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                print('🔧 Force resetting badge...');
                await PushService.forceResetBadge();
                Get.snackbar(
                  'Reset',
                  'Badge force reset completed',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              child: Text('Force Reset Badge'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                // Send a real notification to another user (modify as needed)
                final testRecipientId = '488'; // Change to a real recipient ID
                if (testRecipientId != currentUserId) {
                  await PushService.sendChatNotification(
                    recipientUserId: testRecipientId,
                    senderName: 'Test Sender',
                    message: 'Test message from $currentUserId',
                    messageType: 'text',
                    chatId: 'test_chat_123',
                    senderId: currentUserId,
                  );
                  Get.snackbar(
                    'Sent',
                    'Notification sent to user $testRecipientId',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } else {
                  Get.snackbar(
                    'Error',
                    'Cannot send to yourself',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.withOpacity(0.8),
                    colorText: Colors.white,
                  );
                }
              },
              child: Text('Send to User 488 (Test)'),
            ),
          ],
        ),
      ),
    );
  }
}
