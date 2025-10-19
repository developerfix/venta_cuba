import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/Utils/funcations.dart';
import 'package:venta_cuba/view/Navigation%20bar/post.dart';
import 'package:venta_cuba/view/constants/Colors.dart';
import '../../../Controllers/home_controller.dart';
// Firebase removed for Cuba compatibility
// import '../../../Services/Firebase/firebase_messaging_service.dart';
import '../../../Utils/global_variabel.dart';
import '../Controller/SupabaseChatController.dart';
import '../../../Services/push_service.dart';
import '../custom_text.dart';
import '../widgets/message_tile.dart';

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

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  // Firebase removed for Cuba compatibility
  // final firebaseMessagingService = FirebaseMessagingService();
  final chatCont = Get.put(SupabaseChatController());
  final homeCont = Get.put(HomeController());
  final authCont = Get.put(AuthController());
  bool isKeyBoardOpen = true;
  late FocusNode focusNode;

  Stream<List<Map<String, dynamic>>>? messagesStream;

  @override
  void dispose() {
    chatCont.isShow = false;
    isONImageScreen = false;
    isKeyBoardOpen = true;
    focusNode.dispose();

    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);

    // Mark chat as read when user leaves the chat page
    if (widget.chatId != null && authCont.user?.userId != null) {
      chatCont.markChatAsRead(
        widget.chatId!,
        authCont.user!.userId.toString(),
      );
    }

    // Set chat screen as closed when leaving
    PushService.setChatScreenStatus(false, null);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // CRITICAL: Update PushService about app state for notification logic
    final isInForeground = state == AppLifecycleState.resumed;
    PushService.setAppLifecycleState(isInForeground);

    if (state == AppLifecycleState.resumed && mounted) {
      print('🔄 ChatPage: App resumed - refreshing messages for chat ${widget.chatId}');

      // CRITICAL: Refresh messages for this specific chat when app resumes
      if (widget.chatId != null) {
        chatCont.refreshChatMessages(widget.chatId!);
        print('✅ Messages refreshed for chat ${widget.chatId}');
      }

      // Also update read status and notifications
      if (widget.chatId != null && authCont.user?.userId != null) {
        chatCont.markChatAsRead(
          widget.chatId!,
          authCont.user!.userId.toString(),
        );
      }
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      print('📱 ChatPage: App backgrounded while chat ${widget.chatId} was open');
      print('📱 Notifications will now be allowed for this chat while app is backgrounded');
    }
  }

  @override
  void didChangeDependencies() {
    if (!isONImageScreen && isKeyBoardOpen) {
      _requestFocus();
      isKeyBoardOpen = false;
    }
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

    // Add lifecycle observer to detect app state changes
    WidgetsBinding.instance.addObserver(this);

    focusNode = FocusNode();

    // Set chat screen status immediately
    PushService.setChatScreenStatus(true, widget.chatId);

    // Set user as online when entering chat
    if (authCont.user?.userId != null) {
      chatCont.setUserOnline(authCont.user!.userId.toString());
    }

    // Test Supabase connection before setting up chat
    _testSupabaseBeforeChat();

    getChat();
    saveFile();

    // Preload chat data for instant loading
    if (widget.chatId != null) {
      chatCont.prewarmChatData(widget.chatId!);
    }

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeCont.listingModel = null;
      homeCont.update();

      if (widget.listingId != null &&
          widget.listingId!.isNotEmpty &&
          widget.listingId != "null") {
        homeCont.getListingDetails(widget.listingId!, showDialog: false);
      } else {}
    });
  }

  // Update device tokens when chat is opened
  Future<void> updateDeviceTokensOnChatOpen() async {
    try {
      if (widget.chatId != null && authCont.user?.userId != null) {
        await chatCont.updateDeviceTokenInChat(
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
    } catch (e) {}
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
      Timer(Duration(milliseconds: 100),
          () => _scrollToBottom(animated: animated));
    }
  }

  void _requestFocus() {
    FocusScope.of(context).requestFocus(focusNode);
  }

  // Test Supabase connection before initializing chat
  void _testSupabaseBeforeChat() async {
    try {
      await chatCont.testSupabaseConnection();
    } catch (e) {}
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

      if (id != null && id.isNotEmpty && id != 'null') {
        // Force clear any existing stream to ensure fresh data
        chatCont.clearChatStream(id);

        setState(() {
          messagesStream = chatCont.getChatMessages(id);
        });

        // Test the stream immediately
        messagesStream!.listen(
          (data) {
            // Stream data received
          },
          onError: (error) {
            // Stream error occurred
          },
          onDone: () {
            // Stream closed
          },
        );
      } else {
        // Set an empty stream to prevent null issues
        setState(() {
          messagesStream = Stream.value(<Map<String, dynamic>>[]);
        });
      }
    } catch (e) {
      // Set an error stream
      setState(() {
        messagesStream = Stream.error(e);
      });
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CachedNetworkImage(
                height: 50.h,
                width: 50.w,
                imageUrl: "${widget.userImage}",
                imageBuilder: (context, imageProvider) => Container(
                  height: 180.h,
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
                    height: 50.h,
                    width: 50.w,
                    child: Center(
                        child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ))),
                errorWidget: (context, url, error) {
                  return Container(
                    height: 50.h,
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
                        ? "No Name".tr
                        : widget.userName ?? "No Name".tr,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    fontColor: Theme.of(context).textTheme.bodyLarge?.color ??
                        Colors.black,
                  ),

                  SizedBox(height: 2.h),
                  // Show last active time or online status
                  if (widget.remoteUid != null)
                    FutureBuilder<Map<String, dynamic>>(
                      future: chatCont.getUserPresence(widget.remoteUid!),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          Map<String, dynamic> presenceData = snapshot.data!;

                          bool isOnline = chatCont.isUserOnline(presenceData);
                          DateTime? lastActiveTime =
                              presenceData['last_active_time'] != null
                                  ? DateTime.parse(
                                          presenceData['last_active_time'])
                                      .toLocal()
                                  : null;

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
                            child: _getListingImage().isEmpty
                                ? Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      color: Colors.grey[300],
                                    ),
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey[600],
                                      size: 20,
                                    ),
                                  )
                                : CachedNetworkImage(
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
                                      return Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(7),
                                          color: Colors.grey[300],
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
          GetBuilder<SupabaseChatController>(builder: (cont) {
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
                        // Flexible container that adjusts to content
                        constraints: BoxConstraints(
                          maxHeight: 120.h, // Maximum height (about 4 lines)
                        ),
                        child: IntrinsicHeight(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.black
                                    : Colors.white,
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
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                    width: 1)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: TextField(
                                    focusNode: focusNode,
                                    controller: cont.messageController,
                                    maxLines:
                                        null, // Allow unlimited lines within maxHeight
                                    minLines: 1, // Start with 1 line only
                                    keyboardType: TextInputType.multiline,
                                    textAlignVertical: TextAlignVertical.center,
                                    scrollPhysics: BouncingScrollPhysics(),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                    ),
                                    decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 0,
                                          vertical:
                                              12.h, // Proper vertical padding
                                        ),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                        hintText: 'Type Message'.tr,
                                        hintStyle: TextStyle(
                                          fontSize: 14.sp,
                                          color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color
                                                  ?.withValues(alpha: 0.5) ??
                                              Colors.black
                                                  .withValues(alpha: 0.5),
                                        )),
                                    onTap: () {
                                      Future.delayed(
                                          Duration(milliseconds: 300), () {
                                        _scrollToBottom(animated: true);
                                      });
                                      cont.update();
                                    },
                                    onChanged: (String? value) {
                                      if (cont
                                          .messageController.text.isNotEmpty) {
                                        chatCont.isTyping = true;
                                        cont.update();
                                      } else {
                                        cont.isTyping = false;
                                        cont.update();
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 2.h),
                                  child: IconButton(
                                    constraints: BoxConstraints(
                                      minHeight: 35.h,
                                      minWidth: 35.w,
                                    ),
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      Icons.send,
                                      size: 22.sp,
                                      color: cont.isTyping
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context).iconTheme.color,
                                    ),
                                    onPressed: () async {
                                      // Immediate UI feedback - disable button temporarily
                                      sendMessage('text');
                                      cont.update();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                  ],
                ),
              ),
            );
          }),
          GetBuilder<SupabaseChatController>(builder: (cont) {
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

  chatMessages() {
    if (messagesStream == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initializing chat...'.tr),
          ],
        ),
      );
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: messagesStream,
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 64),
                SizedBox(height: 16),
                Text('Error loading messages'.tr,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('${snapshot.error}', style: TextStyle(color: Colors.red)),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    getChat(); // Retry loading
                  },
                  child: Text('Retry'.tr),
                ),
              ],
            ),
          );
        }

        // Handle different connection states with timeout
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 64),
                  SizedBox(height: 16),
                  Text('No connection to messages'.tr),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      getChat();
                    },
                    child: Text('Try Again'.tr),
                  ),
                ],
              ),
            );
          case ConnectionState.waiting:
            // Show loading indicator while waiting for initial data
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading messages...'.tr),
                ],
              ),
            );
          case ConnectionState.active:
          case ConnectionState.done:
            break;
        }

        // For professional UX, don't show loading spinners
        // Real-time stream will populate data as it arrives
        final messages =
            snapshot.hasData ? snapshot.data! : <Map<String, dynamic>>[];
        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No messages yet'.tr,
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                SizedBox(height: 8),
                Text('Start the conversation!'.tr,
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        // Schedule scroll to bottom after the widget tree is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();

          // Mark chat as read when messages are displayed and user scrolls to bottom
          if (widget.chatId != null && authCont.user?.userId != null) {
            Future.delayed(Duration(milliseconds: 1000), () {
              chatCont.markChatAsRead(
                widget.chatId!,
                authCont.user!.userId.toString(),
              );
            });
          }
        });

        return Column(
          children: [
            GetBuilder<SupabaseChatController>(builder: (cont) {
              return Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: 20.h, top: 80.h),
                  controller: cont.scrollController,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var message = snapshot.data![index];
                    var sendBy = message['send_by'];

                    DateTime? messageTime = message['time'] != null
                        ? DateTime.tryParse(message['time'])?.toLocal()
                        : null;
                    String formattedTime = messageTime != null
                        ? _formatMessageTime(messageTime)
                        : "";

                    return "${authCont.user?.userId}" == sendBy
                        ? Slidable(
                            endActionPane: ActionPane(
                              extentRatio: 0.25,
                              motion: StretchMotion(),
                              children: [
                                SlidableAction(
                                  icon: Icons.save,
                                  label: "Save".tr,
                                  backgroundColor: Colors.blue,
                                  onPressed: (context) {
                                    if (message['message_type'] == 'image') {
                                      // saveImageToGallery(message['message']);
                                    }
                                  },
                                ),
                              ],
                            ),
                            child: MessageTile(
                                message: message['message'] ?? '',
                                sender: message['sender_name'] ?? '',
                                messageType: message['message_type'] ?? 'text',
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
                                  label: "Save".tr,
                                  backgroundColor: Colors.blue,
                                  onPressed: (context) {
                                    if (message['message_type'] == 'image') {
                                      // saveImageToGallery(message['message']);
                                    }
                                  },
                                ),
                              ],
                            ),
                            child: MessageTile(
                                message: message['message'] ?? '',
                                sender: message['sender_name'] ?? '',
                                messageType: message['message_type'] ?? 'text',
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
        // Capture message and clear input immediately for better UX
        String message = chatCont.messageController.text;
        chatCont.messageController.clear();

        String? id = widget.chatId ?? widget.createChatid;

        Map<String, dynamic> chatMessageData = {
          "message": message,
          "messageType": messageType,
          "senderName":
              "${authCont.user?.firstName} ${authCont.user?.lastName}",
          "sendBy": "${authCont.user?.userId}",
          "senderId": "${authCont.user?.userId}",
          "sendToId": widget.remoteUid,
          "sendToName": widget.userName,
          "senderImage": authCont.user?.profileImage,
          "sendToImage": widget.userImage,
          "userDeviceToken": deviceToken,
          "sendToDeviceToken": widget.deviceToken,
          "image": messageType == "image" ? message : null,
          // Include listing information for database storage
          "listingId": widget.listingId,
          "listingName": widget.listingName,
          "listingImage": widget.listingImage,
          "listingPrice": widget.listingPrice,
          "listingLocation": widget.listingLocation,
        };

        // Send message without blocking UI with retry logic
        chatCont.sendMessage(id ?? "", chatMessageData).catchError((e) {
          print('📱 First message send attempt failed: $e');

          // Attempt retry after a short delay for new contacts
          Future.delayed(Duration(milliseconds: 500), () async {
            try {
              await chatCont.sendMessage(id ?? "", chatMessageData);
              print('✅ Message sent successfully on retry');
            } catch (retryError) {
              print('❌ Retry also failed: $retryError');
              // Only show error if retry also fails
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Unable to send message. Please try again."),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                    action: SnackBarAction(
                      label: 'Retry',
                      textColor: Colors.white,
                      onPressed: () {
                        sendMessage('text'); // Retry sending
                      },
                    ),
                  ),
                );
              }
            }
          });
        });

        // Scroll to bottom immediately
        _scrollToBottom(animated: true);

        // Notifications are sent automatically by SupabaseChatController
        // No need for additional notification calls
      }
    } catch (e) {
      // Log error but don't show intrusive message for common issues
      print('❌ Message send error in _sendMessage: $e');

      // Only show error for critical issues, not for common recoverable ones
      if (!e.toString().toLowerCase().contains('unique') &&
          !e.toString().toLowerCase().contains('duplicate') &&
          !e.toString().toLowerCase().contains('already exists')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Message send failed. Please try again."),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                sendMessage('text'); // Retry sending
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> sendNotificationToRecipient(
      String message, String messageType) async {
    try {
      // CRITICAL CHECK: Are you sending to yourself?
      if ("${authCont.user?.userId}" == widget.remoteUid) {
        return;
      }

      // Update sender's device token in chat document before sending notification
      if (widget.chatId != null && authCont.user?.userId != null) {
        await chatCont.updateDeviceTokenInChat(
          authCont.user!.userId.toString(),
          deviceToken,
        );
      }

      // Get the most recent device token from chat document
      String? deviceTokenToUse = await getRecipientDeviceToken();

      // Validate device token
      if (deviceTokenToUse == null || deviceTokenToUse.isEmpty) {
        return;
      }

      // Basic validation of device token format
      if (deviceTokenToUse.length < 50) {
        // Token seems short but proceed anyway
      }

      // Send the notification
      bool notificationSent = await sendNotificationWithRetry(
        deviceTokenToUse,
        messageType,
        message,
      );

      if (notificationSent) {
        // Notification sent successfully
      } else {
        // Failed to send notification
      }
    } catch (e) {
      // Error sending notification
    }
  }

  // Get recipient's device token - now handled by Supabase
  Future<String?> getRecipientDeviceToken() async {
    try {
      // Device tokens are now managed by Supabase automatically
      // This method is kept for compatibility but returns the fallback token
      return widget.deviceToken;
    } catch (e) {
      return widget.deviceToken; // Fallback to original token
    }
  }

  Future<bool> sendNotificationWithRetry(
      String deviceToken, String messageType, String message) async {
    try {
      // Notifications are now handled automatically by SupabaseChatController
      // This method is kept for compatibility but notifications are sent elsewhere
      return true; // Always return true since notifications are handled elsewhere
    } catch (e) {
      return false;
    }
  }

  // Helper methods for listing data
  String _getListingImage() {
    if (homeCont.listingModel?.gallery != null &&
        homeCont.listingModel!.gallery!.isNotEmpty) {
      String imageUrl = homeCont.listingModel!.gallery!.first;
      if (imageUrl.isNotEmpty && imageUrl != "null") {
        return imageUrl;
      }
    }
    String fallbackUrl = widget.listingImage ?? "";
    if (fallbackUrl.isNotEmpty && fallbackUrl != "null") {
      return fallbackUrl;
    }
    return "";
  }

  String _getListingTitle() {
    // First try to get from API data
    if (homeCont.listingModel?.title != null &&
        homeCont.listingModel!.title!.isNotEmpty &&
        homeCont.listingModel!.title != "null") {
      return homeCont.listingModel!.title!;
    }

    // Then try from widget parameters (passed from navigation)
    if (widget.listingName != null &&
        widget.listingName!.isNotEmpty &&
        widget.listingName != "null") {
      return widget.listingName!;
    }

    // Default fallback - avoid showing "Anuncio"
    return "Listing".tr;
  }

  String _getListingLocation() {
    if (homeCont.listingModel?.address != null &&
        homeCont.listingModel!.address!.isNotEmpty &&
        homeCont.listingModel!.address != "null") {
      return homeCont.listingModel!.address!;
    }
    if (widget.listingLocation != null &&
        widget.listingLocation!.isNotEmpty &&
        widget.listingLocation != "null") {
      return widget.listingLocation!;
    }
    return "";
  }

  String _getFormattedPrice() {
    String price = "0";
    String currency = "USD";

    if (homeCont.listingModel?.price != null &&
        homeCont.listingModel!.price!.isNotEmpty &&
        homeCont.listingModel!.price != "null") {
      price = homeCont.listingModel!.price!;
      currency = homeCont.listingModel?.currency ?? "USD";
    } else if (widget.listingPrice != null &&
        widget.listingPrice!.isNotEmpty &&
        widget.listingPrice != "null") {
      price = widget.listingPrice!;
    }

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

  bool _shouldShowPrice() {
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

  updateImage() async {
    Map<String, dynamic> chatUpdateData = {
      "${widget.senderId}" == "${authCont.user?.userId}"
          ? "sender_image"
          : "send_to_image": "${authCont.user?.profileImage}",
    };

    String? id = widget.chatId ?? widget.createChatid;
    if (id != null) {
      try {
        await chatCont.supabaseClient
            .from('chats')
            .update(chatUpdateData)
            .eq('id', id);
      } catch (e) {}
    }
  }

  void _openCamera(BuildContext context) async {
    try {
      // Request camera permission
      final cameraStatus = await Permission.camera.request();

      if (cameraStatus.isGranted) {
        final pickedFile = await ImagePicker().pickImage(
          source: ImageSource.camera,
        );
        if (pickedFile != null) {
          uploadImage(pickedFile);
        }
      } else if (cameraStatus.isPermanentlyDenied) {
        // Show dialog to open settings
        _showPermissionDialog('Camera');
      } else {
        // Permission denied - silent failure
        print('Camera permission denied');
      }
    } catch (e) {
      // Camera error - silent failure
      print('Failed to open camera: ${e.toString()}');
    }
  }

  void _openGallery(BuildContext context) async {
    try {
      // Request photo library permission
      PermissionStatus photoStatus;
      if (Platform.isIOS) {
        photoStatus = await Permission.photos.request();
      } else {
        // Android 13+ uses photos, earlier versions use storage
        photoStatus = await Permission.photos.request();

        // Fallback to storage permission for older Android versions
        if (!photoStatus.isGranted) {
          photoStatus = await Permission.storage.request();
        }
      }

      if (photoStatus.isGranted) {
        final pickedFile = await ImagePicker().pickImage(
          source: ImageSource.gallery,
        );
        if (pickedFile != null) {
          uploadImage(pickedFile);
        }
      } else if (photoStatus.isPermanentlyDenied) {
        // Show dialog to open settings
        _showPermissionDialog('Photo Library');
      } else {
        // Permission denied - silent failure
        print('Gallery permission denied');
      }
    } catch (e) {
      // Gallery error - silent failure
      print('Failed to open gallery: ${e.toString()}');
    }
  }

  void _showPermissionDialog(String permissionName) {
    Get.dialog(
      AlertDialog(
        title: Text('Permission Required'.tr),
        content: Text(
            '$permissionName permission is required to send photos in chat. Please enable it in settings.'
                .tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: Text('Open Settings'.tr),
          ),
        ],
      ),
    );
  }

  Future uploadImage(var pickedFile) async {
    try {
      showLoading();

      String? imageUrl = await chatCont.uploadImage(pickedFile);

      Get.back(); // Hide loading

      if (imageUrl != null) {
        // Send image message
        await sendImageMessage(imageUrl);
      } else {
        // Silent failure - image upload returned null but no exception
        print('Image upload failed: uploadImage returned null');
      }
    } catch (error) {
      Get.back(); // Hide loading

      // Log the error for debugging but don't show to user
      print('Image upload error: ${error.toString()}');

    }
  }

  Future sendImageMessage(String imageUrl) async {
    try {
      String? id = widget.chatId ?? widget.createChatid;

      Map<String, dynamic> chatMessageData = {
        "message": imageUrl,
        "messageType": "image",
        "senderName": "${authCont.user?.firstName} ${authCont.user?.lastName}",
        "sendBy": "${authCont.user?.userId}",
        "senderId": "${authCont.user?.userId}",
        "sendToId": widget.remoteUid,
        "sendToName": widget.userName,
        "senderImage": authCont.user?.profileImage,
        "sendToImage": widget.userImage,
        "userDeviceToken": deviceToken,
        "sendToDeviceToken": widget.deviceToken,
        "image": imageUrl,
        // Include listing information for database storage
        "listingId": widget.listingId,
        "listingName": widget.listingName,
        "listingImage": widget.listingImage,
        "listingPrice": widget.listingPrice,
        "listingLocation": widget.listingLocation,
      };

      await chatCont.sendMessage(id ?? "", chatMessageData);

      // Scroll to bottom
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollToBottom(animated: true);
      });

      // Firebase notifications are sent automatically by SupabaseChatController
    } catch (e) {
    }
  }

  String _formatMessageTime(DateTime messageTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final messageDate =
        DateTime(messageTime.year, messageTime.month, messageTime.day);

    if (messageDate == today) {
      // Today: show only time
      return DateFormat('h:mm a').format(messageTime);
    } else if (messageDate == yesterday) {
      // Yesterday: show "Yesterday HH:MM"
      return "${'Yesterday'.tr} ${DateFormat('h:mm a').format(messageTime)}";
    } else if (now.difference(messageTime).inDays < 7) {
      // This week: show day name and time
      return "${DateFormat('EEEE h:mm a').format(messageTime)}";
    } else if (messageTime.year == now.year) {
      // This year: show month, day and time
      return "${DateFormat('MMM d, h:mm a').format(messageTime)}";
    } else {
      // Different year: show full date and time
      return "${DateFormat('MMM d, yyyy h:mm a').format(messageTime)}";
    }
  }
}
