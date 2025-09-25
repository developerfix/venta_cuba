import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/Utils/funcations.dart';
import 'package:venta_cuba/util/my_button.dart';
import 'package:venta_cuba/view/Chat/custom_text.dart';
import 'package:venta_cuba/view/constants/Colors.dart';
import 'package:venta_cuba/view/payment/VideoPalyScreen.dart';
import 'package:video_player/video_player.dart';

import '../../Controllers/home_controller.dart';
import '../video_screen/video_screen.dart';

class PaymentNext extends StatefulWidget {
  final bool fromCuba;
  PaymentNext({super.key, required this.fromCuba});

  @override
  State<PaymentNext> createState() => _PaymentNextState();
}

class _PaymentNextState extends State<PaymentNext> {
  AuthController authController = Get.put(AuthController());
  final homeCont = Get.put(HomeController());
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController expiryMonthController = TextEditingController();
  TextEditingController expiryYearController = TextEditingController();
  TextEditingController cvc = TextEditingController();
  TextEditingController? transactionUserNameController;
  TextEditingController? transactionPhoneController;
  late VideoPlayerController _controller;
  String? countyCode;
  void getCountryCode() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    countyCode = sharedPreferences.getString("country_code") ?? "+53";
    print(countyCode);

    initialize();
    setState(() {});
  }

  void initialize() {
    homeCont.isCheckedList[0] = false;
    homeCont.isCheckedList[1] = false;
    homeCont.isCheckedList[2] = false;
    homeCont.isCheckedList[3] = false;
    homeCont.isCheckedList[4] = false;
    homeCont.update();
    homeCont.transactionNumberController.clear();
    transactionUserNameController = TextEditingController(
        text:
            "${authController.user?.firstName} ${authController.user?.lastName}");
    transactionPhoneController = TextEditingController(
        text: "${countyCode}${authController.user?.phoneNo}");
  }

  @override
  void initState() {
    super.initState();
    homeCont.videoPath = null;
    getCountryCode();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: GetBuilder(
        init: HomeController(),
        builder: (cont) {
          return InkWell(
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                            Center(
                              child: Text(
                                'Transaction'.tr,
                                style: TextStyle(
                                    fontSize: 20..sp,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.color),
                              ),
                            ),
                            SizedBox(width: 25.w),
                          ],
                        ),
                        SizedBox(
                          height: 10..h,
                        ),
                        Center(
                          child: Image.asset(
                            'assets/images/notImage.jpg',
                            height: 200.h,
                            width: 200.w,
                          ),
                        ),
                        SizedBox(height: 10..h),
                        Center(
                          child: Text(
                            widget.fromCuba
                                ? 'Transfer Money'.tr
                                : 'Payment'.tr,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 26..sp,
                                color: AppColors.black),
                          ),
                        ),
                        widget.fromCuba
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20..h),
                                  // Text(
                                  //   'Read all steps carefully if you don\'t want to lose your money'.tr,
                                  //   style: TextStyle(
                                  //       fontSize: 16..sp,
                                  //       fontWeight: FontWeight.w500,
                                  //       color: AppColors.k0xFF403C3C),
                                  // ),
                                  // SizedBox(height: 10),
                                  Text(
                                    'Step 1:'.tr,
                                    style: TextStyle(
                                        fontSize: 16..sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.k0xFF403C3C),
                                  ),

                                  SizedBox(height: 10),
                                  Text(
                                    'Send 1 MLC to this bank account\nnumber: 9235-1299-7726-1358'
                                        .tr,
                                    style: TextStyle(
                                        fontSize: 16..sp,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.k0xFF403C3C),
                                  ),
                                  Visibility(
                                    visible: Platform.isIOS,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 10),
                                        Text(
                                          "${'iPhone user'.tr}:",
                                          style: TextStyle(
                                              fontSize: 16..sp,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.k0xFF403C3C),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'Record a video of your phone screen showing the money transfer and upload it below.We show you in the video how to add the tool to record your screen on iPhone.This video needs to be the same as the example.If not, we won\'t be able to validate if the money has been send to us and we won\'t give you access. Each video uploaded will be reviewed.'
                                              .tr,
                                          style: TextStyle(
                                              fontSize: 16..sp,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.k0xFF403C3C),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'new_instruction_iso'.tr,
                                          style: TextStyle(
                                              fontSize: 16..sp,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.k0xFF403C3C),
                                        ),
                                        SizedBox(height: 10),
                                        Center(
                                          child: InkWell(
                                            onTap: () =>
                                                Get.to(VideoPlayerScreen()),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 35, vertical: 5),
                                              // height: 20,
                                              decoration: BoxDecoration(
                                                  color: Color(0xFF0254B8),
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: CustomText(
                                                text: "How to pay".tr,
                                                fontColor: Colors.white,
                                                fontSize: 20.sp,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: Platform.isAndroid,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 10.h),
                                      child: Center(
                                        child: InkWell(
                                          onTap: () =>
                                              Get.to(VideoPlayerScreen()),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 35, vertical: 5),
                                            // height: 20,
                                            decoration: BoxDecoration(
                                                color: Color(0xFF0254B8),
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: CustomText(
                                              text: "How to pay".tr,
                                              fontColor: Colors.white,
                                              fontSize: 20.sp,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: Platform.isAndroid,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 10),
                                        // Text(
                                        //   '${"Android user".tr}:',
                                        //   style: TextStyle(
                                        //       fontSize: 16..sp,
                                        //       fontWeight: FontWeight.w700,
                                        //       color: AppColors.k0xFF403C3C),
                                        // ),
                                        // SizedBox(height: 10),
                                        Text(
                                          'You don\'t have upload a video for money transfer, but you need to put this phone number during the transfer:\n000-000-0000\n\nIf you fail to put this phone number, your money will be lost'
                                              .tr,
                                          style: TextStyle(
                                              fontSize: 16..sp,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.k0xFF403C3C),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'upload_video'.tr,
                                          style: TextStyle(
                                              fontSize: 16..sp,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.k0xFF403C3C),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: Platform.isIOS,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            cont.pickVideo().then((value) {
                                              _controller =
                                                  VideoPlayerController.file(
                                                      File(cont.videoPath!))
                                                    ..initialize().then((_) {
                                                      setState(() {});
                                                    });
                                            });
                                          },
                                          child: Container(
                                            height: 165..h,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 2),
                                            child: DottedBorder(
                                                borderType: BorderType.RRect,
                                                color: AppColors.k0xFFC4C4C4,
                                                // Border color
                                                strokeWidth: 1,
                                                // Border width
                                                radius: Radius.circular(10),
                                                child: cont.videoPath != null
                                                    ? Center(
                                                        child: InkWell(
                                                          onTap: () {
                                                            Get.to(VideoPlayerScreenFile(
                                                                file: File(cont
                                                                    .videoPath!)));
                                                          },
                                                          child: AspectRatio(
                                                              aspectRatio:
                                                                  _controller
                                                                      .value
                                                                      .aspectRatio,
                                                              child: VideoPlayer(
                                                                  _controller)),
                                                        ),
                                                      )
                                                    // Text(
                                                    //         'Video Picked Successfully'.tr,
                                                    //         style: TextStyle(
                                                    //             fontSize: 13..sp,
                                                    //             fontWeight: FontWeight.w500,
                                                    //             color: AppColors.black),
                                                    //       )
                                                    : Center(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Image.asset(
                                                                'assets/images/upload.png'),
                                                            Text(
                                                              'Upload Your Video Here'
                                                                  .tr,
                                                              style: TextStyle(
                                                                  fontSize: 13
                                                                    ..sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: AppColors
                                                                      .black),
                                                            ),
                                                            Text(
                                                              'Maximum 20mb Size'
                                                                  .tr,
                                                              style: TextStyle(
                                                                  fontSize: 10
                                                                    ..sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: AppColors
                                                                      .k0xFFA9ABAC),
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 20..h),
                                  Image.asset(
                                    "assets/images/messageBank_opt.jpg",
                                    height: 150.h,
                                  ),
                                  SizedBox(height: 10),

                                  Text(
                                    'Enter Transaction Number'.tr,
                                    style: TextStyle(
                                        fontSize: 15..sp,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.k0xFF403C3C),
                                  ),
                                  SizedBox(height: 10..h),
                                  TextFormField(
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(13),
                                      UpperCaseTextFormatter(),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.length < 13) {
                                        return 'There should be 13 characters entered.'
                                            .tr;
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      _formKey.currentState?.validate();
                                    },
                                    controller:
                                        cont.transactionNumberController,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 15),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              color: Colors.white,
                                            )),
                                        errorBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              color: Colors.red,
                                            ))),
                                    cursorColor: AppColors.black,
                                  ),
                                  Visibility(
                                    visible: Platform.isAndroid,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 30..h,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            cont.pickVideo().then((value) {
                                              _controller =
                                                  VideoPlayerController.file(
                                                      File(cont.videoPath!))
                                                    ..initialize().then((_) {
                                                      setState(() {});
                                                    });
                                            });
                                          },
                                          child: Container(
                                            height: 165..h,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 2),
                                            child: DottedBorder(
                                                borderType: BorderType.RRect,
                                                color: AppColors.k0xFFC4C4C4,
                                                // Border color
                                                strokeWidth: 1,
                                                // Border width
                                                radius: Radius.circular(10),
                                                child: cont.videoPath != null
                                                    ? Center(
                                                        child: InkWell(
                                                          onTap: () {
                                                            Get.to(VideoPlayerScreenFile(
                                                                file: File(cont
                                                                    .videoPath!)));
                                                          },
                                                          child: AspectRatio(
                                                              aspectRatio:
                                                                  _controller
                                                                      .value
                                                                      .aspectRatio,
                                                              child: VideoPlayer(
                                                                  _controller)),
                                                        ),
                                                      )
                                                    // Text(
                                                    //         'Video Picked Successfully'.tr,
                                                    //         style: TextStyle(
                                                    //             fontSize: 13..sp,
                                                    //             fontWeight: FontWeight.w500,
                                                    //             color: AppColors.black),
                                                    //       )
                                                    : Center(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Image.asset(
                                                                'assets/images/upload.png'),
                                                            Text(
                                                              'Upload Your Video Here'
                                                                  .tr,
                                                              style: TextStyle(
                                                                  fontSize: 13
                                                                    ..sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: AppColors
                                                                      .black),
                                                            ),
                                                            Text(
                                                              'Maximum 20mb Size'
                                                                  .tr,
                                                              style: TextStyle(
                                                                  fontSize: 10
                                                                    ..sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: AppColors
                                                                      .k0xFFA9ABAC),
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Text(
                                          'Add your payment methods'.tr,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF212B36)),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 12..h,
                                      ),
                                      Center(
                                        child: Text(
                                          'This card will only be charged\nout of Cuba'
                                              .tr,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF454F5B),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      SizedBox(height: 20..h),
                                      Container(
                                        height: 50..h,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 2),
                                        decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: AppColors.black
                                                      .withValues(alpha: .25),
                                                  blurRadius: 2)
                                            ]),
                                        child: TextField(
                                          controller:
                                              transactionUserNameController,
                                          decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                              border: InputBorder.none,
                                              hintText: 'Card Holder Name'.tr),
                                          cursorColor: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color,
                                        ),
                                      ),
                                      SizedBox(height: 20..h),
                                      Container(
                                        height: 50..h,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 2),
                                        decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Theme.of(context)
                                                      .shadowColor
                                                      .withValues(alpha: .25),
                                                  blurRadius: 2)
                                            ]),
                                        child: Center(
                                          child: TextField(
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(
                                                  16),
                                            ],
                                            controller: cardNumberController,
                                            keyboardType: TextInputType.number,
                                            cursorColor: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        0, 0, 0, 0),
                                                border: InputBorder.none,
                                                prefixIcon: Image.asset(
                                                    'assets/icons/card1.png'),
                                                hintText:
                                                    '4343 4343 4343 4343'),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20..h),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              height: 50..h,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 2),
                                              decoration: BoxDecoration(
                                                  color: AppColors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: AppColors.black
                                                            .withValues(alpha: .25),
                                                        blurRadius: 2)
                                                  ]),
                                              child: Center(
                                                child: TextField(
                                                  inputFormatters: [
                                                    LengthLimitingTextInputFormatter(
                                                        2)
                                                  ],
                                                  controller:
                                                      expiryMonthController,
                                                  cursorColor: Colors.black,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  textAlignVertical:
                                                      TextAlignVertical.top,
                                                  decoration: InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 20,
                                                              vertical: 15),
                                                      border: InputBorder.none,
                                                      hintText: '02'.tr),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 20),
                                          Flexible(
                                            child: Container(
                                              height: 50..h,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 2),
                                              decoration: BoxDecoration(
                                                  color: AppColors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: AppColors.black
                                                            .withValues(alpha: .25),
                                                        blurRadius: 2)
                                                  ]),
                                              child: Center(
                                                child: TextField(
                                                  controller:
                                                      expiryYearController,
                                                  inputFormatters: [
                                                    LengthLimitingTextInputFormatter(
                                                        2)
                                                  ],
                                                  keyboardType:
                                                      TextInputType.number,
                                                  cursorColor: Colors.black,
                                                  textAlignVertical:
                                                      TextAlignVertical.top,
                                                  decoration: InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 20,
                                                              vertical: 15),
                                                      border: InputBorder.none,
                                                      hintText: '27'.tr),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20..h),
                                      Container(
                                        height: 50..h,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 2),
                                        decoration: BoxDecoration(
                                            color: AppColors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: AppColors.black
                                                      .withValues(alpha: .25),
                                                  blurRadius: 2)
                                            ]),
                                        child: Center(
                                          child: TextField(
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(
                                                  4)
                                            ],
                                            controller: cvc,
                                            keyboardType: TextInputType.number,
                                            cursorColor: Colors.black,
                                            textAlignVertical:
                                                TextAlignVertical.top,
                                            decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 15),
                                                border: InputBorder.none,
                                                hintText: 'CVC'),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20..h),
                                      Text(
                                        "Do you want to purchase a subscription for yourself?."
                                            .tr,
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      SizedBox(height: 5..h),
                                      Container(
                                        height: 50..h,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 2),
                                        decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Theme.of(context)
                                                      .shadowColor
                                                      .withValues(alpha: .25),
                                                  blurRadius: 2)
                                            ]),
                                        child: Center(
                                            child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20.w),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              isExpanded: true,
                                              value: cont.selectedValueYourself,
                                              onChanged: (newValue) {
                                                cont.selectedValueYourself =
                                                    newValue ?? "No";
                                                cont.update();
                                              },
                                              items: <String>[
                                                'Yes',
                                                'No'
                                              ].map<DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value.tr),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        )),
                                      ),
                                      SizedBox(height: 20..h),
                                      Text(
                                        "Generate promotional code for friends/family."
                                            .tr,
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      SizedBox(height: 5..h),
                                      Container(
                                        height: 50..h,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 2),
                                        decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Theme.of(context)
                                                      .shadowColor
                                                      .withValues(alpha: .25),
                                                  blurRadius: 2)
                                            ]),
                                        child: Center(
                                            child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20.w),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              isExpanded: true,
                                              value: cont.selectedValue,
                                              onChanged: (newValue) {
                                                cont.selectedValue =
                                                    newValue ?? "No";
                                                if (cont.selectedValue ==
                                                    "No") {
                                                  cont.subtotal = 0.0;
                                                } else {
                                                  cont.subtotal = 1.99 *
                                                      cont.numberOfPromoCodes;
                                                }
                                                cont.update();
                                              },
                                              items: <String>[
                                                'Yes',
                                                'No'
                                              ].map<DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value.tr),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        )),
                                      ),
                                      SizedBox(height: 10..h),
                                      Visibility(
                                        visible: cont.selectedValue == "Yes",
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 50..h,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 2),
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .cardColor,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Theme.of(context)
                                                            .shadowColor
                                                            .withValues(alpha: .25),
                                                        blurRadius: 2)
                                                  ]),
                                              child: Center(
                                                  child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20.w),
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child: DropdownButton<int>(
                                                    isExpanded: true,
                                                    value:
                                                        cont.numberOfPromoCodes,
                                                    onChanged: (newValue) {
                                                      cont.numberOfPromoCodes =
                                                          newValue ?? 1;
                                                      cont.subtotal = 1.99 *
                                                          cont.numberOfPromoCodes;
                                                      cont.update();
                                                    },
                                                    items: [1, 2, 3, 4, 5].map<
                                                        DropdownMenuItem<
                                                            int>>((int value) {
                                                      return DropdownMenuItem(
                                                        value: value,
                                                        child: Text(
                                                            value.toString()),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                              )),
                                            ),
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Visibility(
                                        visible: cont.selectedValue == "Yes",
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Purchasing promotional codes:"
                                                  .tr,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              "${cont.numberOfPromoCodes}",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Visibility(
                                        visible:
                                            cont.selectedValueYourself == "Yes",
                                        child: Text(
                                          "1x subscription for you, 1.99\$".tr,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      Visibility(
                                        visible: cont.selectedValue == "Yes",
                                        child: Text(
                                          "${cont.numberOfPromoCodes}x ${"subscription for friends/family".tr}, ${double.parse("${cont.subtotal}").toStringAsFixed(2)}\$"
                                              .tr,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Subtotal:".tr,
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            cont.selectedValueYourself == "Yes"
                                                ? "${cont.subtotal + 1.99}\$"
                                                : "${cont.subtotal}\$",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                        Visibility(
                          visible: widget.fromCuba,
                          child: Column(
                            children: [
                              SizedBox(height: 20..h),
                              Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 28,
                                        child: Checkbox(
                                            value: cont.isCheckedList[0],
                                            activeColor: Color(0xFF0254B8),
                                            onChanged: (value) {
                                              cont.isCheckedList[0] =
                                                  value ?? false;
                                              cont.update();
                                            }),
                                      ),
                                      SizedBox(
                                        width: 270.w,
                                        child: Text(
                                          "I sent money to the good account number: 9235-1299-7726-1358"
                                              .tr,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15..sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 28,
                                        child: Checkbox(
                                            value: cont.isCheckedList[1],
                                            activeColor: Color(0xFF0254B8),
                                            onChanged: (value) {
                                              cont.isCheckedList[1] =
                                                  value ?? false;
                                              cont.update();
                                            }),
                                      ),
                                      SizedBox(
                                        width: 270.w,
                                        child: Text(
                                          "I sent the good amount of money: 1 MLC"
                                              .tr,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15..sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 28,
                                        child: Checkbox(
                                            value: cont.isCheckedList[2],
                                            activeColor: Color(0xFF0254B8),
                                            onChanged: (value) {
                                              cont.isCheckedList[2] =
                                                  value ?? false;
                                              cont.update();
                                            }),
                                      ),
                                      SizedBox(
                                        width: 270.w,
                                        child: Text(
                                          "I entered the good transaction number of the transfer."
                                              .tr,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Visibility(
                                    visible: Platform.isAndroid,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 28,
                                          child: Checkbox(
                                              value: cont.isCheckedList[3],
                                              activeColor: Color(0xFF0254B8),
                                              onChanged: (value) {
                                                cont.isCheckedList[3] =
                                                    value ?? false;
                                                cont.update();
                                              }),
                                        ),
                                        SizedBox(
                                          width: 270.w,
                                          child: Text(
                                            "If I am an Android user, I entered the correct phone number during the transaction: 000-000-0000"
                                                .tr,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15..sp),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: Platform.isAndroid,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 28,
                                          child: Checkbox(
                                              value: cont.isCheckedList[4],
                                              activeColor: Color(0xFF0254B8),
                                              onChanged: (value) {
                                                cont.isCheckedList[4] =
                                                    value ?? false;
                                                cont.update();
                                              }),
                                        ),
                                        SizedBox(
                                          width: 270.w,
                                          child: Text(
                                            "As a proof, I recorded a video of my money transfer if VentaCuba doesn't receive my transaction number through SMS."
                                                .tr,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15..sp),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10..h),
                              Text(
                                "If you make a mistake, we won’t be able to refund you and your money will be likely lost."
                                    .tr,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16..sp),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10..h),
                        InkWell(
                          onTap: () {
                            if (Platform.isIOS) {
                              cont.isCheckedList[3] = true;
                            }
                            cont.isCheckedList.forEach((element) {
                              if (element == false) {
                                return;
                              }
                            });
                            widget.fromCuba == false
                                ? {
                                    cont.packageData?.id = 2,
                                  }
                                : null;
                            if (widget.fromCuba == false) {
                              cont.paymentTypeId = 2;
                              cont.update();
                            } else {
                              cont.paymentTypeId = 1;
                              cont.update();
                            }
                            if (widget.fromCuba &&
                                cont.transactionNumberController.text.length <
                                    13) {
                              errorAlertToast(
                                  "Please enter a correct transaction number."
                                      .tr);
                              return;
                            }
                            if (Platform.isIOS &&
                                widget.fromCuba &&
                                cont.isCheckedList[2] != true &&
                                cont.isCheckedList[0] != true &&
                                cont.isCheckedList[1] != true) {
                              errorAlertToast("Check all boxes.".tr);
                              return;
                            }

                            print(cont.isCheckedList[0]);
                            print(cont.isCheckedList[1]);
                            print(cont.isCheckedList[2]);
                            print(cont.isCheckedList[3]);

                            print(cont.isCheckedList[4]);
                            if (Platform.isAndroid &&
                                    widget.fromCuba &&
                                    cont.isCheckedList[4] != true ||
                                cont.isCheckedList[3] != true ||
                                cont.isCheckedList[2] != true ||
                                cont.isCheckedList[0] != true ||
                                cont.isCheckedList[1] != true) {
                              errorAlertToast("Check all boxes.".tr);
                              return;
                            }

                            if (widget.fromCuba && cont.videoPath == null) {
                              errorAlertToast("Please Enter video.".tr);
                              return;
                            }

                            if (!widget.fromCuba &&
                                cont.selectedValue == "No" &&
                                cont.selectedValueYourself == "No") {
                              errorAlertToast(
                                  "Please purchase a subscription for yourself or purchase promotional codes for family or friends."
                                      .tr);
                              return;
                            }

                            if (!widget.fromCuba &&
                                cardNumberController.text.isEmpty) {
                              errorAlertToast(
                                  "Please enter credit card number.".tr);
                              return;
                            }
                            if (!widget.fromCuba &&
                                expiryMonthController.text.isEmpty) {
                              errorAlertToast(
                                  "Please enter expiration month.".tr);
                              return;
                            }
                            if (!widget.fromCuba &&
                                expiryYearController.text.isEmpty) {
                              errorAlertToast(
                                  "Please enter expiration year.".tr);
                              return;
                            }
                            if (!widget.fromCuba && cvc.text.isEmpty) {
                              errorAlertToast("Please enter CVC.".tr);
                              return;
                            }

                            widget.fromCuba
                                ? {cont.type = "Other"}
                                : {cont.type = "Stripe"};
                            cont.userNameTr =
                                transactionUserNameController!.text;
                            cont.phoneNoTr = transactionPhoneController!.text;
                            cont.cardNumberController =
                                cardNumberController.text;
                            cont.expiryMonthController =
                                expiryMonthController.text;
                            cont.expiryYearController =
                                expiryYearController.text;
                            cont.cvc = cvc.text;
                            Get.log(cont.userNameTr.toString());
                            Get.log(cont.phoneNoTr.toString());
                            Get.log(cont.paymentTypeId.toString());
                            cont.buyPackage();
                          },
                          child: MyButton(
                            text: 'Pay Now'.tr,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
