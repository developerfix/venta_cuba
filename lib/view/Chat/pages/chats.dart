import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import '../Controller/SupabaseChatController.dart';
import '../custom_text.dart';
import '../widgets/group_tile.dart';

class Chats extends StatefulWidget {
  const Chats({Key? key}) : super(key: key);

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> with WidgetsBindingObserver {
  final authCont = Get.put(AuthController());
  final chatCont = Get.put(SupabaseChatController());
  String userName = "";
  String email = "";
  Stream<List<Map<String, dynamic>>>? chats;
  TextEditingController textEditingController = TextEditingController();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    // Add lifecycle observer to detect app state changes
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      gettingUserData();
      // Update badge count and unread indicators when chats page is loaded
      chatCont.updateBadgeCountFromChats();
      chatCont.updateUnreadMessageIndicators();
      // Force immediate refresh of chat lists
      chatCont.refreshAllChatLists();
    });

    // Start periodic refresh for real-time unread count updates
    _refreshTimer = Timer.periodic(Duration(seconds: 10), (_) {
      if (mounted) {
        chatCont.updateUnreadMessageIndicators();
        // Also refresh chat lists more frequently
        chatCont.refreshAllChatLists();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed && mounted) {
      print('🔄 Chat screen: App resumed - refreshing chat list');
      // Immediately refresh when app comes to foreground
      chatCont.refreshAllChatLists();
      chatCont.updateUnreadMessageIndicators();
      // Also refresh the local state
      gettingUserData();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(Chats oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh unread indicators when widget updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatCont.updateUnreadMessageIndicators();
    });
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  gettingUserData() async {
    try {
      if (authCont.user?.userId != null) {
        setState(() {
          chats = chatCont.getAllChats(authCont.user!.userId.toString());
        });
      }
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          title: CustomText(
            text: "Message".tr,
            fontSize: 20..sp,
            fontWeight: FontWeight.w700,
            fontColor: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        body: Column(
          children: [
            SizedBox(height: 2.h, child: Divider()),
            // Notification warning text - only show on iOS
            if (Platform.isIOS)
              Container(
                padding: EdgeInsets.all(8.0),
                margin: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  'Notifications won\'t work outside the app because of network restrictions'
                      .tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.orange[700],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(child: groupList()),
          ],
        ));
  }

  groupList() {
    if (chats == null) {
      return Center(
        child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor),
      );
    }

    return GetBuilder<AuthController>(
      builder: (authController) => StreamBuilder<List<Map<String, dynamic>>>(
        stream: chats,
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 16),
                  Text(
                    "🔥 Supabase Error",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          );
        }
        
        // make some checks
        if (snapshot.hasData) {
          if (snapshot.data != null) {
            if (snapshot.data!.length != 0) {
              // Filter and sort chats
              List<Map<String, dynamic>> chatDocs = snapshot.data!
                  .where((chat) {
                    // Only show chats that have actual messages
                    bool hasMessages = chat['is_messaged'] == true ||
                        (chat['message'] != null &&
                            chat['message'].toString().trim().isNotEmpty &&
                            chat['message'] != "");
                    return hasMessages;
                  })
                  .toList();

              // Sort by time (already sorted by Supabase, but just in case)
              chatDocs.sort((a, b) {
                DateTime? timeA = a['time'] != null 
                    ? DateTime.tryParse(a['time']) 
                    : null;
                DateTime? timeB = b['time'] != null 
                    ? DateTime.tryParse(b['time']) 
                    : null;
                
                if (timeA == null && timeB == null) return 0;
                if (timeA == null) return 1;
                if (timeB == null) return -1;
                
                return timeB.compareTo(timeA);
              });

              return ListView.builder(
                itemCount: chatDocs.length,
                itemBuilder: (context, index) {
                  var chat = chatDocs[index];
                  String currentUserId = "${authCont.user?.userId}";
                  
                  if (chat['sender_id'] == currentUserId ||
                      chat['send_to_id'] == currentUserId) {
                    
                    // Calculate unread status for this chat
                    bool isUnread = false;

                    // Check if there are unread messages based on read times
                    if (chat['send_by'] != currentUserId) { // Last message wasn't sent by current user
                      final isCurrentUserSender = chat['sender_id'] == currentUserId;
                      final lastReadTime = isCurrentUserSender
                          ? chat['sender_last_read_time']
                          : chat['recipient_last_read_time'];
                      final lastMessageTime = chat['time'];

                      // Message is unread if no read time or message is newer than read time
                      if (lastReadTime == null ||
                          (lastMessageTime != null &&
                           DateTime.parse(lastMessageTime).isAfter(DateTime.parse(lastReadTime)))) {
                        isUnread = true;
                      }
                    }

                    // Also check the unread_count field if available
                    if (chat['unread_count'] != null && chat['unread_count'] > 0) {
                      isUnread = true;
                    }

                    // Determine which user is the "other" user
                    bool isCurrentUserSender = chat['sender_id'] == currentUserId;
                    String remoteUserId = isCurrentUserSender 
                        ? chat['send_to_id'] 
                        : chat['sender_id'];
                    String remoteName = isCurrentUserSender 
                        ? chat['send_to_name'] 
                        : chat['sender_name'];
                    String remoteImage = isCurrentUserSender 
                        ? chat['send_to_image'] 
                        : chat['sender_image'];
                    String? remoteDeviceToken = isCurrentUserSender 
                        ? chat['send_to_device_token'] 
                        : chat['user_device_token'];

                    return GroupTile(
                        userChatId: chat['id'],
                        senderId: chat['sender_id'],
                        listingImage: chat['listing_image'] ?? '',
                        listingId: chat['listing_id'] ?? '',
                        listingName: chat['listing_name'] ?? '',
                        listingPrice: chat['listing_price'] ?? '',
                        listingLocation: chat['listing_location'] ?? '',
                        lastMessage: chat['message'] ?? '',
                        messageType: chat['message_type'] ?? 'text',
                        messageTime: chat['time'] != null 
                            ? DateTime.tryParse(chat['time'])
                            : null,
                        userName: remoteName,
                        userImage: remoteImage,
                        isUnread: isUnread,
                        remoteUserId: remoteUserId,
                        deviceToken: remoteDeviceToken,
                        remoteUid: remoteUserId);
                  } else {
                    return Container();
                  }
                },
              );
            } else {
              return noGroupWidget();
            }
          } else {
            return noGroupWidget();
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor),
          );
        }
          },
        ),
    );
  }

  noGroupWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 80.0.h),
        child: SelectionArea(
          child: CustomText(
            text: "No Chat".tr,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
