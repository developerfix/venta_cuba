import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/view/Chat/Controller/ChatController.dart';

/// Test widget to verify chat badge functionality
class ChatBadgeTest extends StatefulWidget {
  @override
  _ChatBadgeTestState createState() => _ChatBadgeTestState();
}

class _ChatBadgeTestState extends State<ChatBadgeTest> {
  final authCont = Get.find<AuthController>();
  final chatCont = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Badge Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chat Badge Functionality Test',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            
            // Display current unread count
            Obx(() => Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Status:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Unread Count: ${authCont.unreadMessageCount.value}'),
                    Text('Has Unread: ${authCont.hasUnreadMessages.value}'),
                    SizedBox(height: 16),
                    
                    // Badge preview
                    Text('Badge Preview:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Container(
                      width: 50,
                      height: 50,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.chat, color: Colors.white),
                          ),
                          if (authCont.unreadMessageCount.value > 0)
                            Positioned(
                              right: -6,
                              top: -6,
                              child: Container(
                                constraints: BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white, width: 1),
                                ),
                                child: Center(
                                  child: Text(
                                    authCont.unreadMessageCount.value > 99
                                        ? '99+'
                                        : authCont.unreadMessageCount.value.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
            
            SizedBox(height: 20),
            
            // Test buttons
            Text(
              'Test Actions:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: () async {
                await chatCont.updateUnreadMessageIndicators();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Refreshed unread count')),
                );
              },
              child: Text('Refresh Unread Count'),
            ),
            
            SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: () async {
                await chatCont.updateBadgeCountFromChats();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Updated badge count')),
                );
              },
              child: Text('Update Badge Count'),
            ),
            
            SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: () {
                chatCont.startListeningForChatUpdates();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Started chat listener')),
                );
              },
              child: Text('Start Chat Listener'),
            ),
            
            SizedBox(height: 20),
            
            // Manual test controls
            Text(
              'Manual Test Controls:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    authCont.unreadMessageCount.value++;
                  },
                  child: Text('+ Count'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (authCont.unreadMessageCount.value > 0) {
                      authCont.unreadMessageCount.value--;
                    }
                    authCont.hasUnreadMessages.value = authCont.unreadMessageCount.value > 0;
                  },
                  child: Text('- Count'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    authCont.unreadMessageCount.value = 0;
                    authCont.hasUnreadMessages.value = false;
                  },
                  child: Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
