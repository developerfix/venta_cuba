import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import 'package:venta_cuba/Controllers/homepage_controller.dart';
import 'package:venta_cuba/Controllers/theme_controller.dart';
import 'package:venta_cuba/util/profile_list.dart';
import 'package:venta_cuba/view/Chat/Controller/SupabaseChatController.dart';
import 'package:venta_cuba/view/auth/vendor_screen.dart';
import 'package:venta_cuba/view/constants/Colors.dart';
import 'package:flutter_svg/svg.dart';
import 'package:venta_cuba/view/constants/premium_animations.dart';

import 'package:venta_cuba/view/profile/manage_account.dart';
import 'package:venta_cuba/view/profile/notification_preferences.dart';
import 'package:venta_cuba/view/profile/personal_details.dart';
import 'package:venta_cuba/view/profile/social_media_links.dart';
import '../../util/my_button.dart';
import '../change_language/change_language_screen.dart';
import '../privacy_policy/privacy_policy_screen.dart';
import '../profile/DefaultLocation.dart';
import '../terms_of_use/terms_of_use_screen.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final homeCont = Get.put(HomeController());
  final homePageCont = Get.put(HomepageController());
  final themeController = Get.put(ThemeController());

  List<Widget> _buildStarRating(double rating) {
    List<Widget> stars = [];
    for (int i = 0; i < 5; i++) {
      stars.add(
        Icon(Icons.star,
            color: i < rating ? AppColors.k0xFFF9E005 : AppColors.k1xFFF9E005),
      );
    }
    return stars;
  }

  final authCont = Get.put(AuthController());

  void imagePickerOption() {
    Get.bottomSheet(
      SingleChildScrollView(
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: Container(
            color: Theme.of(context).dialogTheme.backgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pick Image From'.tr,
                    style: TextStyle(
                        fontSize: 22..h,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleLarge?.color),
                  ),
                  SizedBox(
                    height: 40..h,
                  ),
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          pickImage(ImageSource.camera);
                          Get.back();
                        });
                      },
                      child: MyButton(text: 'Camera'.tr)),
                  SizedBox(
                    height: 20..h,
                  ),
                  GestureDetector(
                      onTap: () {
                        pickImage(ImageSource.gallery);
                        Get.back();
                      },
                      child: MyButton(text: 'Gallery'.tr)),
                  SizedBox(
                    height: 20..h,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      height: 60..h,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: AppColors.k0xFFA9ABAC,
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                        child: Text(
                          'Cancel'.tr,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
        content: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.close_rounded,
            size: 15,
            color: AppColors.k0xFF9F9F9F,
          ),
        ),
        SizedBox(height: 10..h),
        Text(
          authCont.user?.businessName == ""
              ? 'Want to Switch to Business Account'.tr
              : authCont.isBusinessAccount
                  ? 'Want to Switch to Personal Account'.tr
                  : 'Want to Switch to Business Account'.tr,
          style: TextStyle(
              fontSize: 18..sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 15..h),
        Text(
          'Your account is switch to other one'.tr,
          style: TextStyle(
              fontSize: 14..sp,
              fontWeight: FontWeight.w400,
              color: AppColors.k0xFF9F9F9F),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30..h),
        Container(
          height: 40..h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  height: 40..h,
                  width: MediaQuery.of(context).size.width * .3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.k0xFF0254B8,
                  ),
                  child: Center(
                    child: Text(
                      'Cancel'.tr,
                      style: TextStyle(
                          fontSize: 14..sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  if (authCont.user?.businessName == "") {
                    Navigator.of(context).pop();
                    Get.to(VendorScreen());
                  } else {
                    // Close dialog first
                    Navigator.of(context).pop();

                    // Show loading

                    homeCont.loadingHome.value = true;
                    homeCont.update();

                    // Switch account type locally
                    authCont.isBusinessAccount = !authCont.isBusinessAccount;
                    authCont.update();

                    // Update on server
                    await authCont.changeAccountType();
                    await homeCont.fetchAccountType();

                    final chatController = Get.find<SupabaseChatController>();

                    // Agar user ID null nahi hai to nayi stream init karein
                    if (authCont.user?.userId != null) {
                      chatController.getAllChats(
                          authCont.user!.userId.toString(),
                          authCont.isBusinessAccount // Naya status
                          );
                    }

                    // Switch to homepage tab
                    authCont.currentIndexBottomAppBar = 0;
                    authCont.update();
                    // FORCE complete reset of all data
                    homeCont.listingModelList.clear();
                    homeCont.listingModelSearchList.clear();
                    homeCont.currentPage.value = 1;
                    homeCont.hasMore.value = true;
                    homeCont.shouldShuffleOnLocationChange = false;

                    // FORCE location change to trigger reload
                    homeCont.lastLat = null;
                    homeCont.lastLng = null;
                    homeCont.lastRadius = null;

                    // Clear categories to show all items
                    homeCont.selectedCategory = null;
                    homeCont.selectedSubCategory = null;
                    homeCont.selectedSubSubCategory = null;

                    // Ensure scroll listeners are attached
                    homeCont.ensureScrollListenerAttached();

                    try {
                      await homePageCont.forceRefresh();
                      // Get categories first
                      await homeCont.getCategories();

                      // Then load listings directly
                      await homeCont.getListing(isLoadMore: false);

                      // Refresh favorite sellers list for the new account type
                      await homeCont.refreshFavouriteSellerList();

                      // Save location
                      homeCont.saveLocationAndRadius();

                      Get.log(
                          "✅ Account switched successfully - Homepage reloaded");
                    } catch (e) {
                      Get.log("❌ Error during account switch reload: $e");
                      print(
                          'Failed to reload data. Please refresh manually.'.tr);
                    } finally {
                      homeCont.loadingHome.value = false;
                      homeCont.update();
                    }
                  }
                },
                child: Container(
                  height: 40..h,
                  width: MediaQuery.of(context).size.width * .3,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.k0xFF0254B8)),
                  child: Center(
                    child: Text(
                      'Yes Switch'.tr,
                      style: TextStyle(
                          fontSize: 14..sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.k0xFF0254B8),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    ));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: alert);
      },
    );
  }

  pickImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return;
    final imageTemp = File(image.path);
    authCont.profileImage = imageTemp.path;
    authCont.firstNameCont.text = authCont.user?.firstName ?? "";
    authCont.lastNameCont.text = authCont.user?.lastName ?? "";
    authCont.isBusinessAccount
        ? authCont.updateBusinessImage()
        : authCont.editProfile(false);
    authCont.update();
  }

  @override
  void initState() {
    authCont.fetchAccountType();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GetBuilder(
        init: AuthController(),
        builder: (cont) {
          return SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10..h,
                    ),
                    Stack(
                      children: [
                        Container(
                          height: 90..h,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CachedNetworkImage(
                                    height: 85..h,
                                    width: 85..w,
                                    imageUrl: cont.isBusinessAccount
                                        ? '${cont.user?.businessLogo}'
                                        : '${cont.user?.profileImage}',
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      height: 85..h,
                                      width: 85..w,
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                          shape: BoxShape.circle),
                                    ),
                                    placeholder: (context, url) => SizedBox(
                                        height: 85..h,
                                        width: 85..w,
                                        child: Center(
                                            child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ))),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      height: 85..h,
                                      width: 85..w,
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  "assets/images/notImage.jpg")),
                                          shape: BoxShape.circle),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20..w,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 10..h,
                                      ),
                                      GetBuilder<AuthController>(
                                          builder: (cont) {
                                        return SelectionArea(
                                          child: Text(
                                            cont.user?.businessName == ""
                                                ? '${cont.user?.firstName} ${cont.user?.lastName}'
                                                    .tr
                                                : cont.isBusinessAccount
                                                    ? '${cont.user?.businessName}'
                                                    : '${cont.user?.firstName} ${cont.user?.lastName}',
                                            style: TextStyle(
                                                fontSize: 16..sp,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.k0xFF0254B8),
                                          ),
                                        );
                                      }),
                                      SizedBox(
                                        height: 3..h,
                                      ),
                                      GetBuilder<AuthController>(
                                        builder: (cont) {
                                          return SelectionArea(
                                            child: Text(
                                              cont.user?.businessName == ""
                                                  ? 'Personal Account'.tr
                                                  : cont.isBusinessAccount
                                                      ? 'Business Account'.tr
                                                      : 'Personal Account'.tr,
                                              style: TextStyle(
                                                  fontSize: 16..sp,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      AppColors.textSecondary),
                                            ),
                                          );
                                        },
                                      ),
                                      SizedBox(
                                        height: 7..h,
                                      ),
                                      Row(
                                        children: [
                                          Row(
                                            children: _buildStarRating(
                                                double.parse(cont
                                                        .user?.averageRating
                                                        .toString() ??
                                                    "0")),
                                          ),
                                          SizedBox(
                                            width: 8..w,
                                          ),
                                          SelectionArea(
                                            child: Text(cont.user?.averageRating
                                                    .toString() ??
                                                "0"),
                                          ),
                                          SizedBox(width: 3),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  _showAlertDialog(context);
                                },
                                child: Container(
                                    height: 30..h,
                                    width: 30..w,
                                    child: SvgPicture.asset(
                                      'assets/icons/reload.svg',
                                      colorFilter: ColorFilter.mode(
                                        Theme.of(context).iconTheme.color ??
                                            Colors.grey,
                                        BlendMode.srcIn,
                                      ),
                                    )),
                              )
                            ],
                          ),
                        ),
                        Positioned(
                          top: 55..h,
                          left: 55..w,
                          child: InkWell(
                            onTap: () {
                              imagePickerOption();
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              height: 35..h,
                              width: 35..w,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).cardColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .shadowColor
                                          .withValues(alpha: .05),
                                      blurRadius: 10,
                                    )
                                  ]),
                              child: SvgPicture.asset('assets/icons/edit.svg'),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 45..h,
                    ),
                    SelectionArea(
                      child: Text(
                        'Quick Link'.tr,
                        style: TextStyle(
                            fontSize: 15..sp,
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).textTheme.titleMedium?.color),
                      ),
                    ),
                    SizedBox(
                      height: 25..h,
                    ),
                    GestureDetector(
                      onTap: () {
                        // if (authCont.user?.businessName == "") {
                        //   Get.snackbar(
                        //       "Warning", "User must be a business owner");
                        // } else {
                        homeCont.sellerId = authCont.user?.userId.toString();
                        homeCont.getSellerDetails(
                            authCont.isBusinessAccount ? "1" : "0", 0, true);
                        // }
                      },
                      child: Container(
                        height: 60..h,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .shadowColor
                                    .withValues(alpha: .4),
                                blurRadius: 5,
                              )
                            ],
                            color: Theme.of(context).cardColor),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 20..h,
                              width: 20..w,
                              child: SvgPicture.asset(
                                'assets/icons/person.svg',
                                colorFilter: ColorFilter.mode(
                                  Theme.of(context).iconTheme.color ??
                                      Colors.grey,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5..w,
                            ),
                            Text(
                              'My Public Page'.tr,
                              style: TextStyle(
                                  fontSize: 15..sp,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.color),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15..h,
                    ),
                    GestureDetector(
                        onTap: () {
                          homeCont.getFavouriteSeller();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          height: 60..h,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .shadowColor
                                      .withValues(alpha: .4),
                                  blurRadius: 5,
                                )
                              ],
                              color: Theme.of(context).cardColor),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 25..h,
                                width: 25..w,
                                child: Image.asset(
                                  'assets/icons/thumbs-up.png',
                                  color: Theme.of(context).iconTheme.color,
                                ),
                              ),
                              SizedBox(width: 7..w),
                              Padding(
                                padding: const EdgeInsets.only(top: 3.0),
                                child: Text(
                                  'Favorite Sellers'.tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15..sp,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.color),
                                ),
                              ),
                            ],
                          ),
                        )),
                    SizedBox(
                      height: 15..h,
                    ),
                    GestureDetector(
                        onTap: () {
                          homeCont.getFavouriteItems();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          height: 60..h,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .shadowColor
                                      .withValues(alpha: .4),
                                  blurRadius: 5,
                                )
                              ],
                              color: Theme.of(context).cardColor),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 25..h,
                                width: 25..w,
                                child: SvgPicture.asset(
                                  'assets/icons/heartSimple.svg',
                                  colorFilter: ColorFilter.mode(
                                    Theme.of(context).iconTheme.color ??
                                        Colors.grey,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              SizedBox(width: 7..w),
                              Padding(
                                padding: const EdgeInsets.only(top: 3.0),
                                child: Text(
                                  'Favorite Listings'.tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15..sp,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.color),
                                ),
                              ),
                            ],
                          ),
                        )),

                    SizedBox(height: 15..h),
                    Text(
                      'Profile Details'.tr,
                      style: TextStyle(
                          fontSize: 15..sp,
                          fontWeight: FontWeight.w500,
                          color:
                              Theme.of(context).textTheme.titleMedium?.color),
                    ),
                    SizedBox(
                      height: 25..h,
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              PremiumPageTransitions.slideFromRight(
                                const PersonalDetails(),
                              ));
                        },
                        child: ProfileList(text: 'Personal Details'.tr)),

                    SizedBox(
                      height: 15..h,
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              PremiumPageTransitions.slideFromRight(
                                const DefaultLocation(),
                              ));
                        },
                        child: ProfileList(text: 'Default Location'.tr)),
                    SizedBox(
                      height: 15..h,
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              PremiumPageTransitions.slideFromRight(
                                const SocialMediaLinks(),
                              ));
                        },
                        child: ProfileList(text: 'Social Media Links'.tr)),
                    SizedBox(
                      height: 15..h,
                    ),
                    GestureDetector(
                        onTap: null,
                        // onTap: () {
                        //   homeCont.promoCodesAndPackage();
                        // },
                        child: ProfileList(text: 'Promotional Codes'.tr)),
                    SizedBox(
                      height: 35..h,
                    ),
                    Text(
                      'Account Settings'.tr,
                      style: TextStyle(
                          fontSize: 15..sp,
                          fontWeight: FontWeight.w500,
                          color:
                              Theme.of(context).textTheme.titleMedium?.color),
                    ),
                    SizedBox(
                      height: 25..h,
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              PremiumPageTransitions.slideFromRight(
                                const ManageAccount(),
                              ));
                        },
                        child: ProfileList(text: 'Manage Account'.tr)),
                    SizedBox(
                      height: 15..h,
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              PremiumPageTransitions.slideFromRight(
                                const NotificationPreferences(),
                              ));
                        },
                        child:
                            ProfileList(text: 'Notifications Preferences'.tr)),
                    SizedBox(
                      height: 15..h,
                    ),
                    // Dark Mode Toggle
                    Obx(() => Container(
                          height: 60..h,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15..w),
                            child: Row(
                              children: [
                                Icon(
                                  themeController.isDarkMode.value
                                      ? Icons.dark_mode
                                      : Icons.light_mode,
                                  color: Theme.of(context).iconTheme.color,
                                  size: 20..sp,
                                ),
                                SizedBox(width: 15..w),
                                Expanded(
                                  child: Text(
                                    'Dark Mode'.tr,
                                    style: TextStyle(
                                      fontSize: 15..sp,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                    ),
                                  ),
                                ),
                                Obx(() => Switch(
                                      value: themeController.isDarkMode.value,
                                      onChanged: (value) {
                                        themeController.toggleTheme();
                                      },
                                      activeColor: AppColors.k0xFF0254B8,
                                      inactiveThumbColor: Theme.of(context)
                                          .unselectedWidgetColor,
                                      inactiveTrackColor: Theme.of(context)
                                          .unselectedWidgetColor
                                          .withValues(alpha: 0.3),
                                    )),
                              ],
                            ),
                          ),
                        )),
                    SizedBox(
                      height: 35..h,
                    ),
                    SelectionArea(
                      child: Text(
                        'General Information'.tr,
                        style: TextStyle(
                            fontSize: 15..sp,
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).textTheme.titleMedium?.color),
                      ),
                    ),
                    SizedBox(
                      height: 25..h,
                    ),
                    InkWell(
                      onTap: () => Get.to(ChangeLanguageScreen()),
                      child: ProfileList2(text: 'Change Language'.tr),
                    ),
                    SizedBox(
                      height: 15..h,
                    ),
                    GestureDetector(
                        onTap: () => Get.to(TermsOfUse()),
                        child: ProfileList2(text: 'Terms Of Use'.tr)),
                    SizedBox(
                      height: 15..h,
                    ),
                    GestureDetector(
                        onTap: () => Get.to(PrivacyPolicy()),
                        child: ProfileList2(text: 'Privacy Policy'.tr)),
                    SizedBox(
                      height: 15..h,
                    ),
                    // ProfileList(text: 'Help'.tr),
                    // SizedBox(
                    //   height: 15..h,
                    // ),
                    // GestureDetector(
                    //     onTap: () {
                    //       homeCont.getAllPackages();
                    //     },
                    //     child: ProfileList(text: 'Subscription'.tr)),
                    // SizedBox(
                    //   height: 15..h,
                    // ),
                    // GestureDetector(
                    //     onTap: () {
                    //       Navigator.push(
                    //           context,
                    //           PremiumPageTransitions.slideFromRight(
                    //             builder: (context) => const VendorScreen(),
                    //           ));
                    //     },
                    //     child: ProfileList(text:authCont.user?.businessName == ""?'Convert to Personal Account'.tr: 'Become a Vendor'.tr)),
                    SizedBox(
                      height: 35..h,
                    ),
                    InkWell(
                      onTap: () {
                        cont.logout();
                      },
                      child: Container(
                        height: 60..h,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                color: AppColors.k0xFF0254B8, width: 2)),
                        child: Center(
                          child: Text(
                            'Log Out'.tr,
                            style: TextStyle(
                                fontSize: 17..sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.k0xFF0254B8),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
