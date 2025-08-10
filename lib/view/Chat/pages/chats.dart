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

class _ChatsState extends State<Chats> {
  final authCont = Get.put(AuthController());
  final chatCont = Get.put(SupabaseChatController());
  String userName = "";
  String email = "";
  Stream<List<Map<String, dynamic>>>? chats;
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      gettingUserData();
      // Update badge count and unread indicators when chats page is loaded
      chatCont.updateBadgeCountFromChats();
      chatCont.updateUnreadMessageIndicators();
    });
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  gettingUserData() async {
    try {
      print("🔥 📋 LOADING CHATS LIST FROM SUPABASE...");
      if (authCont.user?.userId != null) {
        setState(() {
          chats = chatCont.getAllChats(authCont.user!.userId.toString());
        });
        print("🔥 ✅ CHATS LIST STREAM INITIALIZED!");
      }
    } catch (e) {
      print("🔥 ❌ ERROR LOADING CHATS LIST: $e");
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
    
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: chats,
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        print("🔥 📋 StreamBuilder state: hasData=${snapshot.hasData}, hasError=${snapshot.hasError}");
        
        if (snapshot.hasError) {
          print("🔥 ❌ StreamBuilder error: ${snapshot.error}");
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
            print("${snapshot.data!.length} chats found");
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
                    bool isUnread = chatCont.hasUnreadMessages(
                        chat, currentUserId);

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
    );
  }

  noGroupWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 80.0.h),
        child: SelectionArea(
          child: CustomText(
            text: "No Chat",
            fontSize: 20,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
