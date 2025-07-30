import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
// import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/Utils/funcations.dart';
import 'package:venta_cuba/view/Navigation%20bar/post.dart';
import 'package:venta_cuba/view/constants/Colors.dart';
import '../../../Controllers/home_controller.dart';
import '../../../Notification/firebase_messaging.dart';
import '../../../Utils/global_variabel.dart';
import '../../frame/frame.dart';
import '../Controller/ChatController.dart';
import '../custom_text.dart';
import '../widgets/message_tile.dart';
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  final bool? isLast;
  final String? createChatid;
  final String? listingImage;
  final String? listingName;
  final String? listingPrice;
  final String? listingLocation;
  final String? senderId;
  final String? remoteUid;
  final String? chatId;
  final String? userName;
  final String? userImage;
  final String? deviceToken;
  final String? listingId;

  const ChatPage(
      {Key? key,
      this.chatId,
      this.isLast,
      this.userName,
      this.userImage,
      this.senderId,
      this.remoteUid,
      this.createChatid,
      this.deviceToken,
      this.listingImage,
      this.listingName,
      this.listingId,
      this.listingPrice,
      this.listingLocation})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  FCM firebaseMessaging = FCM();

  final chatCont = Get.put(ChatController());
  final homeCont = Get.put(HomeController());
  final authCont = Get.put(AuthController());
  bool isKeyBoardOpen = true;
  late FocusNode focusNode; // Add the missing FocusNode declaration

  @override
  void dispose() {
    chatCont.isShow = false;
    isONImageScreen = false;
    isKeyBoardOpen = true;
    focusNode.dispose(); // Dispose the FocusNode
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (!isONImageScreen && isKeyBoardOpen) {
      _requestFocus();
      isKeyBoardOpen = false;
    }
    super.didChangeDependencies();
    // Call dependOnInheritedWidgetOfExactType here.
  }

  @override
  void initState() {
    super.initState();

    print("🔥 === CHAT PAGE INIT STATE ===");
    print("🔥 Chat ID: ${widget.chatId}");
    print("🔥 User Name: ${widget.userName}");
    print("🔥 Listing ID: ${widget.listingId}");
    print("🔥 Remote UID: ${widget.remoteUid}");

    focusNode = FocusNode();
    getChat();
    saveFile();

    // Update device tokens when chat is opened
    updateDeviceTokensOnChatOpen();

    // Initialize listing data for this specific chat
    _initializeListingData();

    // Improved scroll listener with better logic
    chatCont.scrollController.addListener(() {
      if (chatCont.scrollController.hasClients) {
        final maxScroll = chatCont.scrollController.position.maxScrollExtent;
        final currentScroll = chatCont.scrollController.position.pixels;

        // Show scroll-to-bottom button if user is not near the bottom (within 100 pixels)
        bool shouldShow = (maxScroll - currentScroll) > 100;

        if (chatCont.isShow != shouldShow) {
          chatCont.isShow = shouldShow;
          chatCont.update();
        }
      }
    });
    chatCont.isLast = widget.isLast ?? false;
    updateImage();
  }

  // Initialize listing data for this specific chat
  void _initializeListingData() {
    // Use addPostFrameCallback to ensure this runs after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Clear any cached listing data first to prevent showing wrong data
      homeCont.listingModel = null;
      homeCont.update();

      // Fetch the correct listing details if listingId is available
      if (widget.listingId != null &&
          widget.listingId!.isNotEmpty &&
          widget.listingId != "null") {
        print("🔥 Fetching listing details for ID: ${widget.listingId}");
        homeCont.getListingDetails(widget.listingId!, showDialog: false);
      } else {
        print("🔥 No valid listing ID provided: ${widget.listingId}");
      }
    });
  }

  // Update device tokens when chat is opened
  Future<void> updateDeviceTokensOnChatOpen() async {
    try {
      if (widget.chatId != null && authCont.user?.userId != null) {
        print("🔥 📱 Updating device token on chat open...");
        await chatCont.updateDeviceTokenInChat(
          widget.chatId!,
          authCont.user!.userId.toString(),
          deviceToken,
        );

        // Also mark chat as read when opened
        await chatCont.markChatAsRead(
          widget.chatId!,
          authCont.user!.userId.toString(),
        );

        // Update unread indicators after marking as read
        await chatCont.updateUnreadMessageIndicators();
      }
    } catch (e) {
      print("🔥 ❌ Error updating device token on chat open: $e");
    }
  }

  void _scrollToBottom({bool animated = false}) {
    if (chatCont.scrollController.hasClients) {
      final maxScrollExtent =
          chatCont.scrollController.position.maxScrollExtent;
      if (animated) {
        chatCont.scrollController.animateTo(
          maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        chatCont.scrollController.jumpTo(maxScrollExtent);
      }
    } else {
      // Retry after a short delay if scroll controller is not ready
      Timer(Duration(milliseconds: 100),
          () => _scrollToBottom(animated: animated));
    }
  }

  void _requestFocus() {
    FocusScope.of(context).requestFocus(focusNode);
  }

  Future<bool> saveFile() async {
    Directory? directory;
    try {
      if (Platform.isAndroid) {
        if (await _requestPermissions(Permission.manageExternalStorage) ||
            await _requestPermissions(Permission.storage)) {
          directory = await getExternalStorageDirectory();
          String newPath = "";
          List<String> folders = directory!.path.split('/');
          for (int x = 1; x < folders.length; x++) {
            String folder = folders[x];
            if (folder != "Android") {
              newPath += "/$folder";
            } else {
              break;
            }
          }
          newPath = "$newPath/VentaCuba";
          directory = Directory(newPath);
        } else {
          if (await _requestPermissions(Permission.photos)) {
            directory = await getTemporaryDirectory();
          } else {
            return false;
          }
        }
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        if (await directory.exists()) {
          chatCont.path = directory.path;
        }
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  Future<bool> _requestPermissions(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  getChat() {
    try {
      String? id = widget.chatId ?? widget.createChatid;
      chatCont.getChats(id ?? "").then((val) {
        setState(() {
          chatCont.chats = val;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Color(0x19D9D9D9),
        elevation: 0,
        leadingWidth: 40,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Icon(
              Icons.arrow_back,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        ),
        title: GestureDetector(
          onTap: () {
            final HomeController homeController = Get.find();
            homeController.sellerId = widget.remoteUid.toString();
            homeController.getSellerDetails(
                homeController.isBusinessAccount ? "1" : "0", 0, true);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedNetworkImage(
                height: 50..h,
                width: 50.w,
                imageUrl: "${widget.userImage}",
                imageBuilder: (context, imageProvider) => Container(
                  height: 180..h,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                placeholder: (context, url) => SizedBox(
                    height: 50..h,
                    width: 50.w,
                    child: Center(
                        child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ))),
                errorWidget: (context, url, error) {
                  print("🔥 Profile image load error: $error for URL: $url");
                  return Container(
                    height: 50..h,
                    width: 50.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.grey[600],
                    ),
                  );
                },
              ),
              SizedBox(
                width: 16.w,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: widget.userName == ""
                        ? "No Name"
                        : widget.userName ?? "No Name",
                    fontSize: 16..sp,
                    fontWeight: FontWeight.w600,
                    fontColor: Theme.of(context).textTheme.bodyLarge?.color ??
                        Colors.black,
                  ),

                  SizedBox(height: 2.h),
                  // Show last active time or online status
                  if (widget.remoteUid != null)
                    StreamBuilder<DocumentSnapshot>(
                      stream: chatCont.getUserPresence(widget.remoteUid!),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.exists) {
                          Map<String, dynamic> presenceData =
                              snapshot.data!.data() as Map<String, dynamic>;

                          bool isOnline = chatCont.isUserOnline(presenceData);
                          Timestamp? lastActiveTime =
                              presenceData['lastActiveTime'];

                          return CustomText(
                            text: isOnline
                                ? "Online".tr
                                : chatCont.formatLastActiveTime(lastActiveTime),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            fontColor:
                                isOnline ? Colors.green : Colors.grey[600]!,
                          );
                        }
                        return CustomText(
                          text: "Last seen long ago".tr,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          fontColor: Colors.grey[600]!,
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          // Debug status banner
          _buildDebugStatusBanner(),
          // chat messages here
          chatMessages(),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: InkWell(
              onTap: () {
                homeCont.getListingDetails("${widget.listingId}",
                    showDialog: true);
              },
              child: Container(
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(0, 5))
                    ]),
                child: GetBuilder<HomeController>(
                  builder: (controller) {
                    return Row(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: CachedNetworkImage(
                              height: 50,
                              width: 50,
                              imageUrl: _getListingImage(),
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => SizedBox(
                                height: 50,
                                width: 50,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) {
                                print(
                                    "🔥 Listing image load error: $error for URL: $url");
                                return Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    color: Colors.grey[300],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported,
                                        size: 20,
                                        color: Colors.grey[600],
                                      ),
                                      Text(
                                        "No Image".tr,
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Only show price if it's valid
                              if (_shouldShowPrice())
                                CustomText(
                                  text: _getFormattedPrice(),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  fontColor: Colors.green[700]!,
                                ),
                              // Show title/name
                              if (_getListingTitle().isNotEmpty)
                                CustomText(
                                    text: _getListingTitle(),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    fontColor: AppColors.textPrimary),
                              // Show location
                              if (_getListingLocation().isNotEmpty)
                                CustomText(
                                  text: _getListingLocation(),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  fontColor: Colors.grey[600]!,
                                ),
                            ],
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          GetBuilder<ChatController>(builder: (cont) {
            return Container(
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.only(bottom: 10.h),
              width: MediaQuery.of(context).size.width,
              child: Container(
                color: Colors.transparent,
                padding: EdgeInsets.only(top: 2.h, bottom: 8.h, right: 5.w),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: InkWell(
                        onTap: () {
                          cont.isImageSend = !cont.isImageSend;
                          cont.update();
                        },
                        child: Icon(
                          cont.isImageSend
                              ? Icons.arrow_back_ios_new
                              : Icons.arrow_forward_ios_outlined,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: cont.isImageSend,
                      child: Row(
                        children: [
                          SizedBox(width: 10.w),
                          InkWell(
                            onTap: () {
                              focusNode.unfocus();
                              _openCamera(context);
                            },
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          InkWell(
                            onTap: () {
                              focusNode.unfocus();
                              _openGallery(context);
                            },
                            child: Icon(
                              Icons.image,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 50..h,
                        padding: EdgeInsets.only(left: 10.w, bottom: 5),
                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(30.r),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .shadowColor
                                    .withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                                spreadRadius: 0,
                              )
                            ],
                            border: Border.all(
                                color: AppColors.textPrimary
                                    .withValues(alpha: 0.5),
                                width: 1.5)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 4..w),
                            Expanded(
                              child: TextField(
                                focusNode: focusNode,
                                controller: cont.messageController,
                                maxLines: null,
                                minLines: 1,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    hintText: 'Type Message'.tr,
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color
                                              ?.withValues(alpha: 0.5) ??
                                          Colors.black.withValues(alpha: 0.5),
                                    )),
                                onTap: () {
                                  // Scroll to bottom when text field is tapped (keyboard appears)
                                  Future.delayed(Duration(milliseconds: 300),
                                      () {
                                    _scrollToBottom(animated: true);
                                  });
                                  cont.update();
                                },
                                onChanged: (String? value) {
                                  if (cont.messageController.text.isNotEmpty) {
                                    chatCont.isTyping = true;
                                    cont.update();
                                  } else {
                                    cont.isTyping = false;
                                    cont.update();
                                  }
                                },
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.send,
                                    color: cont.isTyping
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context).iconTheme.color,
                                  ),
                                  onPressed: () async {
                                    await sendMessage('text');

                                    cont.update();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                  ],
                ),
              ),
            );
          }),
          GetBuilder<ChatController>(builder: (cont) {
            return Positioned(
              bottom: 80.h,
              left: 170.w,
              child: Visibility(
                visible: cont.isShow,
                child: InkWell(
                  onTap: () {
                    _scrollToBottom(animated: true);
                  },
                  child: Container(
                    height: 40.h,
                    width: 40.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(
                              0, 3), // changes the position of the shadow
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_downward_rounded,
                      color: Theme.of(context).iconTheme.color ?? Colors.black,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Debug status banner to show connection info
  Widget _buildDebugStatusBanner() {
    return Positioned(
      top: 80.h, // Below the listing info
      left: 0,
      right: 0,
      child: Container(
        color: Colors.red.withOpacity(0.8),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          children: [
            Text(
              "🔥 DEBUG INFO FOR CUBAN TESTING 🔥",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 3),
            _buildFirebaseConnectionStatus(),
            _buildLastMessageStatus(),
            _buildNetworkStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildFirebaseConnectionStatus() {
    return StreamBuilder<bool>(
      stream: _getFirebaseConnectionStream(),
      builder: (context, snapshot) {
        bool isConnected = snapshot.data ?? false;
        return Row(
          children: [
            Icon(
              isConnected ? Icons.check_circle : Icons.error_outline,
              color: isConnected ? Colors.green : Colors.red,
              size: 16,
            ),
            SizedBox(width: 5),
            Expanded(
              child: Text(
                isConnected 
                  ? "✅ Firebase: CONNECTED" 
                  : "❌ Firebase: DISCONNECTED",
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLastMessageStatus() {
    return StreamBuilder(
      stream: chatCont.chats,
      builder: (context, snapshot) {
        String status = "❌ No messages yet";
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          var lastDoc = snapshot.data!.docs.last;
          Timestamp? timestamp = lastDoc.get('time');
          if (timestamp != null) {
            DateTime lastTime = timestamp.toDate();
            String timeAgo = _formatTimeAgo(lastTime);
            status = "✅ Last msg: $timeAgo";
          }
        }
        return Row(
          children: [
            Icon(Icons.message, color: Colors.white, size: 16),
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
    );
  }

  Widget _buildNetworkStatus() {
    return FutureBuilder<bool>(
      future: _checkInternetConnection(),
      builder: (context, snapshot) {
        bool hasInternet = snapshot.data ?? false;
        return Row(
          children: [
            Icon(
              hasInternet ? Icons.wifi : Icons.wifi_off,
              color: hasInternet ? Colors.green : Colors.red,
              size: 16,
            ),
            SizedBox(width: 5),
            Expanded(
              child: Text(
                hasInternet 
                  ? "✅ Internet: CONNECTED" 
                  : "❌ Internet: NO CONNECTION",
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ],
        );
      },
    );
  }

  Stream<bool> _getFirebaseConnectionStream() {
    return FirebaseFirestore.instance
        .collection('debug')
        .doc('connection')
        .snapshots()
        .map((snapshot) => true)
        .handleError((error) => false);
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com')).timeout(Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return "${difference.inSeconds}s ago";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else {
      return "${difference.inDays}d ago";
    }
  }

  // Future<void> saveImageToGallery(String imageUrl) async {
  //   try {
  //     // Download the image from the URL
  //     var response = await http.get(Uri.parse(imageUrl));

  //     if (response.statusCode == 200) {
  //       Uint8List bytes = response.bodyBytes;

  //       // Get the application documents directory
  //       final appDir = await getApplicationDocumentsDirectory();

  //       // Generate a unique filename
  //       String fileName =
  //           DateTime.now().millisecondsSinceEpoch.toString() + '.png';

  //       // Create a new file with the generated filename
  //       final file = File('${appDir.path}/$fileName');

  //       // Write the image bytes to the file
  //       await file.writeAsBytes(bytes);

  //       print('Image saved locally: ${file.path}');

  //       // Save the image to the gallery
  //       final result = await ImageGallerySaverPlus.saveFile(file.path,
  //           isReturnPathOfIOS: true);

  //       if (result != null && result.isNotEmpty) {
  //         errorAlertToast("Saved".tr);
  //         print('Image saved to gallery: $result');
  //       } else {
  //         print('Failed to save image to gallery. File path is null or empty.');
  //       }
  //     } else {
  //       print('Failed to download image: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error saving image to gallery: $e');
  //   }
  // }

  chatMessages() {
    return StreamBuilder(
      stream: chatCont.chats,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        // Schedule scroll to bottom after the widget tree is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });

        return Column(
          children: [
            GetBuilder<ChatController>(builder: (cont) {
              return Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: 20.h, top: 80.h),
                  controller: cont.scrollController,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    var sendBy = snapshot.data.docs[index].get('sendBy');
                    print(sendBy);
                    Timestamp? timestamp =
                        snapshot.data.docs[index].get('time');
                    String formattedTime = timestamp != null
                        ? DateFormat('h:mm a')
                            .format(timestamp.toDate().toLocal())
                        : "";

                    return "${authCont.user?.userId}" == sendBy
                        ? Slidable(
                            endActionPane: ActionPane(
                              extentRatio: 0.25,
                              motion: StretchMotion(),
                              children: [
                                SlidableAction(
                                  icon: Icons.save,
                                  label: "Save",
                                  backgroundColor: Colors.blue,
                                  onPressed: (context) {
                                    if (snapshot.data.docs[index]
                                            ['messageType'] ==
                                        'image') {
                                      // saveImageToGallery(snapshot
                                      //     .data.docs[index]['message']);
                                    }
                                  },
                                ),
                              ],
                            ),
                            child: MessageTile(
                                message: snapshot.data.docs[index]['message'],
                                sender: snapshot.data.docs[index]['sender'],
                                messageType: snapshot.data.docs[index]
                                    ['messageType'],
                                messageTime: formattedTime,
                                sentByMe: "${authCont.user?.userId}" == sendBy),
                          )
                        : Slidable(
                            startActionPane: ActionPane(
                              extentRatio: 0.25,
                              motion: StretchMotion(),
                              children: [
                                SlidableAction(
                                  icon: Icons.save,
                                  label: "Save",
                                  backgroundColor: Colors.blue,
                                  onPressed: (context) {
                                    if (snapshot.data.docs[index]
                                            ['messageType'] ==
                                        'image') {
                                      // saveImageToGallery(snapshot
                                      //     .data.docs[index]['message']);
                                    }
                                  },
                                ),
                              ],
                            ),
                            child: MessageTile(
                                message: snapshot.data.docs[index]['message'],
                                sender: snapshot.data.docs[index]['sender'],
                                messageType: snapshot.data.docs[index]
                                    ['messageType'],
                                messageTime: formattedTime,
                                sentByMe: "${authCont.user?.userId}" == sendBy),
                          );
                  },
                ),
              );
            }),
            SizedBox(
              height: 53.h,
            )
          ],
        );
      },
    );
  }

  Future sendMessage(String messageType) async {
    try {
      if (chatCont.messageController.text.isNotEmpty) {
        print("🔥 💬 TRYING TO SEND MESSAGE: ${chatCont.messageController.text}");
        print("🔥 💬 Chat ID: ${widget.chatId ?? widget.createChatid}");
        
        Map<String, dynamic> chatMessageMap = {
          "message": chatCont.messageController.text,
          "isMessaged": true,
          "messageType": messageType,
          "sender": "${authCont.user?.firstName} ${authCont.user?.lastName}",
          "time": FieldValue.serverTimestamp(),
          // "messageTime": DateFormat('h:mm a').format(DateTime.now()).toString(),
          "sendBy": "${authCont.user?.userId}",
        };
        String? id = widget.chatId ?? widget.createChatid;
        
        print("🔥 💬 Sending to Firebase...");
        await chatCont.sendMessage(id ?? "", chatMessageMap);
        print("🔥 ✅ Message sent to Firebase successfully!");
        
        String message = chatCont.messageController.text;

        // Clear the message controller first
        chatCont.messageController.clear();

        // Scroll to bottom with a slight delay to ensure message is added
        Future.delayed(Duration(milliseconds: 100), () {
          _scrollToBottom(animated: true);
        });

        // Send notification with improved error handling
        print("🔥 📤 Sending notification...");
        await sendNotificationToRecipient(message, messageType);
      }
    } catch (e) {
      print("🔥 ❌ ERROR SENDING MESSAGE: $e");
      print("🔥 ❌ Error details: ${e.toString()}");
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Failed to send message: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> sendNotificationToRecipient(
      String message, String messageType) async {
    try {
      print("🔥 === NOTIFICATION SENDING DEBUG ===");
      print("🔥 Current user ID: ${authCont.user?.userId}");
      print(
          "🔥 Current user name: ${authCont.user?.firstName} ${authCont.user?.lastName}");
      print("🔥 Recipient UID: ${widget.remoteUid}");
      print("🔥 Device token from chat: ${widget.deviceToken}");
      print("🔥 Message: $message");
      print("🔥 Message type: $messageType");

      // CRITICAL CHECK: Are you sending to yourself?
      if ("${authCont.user?.userId}" == widget.remoteUid) {
        print(
            "🔥 🚨 WARNING: You are trying to send notification to YOURSELF!");
        print("🔥 🚨 Current user ID: ${authCont.user?.userId}");
        print("🔥 🚨 Remote user ID: ${widget.remoteUid}");
        print(
            "🔥 🚨 This should NOT happen - there's a bug in the chat logic!");
        return;
      }

      // Update sender's device token in chat document before sending notification
      if (widget.chatId != null && authCont.user?.userId != null) {
        print("🔥 📱 Updating sender's device token in chat document...");
        await chatCont.updateDeviceTokenInChat(
          widget.chatId!,
          authCont.user!.userId.toString(),
          deviceToken,
        );
      }

      // Get the most recent device token from chat document
      String? deviceTokenToUse = await getRecipientDeviceToken();

      // Validate device token
      if (deviceTokenToUse == null || deviceTokenToUse.isEmpty) {
        print("🔥 ❌ Device token from chat is null/empty");
        print("🔥 ❌ Notification will not be sent");
        return;
      }

      // Basic validation of device token format
      if (deviceTokenToUse.length < 50) {
        print(
            "🔥 ⚠️ Device token seems too short (${deviceTokenToUse.length} chars): $deviceTokenToUse");
      } else {
        print(
            "🔥 ✅ Device token looks valid (${deviceTokenToUse.length} chars)");
      }

      // Send the notification
      print("🔥 📤 Sending FCM notification...");
      bool notificationSent = await sendNotificationWithRetry(
        deviceTokenToUse,
        messageType,
        message,
      );

      if (notificationSent) {
        print("🔥 ✅ Notification sent successfully to ${widget.remoteUid}");
      } else {
        print("🔥 ❌ Failed to send notification to ${widget.remoteUid}");
      }
    } catch (e) {
      print("🔥 ❌ Error sending notification: $e");
    }
  }

  // Get recipient's device token from chat document
  Future<String?> getRecipientDeviceToken() async {
    try {
      if (widget.chatId == null) return widget.deviceToken;

      DocumentSnapshot chatDoc = await FirebaseFirestore.instance
          .collection("chat")
          .doc(widget.chatId!)
          .get();

      if (!chatDoc.exists) return widget.deviceToken;

      String currentUserId = authCont.user!.userId.toString();
      String? senderId = chatDoc.get('senderId');

      // Get the recipient's device token (not your own)
      if (senderId == currentUserId) {
        // You are the sender, get recipient's token
        return chatDoc.get('sendToDeviceToken');
      } else {
        // You are the recipient, get sender's token
        return chatDoc.get('userDeviceToken');
      }
    } catch (e) {
      print("🔥 ❌ Error getting recipient device token: $e");
      return widget.deviceToken; // Fallback to original token
    }
  }

  Future<bool> sendNotificationWithRetry(
      String deviceToken, String messageType, String message) async {
    try {
      // First attempt with the provided device token
      bool success = await firebaseMessaging.sendNotificationFCM(
          title: "${authCont.user?.firstName} ${authCont.user?.lastName}",
          name: "${authCont.user?.firstName} ${authCont.user?.lastName}",
          body: messageType == "voice"
              ? "Voice Message"
              : messageType == "image"
                  ? "Image"
                  : message,
          deviceToken: deviceToken,
          userId: authCont.user?.userId.toString(),
          remoteId: widget.remoteUid,
          profileImage: authCont.user?.profileImage ?? "",
          type: "message");

      if (!success) {
        print(
            "🔥 ❌ Notification failed - device token is likely expired/invalid");
        print("🔥 💡 Device token for user ${widget.remoteUid}: $deviceToken");
        print("🔥 💡 This token needs to be refreshed in the chat document");
        print("🔥 💡 Possible solutions:");
        print(
            "🔥 💡 1. Ask the other user to open the app to refresh their token");
        print("🔥 💡 2. Implement backend API to get fresh device tokens");
        print("🔥 💡 3. Update chat documents when users refresh their tokens");
      }

      return success;
    } catch (e) {
      print("🔥 ❌ Error in notification retry: $e");
      return false;
    }
  }

  // Helper method to get listing image URL
  String _getListingImage() {
    // Prefer the fetched listing model data over widget data
    if (homeCont.listingModel?.gallery != null &&
        homeCont.listingModel!.gallery!.isNotEmpty) {
      String imageUrl = homeCont.listingModel!.gallery!.first;
      if (imageUrl.isNotEmpty && imageUrl != "null") {
        return imageUrl;
      }
    }
    // Fallback to widget data
    String fallbackUrl = widget.listingImage ?? "";
    if (fallbackUrl.isNotEmpty && fallbackUrl != "null") {
      return fallbackUrl;
    }
    // Return empty string if no valid image URL found
    return "";
  }

  // Helper method to get listing title
  String _getListingTitle() {
    // Prefer the fetched listing model data over widget data
    if (homeCont.listingModel?.title != null &&
        homeCont.listingModel!.title!.isNotEmpty &&
        homeCont.listingModel!.title != "null") {
      return homeCont.listingModel!.title!;
    }
    // Fallback to widget data
    if (widget.listingName != null &&
        widget.listingName!.isNotEmpty &&
        widget.listingName != "null") {
      return widget.listingName!;
    }
    return "Listing";
  }

  // Helper method to get listing location
  String _getListingLocation() {
    // Prefer the fetched listing model data over widget data
    if (homeCont.listingModel?.address != null &&
        homeCont.listingModel!.address!.isNotEmpty &&
        homeCont.listingModel!.address != "null") {
      return homeCont.listingModel!.address!;
    }
    // Fallback to widget data
    if (widget.listingLocation != null &&
        widget.listingLocation!.isNotEmpty &&
        widget.listingLocation != "null") {
      return widget.listingLocation!;
    }
    return "";
  }

  // Helper method to get formatted price
  String _getFormattedPrice() {
    String price = "0";
    String currency = "USD";

    // Try to get price from listing model first
    if (homeCont.listingModel?.price != null &&
        homeCont.listingModel!.price!.isNotEmpty &&
        homeCont.listingModel!.price != "null") {
      price = homeCont.listingModel!.price!;
      currency = homeCont.listingModel?.currency ?? "USD";
    } else if (widget.listingPrice != null &&
        widget.listingPrice!.isNotEmpty &&
        widget.listingPrice != "null") {
      // Fallback to widget data
      price = widget.listingPrice!;
    }

    // Ensure currency is not empty or null, fallback to 'USD'
    if (currency.isEmpty || currency == "null") {
      currency = "USD";
    }

    try {
      int priceInt = int.parse(price);
      return "${PriceFormatter().formatNumber(priceInt)}\$ ${currency}";
    } catch (e) {
      return "$price\$ $currency";
    }
  }

  // Helper method to check if price should be shown
  bool _shouldShowPrice() {
    // Check homeCont.listingModel?.price first
    var modelPrice = homeCont.listingModel?.price;
    if (modelPrice != null && modelPrice.isNotEmpty && modelPrice != "null") {
      String priceStr = modelPrice.toString().trim();
      if (priceStr.isNotEmpty && priceStr != "0" && priceStr != "0.0") {
        double? price = double.tryParse(priceStr);
        if (price != null && price > 0) {
          return true;
        }
      }
    }

    // Check widget.listingPrice as fallback
    var widgetPrice = widget.listingPrice;
    if (widgetPrice != null &&
        widgetPrice.isNotEmpty &&
        widgetPrice != "null") {
      String priceStr = widgetPrice.toString().trim();
      if (priceStr.isNotEmpty && priceStr != "0" && priceStr != "0.0") {
        double? price = double.tryParse(priceStr);
        if (price != null && price > 0) {
          return true;
        }
      }
    }

    return false;
  }

  updateImage() {
    Map<String, dynamic> chatMessageMap =
        "${widget.senderId}" == "${authCont.user?.userId}"
            ? {
                "senderImage": "${authCont.user?.profileImage}",
              }
            : {
                "senderToImage": "${authCont.user?.profileImage}",
              };
    print("Good>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>$chatMessageMap}");
    String? id = widget.chatId ?? widget.createChatid;
    print("?????????????$id");
    print("here2");

    chatCont.updateImage(id ?? "", chatMessageMap);
  }

  void _openCamera(BuildContext context) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      // Add a temporary message with local image path
      _addTemporaryImageMessage(pickedFile.path);
      // Start upload in background
      uploadImage(pickedFile, localPath: pickedFile.path);
    }
  }

  void _openGallery(BuildContext context) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      // Add a temporary message with local image path
      _addTemporaryImageMessage(pickedFile.path);
      // Start upload in background
      uploadImage(pickedFile, localPath: pickedFile.path);
    }
  }

  void _addTemporaryImageMessage(String localPath) {
    // Add a temporary message to the chat with a local file path and a 'pending' flag
    Map<String, dynamic> chatMessageMap = {
      "message": localPath,
      "isMessaged": true,
      "messageType": "image",
      "sender": "${authCont.user?.firstName} ${authCont.user?.lastName}",
      "time": FieldValue.serverTimestamp(),
      "sendBy": "${authCont.user?.userId}",
      "pending": true, // Custom flag to indicate this is a local/pending image
    };
    String? id = widget.chatId ?? widget.createChatid;
    chatCont.sendMessage(id ?? "", chatMessageMap);

    // Scroll to bottom after adding temporary image message
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollToBottom(animated: true);
    });
  }

  Future uploadImage(var pickedFile, {required String localPath}) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    try {
      await storageRef.putFile(File(pickedFile.path)).then((p) async {
        final url = await storageRef.getDownloadURL();
        // Update the previously sent temporary message with the real image URL
        _replaceTemporaryImageMessage(localPath, url);
      }).timeout(Duration(seconds: 50));
    } catch (error) {
      print(error);
    }
  }

  void _replaceTemporaryImageMessage(String localPath, String imageUrl) async {
    // Find and update the message in Firestore where message == localPath and pending == true
    String? id = widget.chatId ?? widget.createChatid;
    var chatCollection = FirebaseFirestore.instance
        .collection("chat")
        .doc(id)
        .collection("messages");
    var query = await chatCollection
        .where("message", isEqualTo: localPath)
        .where("pending", isEqualTo: true)
        .get();
    for (var doc in query.docs) {
      await doc.reference.update({
        "message": imageUrl,
        "pending": FieldValue.delete(), // Remove the pending flag
      });
    }
  }
}
