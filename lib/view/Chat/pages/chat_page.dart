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

  @override
  void dispose() {
    chatCont.isShow = false;
    isONImageScreen = false;
    isKeyBoardOpen = true;
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

    focusNode = FocusNode();
    getChat();
    saveFile();

    chatCont.scrollController.addListener(() {
      if (chatCont.scrollController.position.pixels ==
          chatCont.scrollController.position.maxScrollExtent) {
        chatCont.isShow = false;
        chatCont.update();
      } else {
        chatCont.isShow = true;
        chatCont.update();
      }
    });
    chatCont.isLast = widget.isLast ?? false;
    updateImage();
  }

  void _scrollToBottom() {
    if (chatCont.scrollController.hasClients) {
      chatCont.scrollController
          .jumpTo(chatCont.scrollController.position.maxScrollExtent);
    } else {
      Timer(Duration(milliseconds: 400), () => _scrollToBottom());
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    return Scaffold(
      backgroundColor: Colors.white,
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
              color: Color(0xFF373535),
            ),
          ),
        ),
        title: Row(
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
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            SizedBox(
              width: 16.w,
            ),
            SizedBox(
              height: 50..h,
              child: SelectionArea(
                child: Center(
                  child: CustomText(
                    text: widget.userName == ""
                        ? "No Name"
                        : widget.userName ?? "No Name",
                    fontSize: 16..sp,
                    fontWeight: FontWeight.w600,
                    fontColor: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          // chat messages here
          chatMessages(),
          InkWell(
            onTap: () {
              homeCont.getListingDetails("${widget.listingId}");
            },
            child: Container(
              width: double.maxFinite,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                    color: Colors.black26, blurRadius: 5, offset: Offset(0, 5))
              ]),
              child: Row(
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: CachedNetworkImage(
                        height: 50,
                        width: 50,
                        imageUrl: widget.listingImage ?? "",
                        imageBuilder: (context, imageProvider) => Container(
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
                        errorWidget: (context, url, error) =>
                            Center(child: Text("No Image".tr)),
                      )),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(
                          text:
                              "\$${homeCont.listingModel?.price ?? widget.listingPrice}"),
                      CustomText(
                          text: homeCont.listingModel?.title ??
                              widget.listingName),
                      CustomText(
                          text: homeCont.listingModel?.address ??
                              widget.listingLocation),
                    ],
                  )
                ],
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30.r),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: 4,
                                offset: Offset(0, 0),
                                spreadRadius: 0,
                              )
                            ],
                            border: Border.all(color: Colors.black)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 4..w),
                            Expanded(
                              child: TextField(
                                focusNode: focusNode,
                                controller: cont.messageController,
                                decoration: InputDecoration.collapsed(
                                    hintText: 'Type Message'.tr,
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black.withOpacity(0.5),
                                    )),
                                onTap: () {
                                  print("object");

                                  // cont.scrollController.jumpTo(chatCont
                                  //     .scrollController
                                  //     .position
                                  //     .physics
                                  //     .maxFlingVelocity);
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
                              // height: 35..h,
                              // width: 42..w,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.send,
                                    color: cont.isTyping
                                        ? Colors.blue
                                        : Colors.grey,
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
                    chatCont.scrollController.jumpTo(
                        chatCont.scrollController.position.maxScrollExtent);
                  },
                  child: Container(
                    height: 40.h,
                    width: 40.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(
                              0, 3), // changes the position of the shadow
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_downward_rounded,
                      color: Colors.black,
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
        return snapshot.hasData
            ? Column(
                children: [
                  GetBuilder<ChatController>(builder: (cont) {
                    return Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.only(bottom: 20.h, top: 20.h),
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
                                      message: snapshot.data.docs[index]
                                          ['message'],
                                      sender: snapshot.data.docs[index]
                                          ['sender'],
                                      messageType: snapshot.data.docs[index]
                                          ['messageType'],
                                      messageTime: formattedTime,
                                      sentByMe:
                                          "${authCont.user?.userId}" == sendBy),
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
                                      message: snapshot.data.docs[index]
                                          ['message'],
                                      sender: snapshot.data.docs[index]
                                          ['sender'],
                                      messageType: snapshot.data.docs[index]
                                          ['messageType'],
                                      messageTime: formattedTime,
                                      sentByMe:
                                          "${authCont.user?.userId}" == sendBy),
                                );
                        },
                      ),
                    );
                  }),
                  SizedBox(
                    height: 53.h,
                  )
                ],
              )
            : Container();
      },
    );
  }

  Future sendMessage(String messageType) async {
    try {
      if (chatCont.messageController.text.isNotEmpty) {
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
        await chatCont.sendMessage(id ?? "", chatMessageMap);
        String message = chatCont.messageController.text;

        chatCont.scrollController
            .jumpTo(chatCont.scrollController.position.maxScrollExtent);
        chatCont.messageController.clear();
        Future.delayed(Duration(milliseconds: 500), () {
          if (chatCont.scrollController.hasClients) {
            chatCont.scrollController.jumpTo(
              chatCont.scrollController.position.maxScrollExtent,
            );
          }
        });
        firebaseMessaging.sendNotificationFCM(
            title: "${authCont.user?.firstName} ${authCont.user?.lastName}",
            name: "${authCont.user?.firstName} ${authCont.user?.lastName}",
            body: messageType == "voice"
                ? "Voice Message"
                : messageType == "image"
                    ? "Image"
                    : message,
            deviceToken: widget.deviceToken,
            userId: authCont.user?.userId.toString(),
            remoteId: widget.remoteUid,
            profileImage: "",
            type: "message");
      }
    } catch (e) {
      print("Error sending message: $e");
    }
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
    await uploadImage(pickedFile);
    sendMessage("image");
  }

  void _openGallery(BuildContext context) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    await uploadImage(pickedFile);
    sendMessage("image");
  }

  Future uploadImage(var pickedFile) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');

    await storageRef
        .putFile(File(pickedFile.path))
        .then((p) async {
          final url = await storageRef.getDownloadURL();
          chatCont.messageController.text = url ?? "";
        })
        .timeout(Duration(seconds: 50))
        .onError((error, stackTrace) {
          print(error);
        });
  }
}
