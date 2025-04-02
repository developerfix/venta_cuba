import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
    gettingUserData();
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
          backgroundColor: Colors.transparent,
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
              return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  if (snapshot.data.docs[index]['senderId'] ==
                          "${authCont.user?.userId}" ||
                      snapshot.data.docs[index]['sendToId'] ==
                          "${authCont.user?.userId}") {
                    return GroupTile(
                        userChatId: snapshot.data.docs[index].id,
                        senderId: snapshot.data.docs[index]['senderId'],
                        listingImage: snapshot.data.docs[index]['listingImage'],
                        listingId: snapshot.data.docs[index]['listingId'],
                        listingName: snapshot.data.docs[index]['listingName'],
                        listingPrice: snapshot.data.docs[index]['listingPrice'],
                        listingLocation: snapshot.data.docs[index]
                            ['listingLocation'],
                        lastMessage: snapshot.data.docs[index]['message'],
                        messageType: snapshot.data.docs[index]['messageType'],
                        messageTime: snapshot.data.docs[index]['messageTime'],
                        userName: snapshot.data.docs[index]['senderId'] ==
                                "${authCont.user?.userId}"
                            ? snapshot.data.docs[index]['sendToName']
                            : snapshot.data.docs[index]['userName'],
                        userImage: snapshot.data.docs[index]['senderId'] ==
                                "${authCont.user?.userId}"
                            ? snapshot.data.docs[index]['senderToImage']
                            : snapshot.data.docs[index]['senderImage'],
                        deviceToken: snapshot.data.docs[index]['senderId'] ==
                                "${authCont.user?.userId}"
                            ? snapshot.data.docs[index]['sendToDeviceToken']
                            : snapshot.data.docs[index]['userDeviceToken'],
                        remoteUid: snapshot.data.docs[index]['senderId'] ==
                                "${authCont.user?.userId}"
                            ? snapshot.data.docs[index]['sendToId']
                            : snapshot.data.docs[index]['senderId']);
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
