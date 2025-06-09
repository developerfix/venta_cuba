import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';

import '../constants/Colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final homeCont = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: GetBuilder<HomeController>(
        builder: (cont) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10..h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 18,
                        ),
                      ),
                      Text(
                        'Notifications'.tr,
                        style: TextStyle(
                            fontSize: 20..sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      Container(
                        width: 10..w,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30..h,
                  ),
                  Expanded(
                    child: ListView.separated(
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 280.w,
                                    child: SelectionArea(
                                      child: Text(
                                        '${cont.allNotificationModel?.data?[index].message}',
                                        style: TextStyle(
                                            fontSize: 16..sp,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.black),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      cont.notificationId = cont
                                          .allNotificationModel
                                          ?.data?[index]
                                          .id;
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return deleteNotification(index);
                                        },
                                      );
                                    },
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.grey,
                                    ),
                                  )
                                ],
                              ),
                              Divider()
                            ],
                          );
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(
                            height: 10.h,
                          );
                        },
                        itemCount:
                            cont.allNotificationModel?.data?.length ?? 0),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  deleteNotification(int index) {
    return AlertDialog(
      title: Text('Delete'.tr),
      content: Text('Are you sure you want to delete this item?'.tr),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Cancel'.tr),
        ),
        TextButton(
          onPressed: () async {
            bool isDeleted = await homeCont.deleteNotification();
            Navigator.of(context).pop();
            isDeleted
                ? homeCont.allNotificationModel?.data?.removeAt(index)
                : null;
            homeCont.update();
          },
          child: Text('Delete'.tr),
        ),
      ],
    );
  }
}
