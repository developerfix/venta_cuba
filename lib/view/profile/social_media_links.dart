import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/Controllers/theme_controller.dart';
import 'package:venta_cuba/util/my_button.dart';

class SocialMediaLinks extends StatefulWidget {
  const SocialMediaLinks({super.key});

  @override
  State<SocialMediaLinks> createState() => _SocialMediaLinksState();
}

class _SocialMediaLinksState extends State<SocialMediaLinks> {
  final themeController = Get.put(ThemeController());
  Widget _buildSocialMediaField({
    required String iconPath,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Row(
      children: [
        Container(
          height: 24.h,
          width: 24.w,
          child: Image.asset(iconPath),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Container(
            height: 50.h,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
              // borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.25),
                  blurRadius: 4,
                )
              ],
              color: themeController.isDarkMode.value
                  ? Colors.black
                  : Colors.white,
            ),
            child: TextField(
              controller: controller,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: Theme.of(context).textTheme.bodyLarge?.color,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: true,
                fillColor: themeController.isDarkMode.value
                    ? Colors.black
                    : Colors.white,
                hintText: hintText.tr,
                hintStyle: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

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
                              color: Theme.of(context).iconTheme.color,
                            ),
                          ),
                          Text(
                            'Social Media Links'.tr,
                            style: TextStyle(
                              fontSize: 21.sp,
                              fontWeight: FontWeight.w500,
                              color:
                                  Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                          Container(
                            height: 24.h,
                            width: 24.w,
                            color: Colors.transparent,
                          )
                        ],
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Add your social media link - Buyers will be able to see it on your listing details page.'
                            .tr,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _buildSocialMediaField(
                        iconPath: 'assets/images/insta.png',
                        controller: cont.instagramLinkCont,
                        hintText: 'Instagram Link',
                      ),
                      SizedBox(height: 30.h),
                      _buildSocialMediaField(
                        iconPath: 'assets/images/fb.png',
                        controller: cont.facebookLinkCont,
                        hintText: 'Facebook Link',
                      ),
                      SizedBox(height: 30.h),
                      _buildSocialMediaField(
                        iconPath: 'assets/images/tiktok.png',
                        controller: cont.tiktokLinkCont,
                        hintText: 'Tiktok Link',
                      ),
                      SizedBox(height: 30.h),
                      _buildSocialMediaField(
                        iconPath: 'assets/images/youtube.png',
                        controller: cont.youtubeLinkCont,
                        hintText: 'Youtube Link',
                      ),
                      SizedBox(height: 30.h),
                      _buildSocialMediaField(
                        iconPath: 'assets/images/pinterest.png',
                        controller: cont.pinterestLinkCont,
                        hintText: 'Pinterest Link',
                      ),
                      SizedBox(height: 30.h),
                      _buildSocialMediaField(
                        iconPath: 'assets/images/x.png',
                        controller: cont.twitterLinkCont,
                        hintText: 'X Link',
                      ),
                      SizedBox(height: 30.h),
                      _buildSocialMediaField(
                        iconPath: 'assets/images/linkd.png',
                        controller: cont.linkedinLinkCont,
                        hintText: 'Linkedin Link',
                      ),
                      SizedBox(height: 30.h),
                      InkWell(
                        onTap: () {
                          cont.user?.businessName == ""
                              ? cont.saveSocialMediaLink()
                              : cont.isBusinessAccount
                                  ? cont.saveSocialMediaLinkBusiness()
                                  : cont.saveSocialMediaLink();
                        },
                        child: MyButton(text: 'Save Changes'.tr),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
