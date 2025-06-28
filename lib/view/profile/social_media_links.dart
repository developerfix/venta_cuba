import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/util/my_button.dart';
import 'package:venta_cuba/view/constants/Colors.dart';
import 'package:flutter_svg/svg.dart';

class SocialMediaLinks extends StatefulWidget {
  const SocialMediaLinks({super.key});

  @override
  State<SocialMediaLinks> createState() => _SocialMediaLinksState();
}

class _SocialMediaLinksState extends State<SocialMediaLinks> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: AuthController(),
        builder: (cont) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: InkWell(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SafeArea(
                    child: Column(
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
                                size: 20,
                              ),
                            ),
                            Text(
                              'Social Media Links'.tr,
                              style: TextStyle(
                                  fontSize: 21..sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.black),
                            ),
                            Container(
                              height: 24..h,
                              width: 24..w,
                              color: Colors.transparent,
                            )
                          ],
                        ),
                        SizedBox(height: 20..h),
                        Text(
                          'Add your social media link - Buyers will be able to see it on your listing details page.'
                              .tr,
                          style: TextStyle(
                              fontSize: 16..sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.black),
                        ),
                        SizedBox(height: 20..h),
                        Container(
                          height: 50..h,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 24..h,
                                width: 24..w,
                                child: Image.asset('assets/images/insta.png'),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                height: 50..h,
                                width: MediaQuery.of(context).size.width * .78,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.black.withOpacity(.25),
                                        blurRadius: 4,
                                      )
                                    ],
                                    color: AppColors.white),
                                child: TextField(
                                  controller: cont.instagramLinkCont,
                                  textAlignVertical: TextAlignVertical.center,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 13),
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      // prefixIcon: Icon(Icons.mail_outline,
                                      //   color: Color(0xFFA9ABAC),
                                      // ),
                                      hintText: 'Instagram Link'.tr,
                                      hintStyle:
                                          TextStyle(color: Color(0xFFA9ABAC))),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 30..h,
                        ),
                        Container(
                          height: 50..h,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 24..h,
                                width: 24..w,
                                child: Image.asset('assets/images/fb.png'),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                height: 50..h,
                                width: MediaQuery.of(context).size.width * .78,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.black.withOpacity(.25),
                                        blurRadius: 4,
                                      )
                                    ],
                                    color: AppColors.white),
                                child: TextField(
                                  controller: cont.facebookLinkCont,
                                  textAlignVertical: TextAlignVertical.center,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 13),
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      // prefixIcon: Icon(Icons.mail_outline,
                                      //   color: Color(0xFFA9ABAC),
                                      // ),
                                      hintText: 'Facebook Link'.tr,
                                      hintStyle:
                                          TextStyle(color: Color(0xFFA9ABAC))),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 30..h,
                        ),
                        Container(
                          height: 50..h,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 24..h,
                                width: 24..w,
                                child: Image.asset('assets/images/tiktok.png'),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                height: 50..h,
                                width: MediaQuery.of(context).size.width * .78,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.black.withOpacity(.25),
                                        blurRadius: 4,
                                      )
                                    ],
                                    color: AppColors.white),
                                child: TextField(
                                  controller: cont.tiktokLinkCont,
                                  textAlignVertical: TextAlignVertical.center,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 13),
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      // prefixIcon: Icon(Icons.mail_outline,
                                      //   color: Color(0xFFA9ABAC),
                                      // ),
                                      hintText: 'Tiktok Link'.tr,
                                      hintStyle:
                                          TextStyle(color: Color(0xFFA9ABAC))),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 30..h,
                        ),
                        Container(
                          height: 50..h,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 24..h,
                                width: 24..w,
                                child: Image.asset(
                                  'assets/images/youtube.png',
                                  // color: Colors.blue,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                height: 50..h,
                                width: MediaQuery.of(context).size.width * .78,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.black.withOpacity(.25),
                                        blurRadius: 4,
                                      )
                                    ],
                                    color: AppColors.white),
                                child: TextField(
                                  controller: cont.youtubeLinkCont,
                                  textAlignVertical: TextAlignVertical.center,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 13),
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      // prefixIcon: Icon(Icons.mail_outline,
                                      //   color: Color(0xFFA9ABAC),
                                      // ),
                                      hintText: 'Youtube Link'.tr,
                                      hintStyle:
                                          TextStyle(color: Color(0xFFA9ABAC))),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 30..h,
                        ),
                        Container(
                          height: 50..h,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 24..h,
                                width: 24..w,
                                child: Image.asset('assets/images/pin.png'),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                height: 50..h,
                                width: MediaQuery.of(context).size.width * .78,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.black.withOpacity(.25),
                                        blurRadius: 4,
                                      )
                                    ],
                                    color: AppColors.white),
                                child: TextField(
                                  controller: cont.pinterestLinkCont,
                                  textAlignVertical: TextAlignVertical.center,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 13),
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      // prefixIcon: Icon(Icons.mail_outline,
                                      //   color: Color(0xFFA9ABAC),
                                      // ),
                                      hintText: 'Pinterest Link'.tr,
                                      hintStyle:
                                          TextStyle(color: Color(0xFFA9ABAC))),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 30..h,
                        ),
                        Container(
                          height: 50..h,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 24..h,
                                width: 24..w,
                                child: Image.asset('assets/images/x.png'),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                height: 50..h,
                                width: MediaQuery.of(context).size.width * .78,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.black.withOpacity(.25),
                                        blurRadius: 4,
                                      )
                                    ],
                                    color: AppColors.white),
                                child: TextField(
                                  controller: cont.twitterLinkCont,
                                  textAlignVertical: TextAlignVertical.center,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 13),
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      // prefixIcon: Icon(Icons.mail_outline,
                                      //   color: Color(0xFFA9ABAC),
                                      // ),
                                      hintText: 'X Link'.tr,
                                      hintStyle:
                                          TextStyle(color: Color(0xFFA9ABAC))),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 30..h,
                        ),
                        Container(
                          height: 50..h,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 24..h,
                                width: 24..w,
                                child: Image.asset('assets/images/linkd.png'),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                height: 50..h,
                                width: MediaQuery.of(context).size.width * .78,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.black.withOpacity(.25),
                                        blurRadius: 4,
                                      )
                                    ],
                                    color: AppColors.white),
                                child: TextField(
                                  controller: cont.linkedinLinkCont,
                                  textAlignVertical: TextAlignVertical.center,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 13),
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      // prefixIcon: Icon(Icons.mail_outline,
                                      //   color: Color(0xFFA9ABAC),
                                      // ),
                                      hintText: 'Linkedin Link'.tr,
                                      hintStyle:
                                          TextStyle(color: Color(0xFFA9ABAC))),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 30..h),
                        InkWell(
                            onTap: () {
                              cont.user?.businessName == ""
                                  ? cont.saveSocialMediaLink()
                                  : cont.isBusinessAccount
                                      ? cont.saveSocialMediaLinkBusiness()
                                      : cont.saveSocialMediaLink();
                            },
                            child: MyButton(text: 'Save Changes'.tr)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
