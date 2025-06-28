import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import '../Controller/ChatController.dart';
import '../custom_text.dart';
import '../widgets/group_tile.dart';

class Chats extends StatefulWidget {
  const Chats({Key? key}) : super(key: key);

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  final authCont = Get.put(AuthController());
  final chatCont = Get.put(ChatController());
  String userName = "";
  String email = "";
  Stream? chats;
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
      await chatCont.getAllUser().then((snapshot) {
        setState(() {
          chats = snapshot;
        });
      });
    } catch (e) {}
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
            fontColor: Colors.black,
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
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        // make some checks
        if (snapshot.hasData) {
          if (snapshot.data != null) {
            print("${snapshot.data.docs.length}");
            if (snapshot.data.docs.length != 0) {
              // Convert snapshot to a list that can be sorted
              List chatDocs = snapshot.data.docs.toList();

              // Sort the list by time in descending order (latest first)
              chatDocs.sort((a, b) {
                // Get timestamps with proper null handling
                Timestamp? timeA;
                Timestamp? timeB;

                try {
                  timeA = a.data().containsKey('time') && a['time'] is Timestamp
                      ? a['time'] as Timestamp
                      : null;
                } catch (e) {
                  timeA = null;
                }

                try {
                  timeB = b.data().containsKey('time') && b['time'] is Timestamp
                      ? b['time'] as Timestamp
                      : null;
                } catch (e) {
                  timeB = null;
                }

                // Handle null cases - put documents without timestamps at the end
                if (timeA == null && timeB == null) return 0;
                if (timeA == null) return 1; // A goes after B
                if (timeB == null) return -1; // B goes after A

                // Both have timestamps - sort in descending order (latest first)
                return timeB.compareTo(timeA);
              });

              return ListView.builder(
                itemCount: chatDocs.length,
                itemBuilder: (context, index) {
                  if (chatDocs[index]['senderId'] ==
                          "${authCont.user?.userId}" ||
                      chatDocs[index]['sendToId'] ==
                          "${authCont.user?.userId}") {
                    // Only show chats that have actual messages
                    bool hasMessages = chatDocs[index]['isMessaged'] == true ||
                        (chatDocs[index]['message'] != null &&
                            chatDocs[index]['message']
                                .toString()
                                .trim()
                                .isNotEmpty &&
                            chatDocs[index]['message'] != "");

                    if (!hasMessages) {
                      return Container(); // Don't show empty chats
                    }

                    // Calculate unread status for this chat
                    bool isUnread = chatCont.hasUnreadMessages(
                        chatDocs[index].data(), "${authCont.user?.userId}");

                    return GroupTile(
                        userChatId: chatDocs[index].id,
                        senderId: chatDocs[index]['senderId'],
                        listingImage: chatDocs[index]['listingImage'],
                        listingId: chatDocs[index]['listingId'],
                        listingName: chatDocs[index]['listingName'],
                        listingPrice: chatDocs[index]['listingPrice'],
                        listingLocation: chatDocs[index]['listingLocation'],
                        lastMessage: chatDocs[index]['message'],
                        messageType: chatDocs[index]['messageType'],
                        messageTime: chatDocs[index]['time'] is Timestamp
                            ? chatDocs[index]['time'] as Timestamp
                            : null,
                        userName: chatDocs[index]['senderId'] ==
                                "${authCont.user?.userId}"
                            ? chatDocs[index]['sendToName']
                            : chatDocs[index]['userName'],
                        userImage: chatDocs[index]['senderId'] ==
                                "${authCont.user?.userId}"
                            ? chatDocs[index]['senderToImage']
                            : chatDocs[index]['senderImage'],
                        isUnread: isUnread, // Pass the unread status
                        remoteUserId: chatDocs[index]['senderId'] ==
                                "${authCont.user?.userId}"
                            ? chatDocs[index]['sendToId']
                            : chatDocs[index][
                                'senderId'], // Pass remote user ID for presence tracking
                        deviceToken: (() {
                          // Debug: Print all chat document data
                          print("🔥 === CHAT DOCUMENT DEBUG ===");
                          var chatDoc = chatDocs[index];
                          print("🔥 Document ID: ${chatDoc.id}");
                          print("🔥 All fields: ${chatDoc.data()}");

                          String currentUserId = "${authCont.user?.userId}";
                          String senderId = chatDoc['senderId'] ?? "";
                          String sendToId = chatDoc['sendToId'] ?? "";
                          String? userDeviceToken = chatDoc['userDeviceToken'];
                          String? sendToDeviceToken =
                              chatDoc['sendToDeviceToken'];

                          print("🔥 Current user ID: $currentUserId");
                          print("🔥 Sender ID: $senderId");
                          print("🔥 SendTo ID: $sendToId");
                          print("🔥 userDeviceToken: $userDeviceToken");
                          print("🔥 sendToDeviceToken: $sendToDeviceToken");

                          // Logic: Get the device token of the OTHER user (not yourself)
                          String? token;
                          if (senderId == currentUserId) {
                            // You are the sender, get recipient's token
                            token = sendToDeviceToken;
                            print(
                                "🔥 ✅ You are SENDER → Using recipient's token: $token");
                          } else {
                            // You are the recipient, get sender's token
                            token = userDeviceToken;
                            print(
                                "🔥 ✅ You are RECIPIENT → Using sender's token: $token");
                          }

                          print("🔥 === END DEBUG ===");
                          return token;
                        })(),
                        remoteUid: chatDocs[index]['senderId'] ==
                                "${authCont.user?.userId}"
                            ? chatDocs[index]['sendToId']
                            : chatDocs[index]['senderId']);
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
