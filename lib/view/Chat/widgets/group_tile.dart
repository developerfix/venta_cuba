import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import '../Controller/ChatController.dart';
import '../custom_text.dart';
import '../pages/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestoree;
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupTile extends StatefulWidget {
  final String userName;
  final String? lastMessage;
  final String? messageType;
  final firestoree.Timestamp? messageTime;
  final String senderId;
  final String? remoteUid;
  final String? userChatId;
  final String? deviceToken;
  final String? userImage;
  final String? listingImage;
  final String? listingName;
  final String? listingPrice;
  final String? listingLocation;
  final String? listingId;
  final bool isUnread; // New parameter for unread status
  final String? remoteUserId; // Add remote user ID for presence tracking

  const GroupTile({
    Key? key,
    required this.senderId,
    required this.userName,
    this.userChatId,
    this.remoteUid,
    this.lastMessage,
    this.messageType,
    this.messageTime,
    this.userImage,
    this.listingImage,
    this.listingName,
    this.listingPrice,
    this.listingId,
    this.listingLocation,
    this.deviceToken,
    this.isUnread = false, // Default to false
    this.remoteUserId, // Add remote user ID parameter
  }) : super(key: key);

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  final authCont = Get.find<AuthController>();
  final chatCont = Get.find<ChatController>();
  String _formatMessageTime(firestoree.Timestamp? messageTime) {
    // Debug: Log the type of messageTime
    print('messageTime type: ${messageTime.runtimeType}');

    if (messageTime != null) {
      try {
        // Convert Firestore Timestamp to local DateTime and format
        return DateFormat('h:mm a').format(messageTime.toDate().toLocal());
      } catch (e) {
        print('Error formatting Timestamp: $e');
        return '';
      }
    } else {
      // Fallback for null Timestamp
      print('Invalid messageTime: $messageTime');
      return '';
    }
  }

  // Navigation function to handle chat page navigation
  Future<void> _navigateToChat() async {
    // Mark chat as read when user taps on it

    // Navigate to ChatPage
    Get.to(() => ChatPage(
          isLast: true,
          chatId: widget.userChatId,
          listingImage: widget.listingImage,
          listingName: widget.listingName,
          listingPrice: widget.listingPrice,
          listingLocation: widget.listingLocation,
          listingId: widget.listingId,
          userName: widget.userName,
          remoteUid: widget.remoteUid,
          senderId: widget.senderId,
          userImage: widget.userImage,
          deviceToken: widget.deviceToken,
        ));
    if (widget.userChatId != null && authCont.user?.userId != null) {
      await chatCont.markChatAsRead(
          widget.userChatId!, "${authCont.user?.userId}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Slidable with proper tap detection
        Slidable(
          endActionPane: ActionPane(
            motion: BehindMotion(),
            children: [
              SlidableAction(
                icon: Icons.delete,
                label: "Delete",
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                onPressed: (context) {
                  chatCont.deleteChat(widget.userChatId ?? "");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Chat deleted"),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _navigateToChat,
              splashColor: Colors.grey.withOpacity(0.3),
              highlightColor: Colors.grey.withOpacity(0.1),
              child: Container(
                width: double.infinity,
                height: 60.h,
                child: Column(
                  children: [
                    SizedBox(
                      height: 5.h,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              CachedNetworkImage(
                                height: 50.h,
                                width: 50.w,
                                imageUrl: widget.userImage ?? "",
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  height: 50.h,
                                  width: 50.w,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                      shape: BoxShape.circle),
                                ),
                                placeholder: (context, url) => SizedBox(
                                    height: 50.h,
                                    width: 50.w,
                                    child: Center(
                                        child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ))),
                                errorWidget: (context, url, error) => Container(
                                  height: 50.h,
                                  width: 50.w,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage(
                                              "assets/images/notImage.jpg")),
                                      shape: BoxShape.circle),
                                ),
                              ),
                              // Online status indicator
                              if (widget.remoteUserId != null)
                                StreamBuilder<DocumentSnapshot>(
                                  stream: chatCont
                                      .getUserPresence(widget.remoteUserId!),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.data!.exists) {
                                      Map<String, dynamic> presenceData =
                                          snapshot.data!.data()
                                              as Map<String, dynamic>;

                                      bool isOnline =
                                          chatCont.isUserOnline(presenceData);

                                      if (isOnline) {
                                        return Positioned(
                                          bottom: 2,
                                          right: 2,
                                          child: Container(
                                            width: 14.w,
                                            height: 14.h,
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                    return SizedBox.shrink();
                                  },
                                ),
                            ],
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 270.w,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(
                                      text: widget.userName == ""
                                          ? "No Name".tr
                                          : widget.userName,
                                      fontWeight: widget.isUnread
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      fontSize: 14,
                                      fontColor: widget.isUnread
                                          ? Colors.black
                                          : Color(0xFFA8AAAC),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CustomText(
                                          text: _formatMessageTime(
                                              widget.messageTime),
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w400,
                                          fontColor: Color(0xFF3F3B3B),
                                        ),
                                        if (widget.isUnread) ...[
                                          SizedBox(width: 5.w),
                                          Container(
                                            width: 8.w,
                                            height: 8.h,
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              SizedBox(
                                width: 270.w,
                                height: 15.h,
                                child: CustomText(
                                  text: widget.messageType == "image"
                                      ? "Image".tr
                                      : "${widget.lastMessage}",
                                  fontWeight: widget.isUnread
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontColor: widget.isUnread
                                      ? Colors.black
                                      : Colors.grey[600]!,
                                  fontSize: 13,
                                  textOverflow: TextOverflow.clip,
                                ),
                              ),
                              SizedBox(
                                height: 3.h,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Divider(),
      ],
    );
  }
}
