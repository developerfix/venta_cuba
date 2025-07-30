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
      print("🔥 📋 LOADING CHATS LIST FROM FIREBASE...");
      await chatCont.getAllUser().then((snapshot) {
        print("🔥 ✅ CHATS LIST LOADED SUCCESSFULLY!");
        setState(() {
          chats = snapshot;
        });
      });
    } catch (e) {
      print("🔥 ❌ ERROR LOADING CHATS LIST: $e");
    }
  }

  // Debug banner for chats list screen
  Widget _buildChatsDebugBanner() {
    return Container(
      width: double.infinity,
      color: Colors.orange.withOpacity(0.8),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        children: [
          Text(
            "🔥 CHATS LIST DEBUG INFO 🔥",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 3),
          StreamBuilder(
            stream: chats,
            builder: (context, snapshot) {
              String status = "❌ Loading chats...";
              if (snapshot.hasError) {
                status = "❌ Firebase Error: ${snapshot.error}";
              } else if (snapshot.hasData) {
                int totalDocs = snapshot.data?.docs?.length ?? 0;
                
                // Count visible chats (same filtering logic as ListView)
                int visibleChats = 0;
                if (snapshot.data?.docs != null) {
                  for (var doc in snapshot.data.docs) {
                    if (doc['senderId'] == "${authCont.user?.userId}" ||
                        doc['sendToId'] == "${authCont.user?.userId}") {
                      // Only count chats that have actual messages
                      bool hasMessages = doc['isMessaged'] == true ||
                          (doc['message'] != null &&
                              doc['message'].toString().trim().isNotEmpty &&
                              doc['message'] != "");
                      if (hasMessages) {
                        visibleChats++;
                      }
                    }
                  }
                }
                
                status = "✅ Firebase: $totalDocs docs → $visibleChats visible chats";
              }
              
              return Row(
                children: [
                  Icon(
                    snapshot.hasData ? Icons.check_circle : Icons.error_outline,
                    color: snapshot.hasData ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      status,
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ],
              );
            },
          ),
          _buildFirebaseConnectionForChats(),
        ],
      ),
    );
  }

  Widget _buildFirebaseConnectionForChats() {
    return FutureBuilder<bool>(
      future: _testFirebaseConnection(),
      builder: (context, snapshot) {
        bool isConnected = snapshot.data ?? false;
        return Row(
          children: [
            Icon(
              isConnected ? Icons.cloud_done : Icons.cloud_off,
              color: isConnected ? Colors.green : Colors.red,
              size: 16,
            ),
            SizedBox(width: 5),
            Expanded(
              child: Text(
                isConnected 
                  ? "✅ Firebase: CAN READ CHATS" 
                  : "❌ Firebase: CONNECTION FAILED",
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _testFirebaseConnection() async {
    try {
      await FirebaseFirestore.instance
          .collection('chat')
          .limit(1)
          .get()
          .timeout(Duration(seconds: 5));
      return true;
    } catch (e) {
      print("🔥 ❌ Firebase connection test failed: $e");
      return false;
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
            // Debug banner for chats list
            _buildChatsDebugBanner(),
            SizedBox(height: 2.h, child: Divider()),
            Expanded(child: groupList()),
          ],
        ));
  }

  groupList() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
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
                    "🔥 Firebase Error",
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
