import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/view/Chat/widgets/widgets.dart';
import '../Controller/ChatController.dart';
import '../custom_text.dart';
import '../pages/chat_page.dart';

class GroupTile extends StatefulWidget {
  final String userName;
  final String? lastMessage;
  final String? messageType;
  final String? messageTime;
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
  }) : super(key: key);

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  final authCont = Get.find<AuthController>();
  final chatCont = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slidable(
            endActionPane: ActionPane(
              motion: BehindMotion(),
              children: [
                SlidableAction(
                  icon: Icons.delete,
                  label: "Delete",
                  onPressed: (context) {
                    chatCont.deleteChat(widget.userChatId ?? "");
                    // showCustomDialog(widget.userChatId ?? "");
                  },
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                authCont.currentIndexBottomAppBar = 1;
                authCont.update();
                setState(() {});
                nextScreen(
                    context,
                    ChatPage(
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
              },
              child: Container(
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
                          CachedNetworkImage(
                            height: 50..h,
                            width: 50..w,
                            imageUrl: widget.userImage ?? "",
                            imageBuilder: (context, imageProvider) => Container(
                              height: 50..h,
                              width: 50..w,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                  shape: BoxShape.circle),
                            ),
                            placeholder: (context, url) => SizedBox(
                                height: 50..h,
                                width: 50..w,
                                child: Center(
                                    child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ))),
                            errorWidget: (context, url, error) => Container(
                              height: 50..h,
                              width: 50..w,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          "assets/images/notImage.jpg")),
                                  shape: BoxShape.circle),
                            ),
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
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      fontColor: Color(0xFFA8AAAC),
                                    ),
                                    CustomText(
                                      text: "${widget.messageTime}",
                                      fontSize: 13..sp,
                                      fontWeight: FontWeight.w400,
                                      fontColor: Color(0xFF3F3B3B),
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
                                  fontWeight: FontWeight.w500,
                                  fontColor: Colors.black,
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
            )),
        SizedBox(height: 1.h, child: Divider()),
      ],
    );
  }
}
