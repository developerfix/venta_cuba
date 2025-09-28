import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Services/push_service.dart';
import 'Controllers/auth_controller.dart';

/// Test widget to verify badge count functionality
class BadgeTestWidget extends StatelessWidget {
  const BadgeTestWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Badge Count Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Current Badge Count', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    Obx(() => Text(
                      '${authController.unreadMessageCount.value}',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    )),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                print('\n=== BADGE TEST: Updating badge count ===');
                await PushService.updateBadgeCount();
                print('=== Badge update complete ===\n');
              },
              child: Text('Refresh Badge Count'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                print('\n=== BADGE TEST: Clearing badge ===');
                await PushService.clearBadgeCount();
                print('=== Badge cleared ===\n');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text('Clear Badge'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                print('\n=== BADGE TEST: Debug test with count 5 ===');
                await PushService.debugTestBadge(5);
                print('=== Debug test complete ===\n');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text('Debug Test Badge 5'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                print('\n=== BADGE TEST: Debug test with count 1 ===');
                await PushService.debugTestBadge(1);
                print('=== Debug test complete ===\n');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: Text('Debug Test Badge 1'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                print('\n=== BADGE TEST: Force reset badge ===');
                await PushService.forceResetBadge();
                authController.unreadMessageCount.value = 0;
                authController.hasUnreadMessages.value = false;
                print('=== Force reset complete ===\n');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Force Reset Badge'),
            ),
            SizedBox(height: 20),
            Text(
              'Instructions:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '1. Send messages to test badge count\n'
              '2. Check if badge matches bottom nav count\n'
              '3. Use "Refresh" to update from database\n'
              '4. Use "Clear" when all messages are read\n'
              '5. Use "Test with 5" to test badge display\n'
              '6. Use "Force Reset" if badge gets stuck',
              style: TextStyle(fontSize: 14),
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text('Debug Info:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Obx(() => Text('Has Unread: ${authController.hasUnreadMessages.value}')),
                  Obx(() => Text('Controller Count: ${authController.unreadMessageCount.value}')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}