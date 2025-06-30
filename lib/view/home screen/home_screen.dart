// ignore_for_file: unused_import

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import 'package:venta_cuba/Utils/funcations.dart';
import 'package:venta_cuba/util/categories.dart';
import 'package:venta_cuba/view/Chat/custom_text.dart';
import 'package:venta_cuba/view/Navigation%20bar/search.dart';
import 'package:venta_cuba/view/category/select_category.dart';
import 'package:venta_cuba/view/constants/Colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:venta_cuba/view/frame/frame.dart';
import 'package:venta_cuba/view/home%20screen/widgets/post_view.dart';
import 'package:venta_cuba/view/widgets/scroll_to_top_button.dart';

import '../../Controllers/auth_controller.dart';
import '../../Share Preferences/Share Preferences.dart';
import '../Search_Places_Screen/searchAndCurrentLocationPage.dart';
import '../auth/login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final homeCont = Get.put(HomeController());
  final authCont = Get.put(AuthController());
  Future<void> getAdd() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      setState(() {
        homeCont.address = sharedPreferences.getString("saveAddress") ?? "";
        homeCont.radius =
            double.parse(sharedPreferences.getString("saveRadius") ?? "50.0");
      });
      if (homeCont.hasLocationOrRadiusChanged()) {
        homeCont.shouldFetchData.value = true;
        homeCont.listingModelList.clear();
        homeCont.currentPage.value = 1;
        homeCont.hasMore.value = true;
      }
    } catch (e) {
      Get.log("Error in getAdd: $e", isError: true);
      errorAlertToast('Failed to load saved address. Using default.'.tr);
    }
  }

  UserPreferences userPreferences = UserPreferences();
  Future<void> getSaveHistory() async {
    try {
      beforeData = await userPreferences.getSaveHistory();
    } catch (e) {
      Get.log("Error in getSaveHistory: $e", isError: true);
    }
  }

  @override
  void initState() {
    super.initState();
    try {
      if (Get.previousRoute == "/login" ||
          Get.previousRoute != "/SearchAndCurrentLocationPage") {
        homeCont.fetchAccountType();
        getAdd();
        getSaveHistory();
        homeCont.selectedCategory = null;
        homeCont.selectedSubCategory = null;
        homeCont.selectedSubSubCategory = null;
        if (homeCont.shouldFetchData.value ||
            homeCont.listingModelList.isEmpty) {
          homeCont.homeData();
        }
      } else {
        Get.log(
            'Coming from SearchAndCurrentLocationPage, checking for changes');
        homeCont.shouldFetchData.value = true;
        getAdd();
        if (homeCont.hasLocationOrRadiusChanged()) {
          homeCont.listingModelList.clear();
          homeCont.currentPage.value = 1;
          homeCont.hasMore.value = true;
          homeCont.homeData();
        }
      }
    } catch (e, stackTrace) {
      Get.log("Error in initState: $e\n$stackTrace", isError: true);
      homeCont.loadingHome.value = false;
      errorAlertToast('Failed to initialize home screen. Please try again.'.tr);
    }
  }

  bool isListView = false;

  void toggleView(bool listView) {
    setState(() {
      isListView = listView;
    });
  }

  bool isLoading = false;
  int? selectedIndex;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GetBuilder<HomeController>(
        init: homeCont,
        builder: (cont) {
          return Stack(
            children: [
              // cont.loadingHome.value
              //     ? Center(child: CircularProgressIndicator())
              // :
              RefreshIndicator(
                onRefresh: () async {
                  homeCont.shouldFetchData.value = true;
                  homeCont.selectedCategory = null;
                  homeCont.selectedSubCategory = null;
                  homeCont.selectedSubSubCategory = null;
                  homeCont.listingModelList.clear();
                  homeCont.currentPage.value = 1;
                  homeCont.hasMore.value = true;
                  await homeCont.getListing();
                },
                child: SingleChildScrollView(
                  controller: cont.scrollsController,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 50,
                                height: 40,
                              ),
                              Container(
                                height: 40,
                                width: 80,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        cont.getFavouriteItems();
                                        toggleView(false);
                                      },
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          // color: isListView ? Colors.transparent : AppColors.k0xFF0254B8,
                                        ),
                                        child: Center(
                                            child: SvgPicture.asset(
                                                'assets/icons/heartadd.svg',
                                                color: Theme.of(context)
                                                    .iconTheme
                                                    .color)),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        toggleView(true);
                                        cont.getAllNotifications();
                                      },
                                      child: Container(
                                        width: 35,
                                        height: 35,
                                        child: Stack(
                                          children: [
                                            Align(
                                              alignment: Alignment.center,
                                              child: Container(
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                child: Center(
                                                    child: SvgPicture.asset(
                                                        'assets/icons/notification.svg',
                                                        color: Theme.of(context)
                                                            .iconTheme
                                                            .color)),
                                              ),
                                            ),
                                            Obx(() => cont
                                                    .hasUnreadNotifications
                                                    .value
                                                ? Positioned(
                                                    right: 5,
                                                    top: 5,
                                                    child: Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: BoxDecoration(
                                                          color: Colors.red,
                                                          shape:
                                                              BoxShape.circle),
                                                    ),
                                                  )
                                                : SizedBox.shrink()),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 30..h,
                          ),
                          Text(
                            'Welcome Back'.tr,
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: 20..h,
                          ),
                          Container(
                            height: 54..h,
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: InkWell(
                                    onTap: () {
                                      cont.listingModelSearchList =
                                          cont.listingModelList;
                                      cont.selectedCategory = null;
                                      cont.selectedSubCategory = null;
                                      cont.selectedSubSubCategory = null;

                                      Get.to(const Search())?.then((value) {
                                        getAdd();
                                        cont.currentPage.value = 1;
                                        cont.hasMore.value = true;
                                        cont.listingModelList.clear();
                                        cont.getListing();
                                      });
                                    },
                                    child: Container(
                                      height: 54..h,
                                      decoration: BoxDecoration(
                                        color: AppColors.k0xFFF0F1F1,
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(width: 8),
                                          Icon(Icons.search_rounded,
                                              color: Color(0xFFA9ABAC)),
                                          SizedBox(width: 8),
                                          CustomText(
                                            text:
                                                'What are you looking for?'.tr,
                                            fontColor: Color(0xFFA9ABAC),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20..h,
                          ),
                          InkWell(
                            onTap: () {
                              Get.to(SearchAndCurrentLocationPage())?.then((_) {
                                setState(() {
                                  getAdd();
                                  if (cont.hasLocationOrRadiusChanged()) {
                                    cont.shouldFetchData.value = true;
                                    cont.listingModelList.clear();
                                    cont.currentPage.value = 1;
                                    cont.hasMore.value = true;
                                    cont.homeData();
                                  }
                                });
                              });
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SvgPicture.asset('assets/icons/location.svg',
                                    color: Theme.of(context).iconTheme.color),
                                SizedBox(
                                  width: 5..w,
                                ),
                                SizedBox(
                                  width: 290.w,
                                  // height: 20.h,
                                  child: cont.address == ''
                                      ? Text(
                                          'Click here to enter a location to see publications near you.'
                                              .tr,
                                          // overflow: TextOverflow.clip,
                                          style: TextStyle(
                                              fontSize: 14..sp,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.k0xFF403C3C),
                                        )
                                      : Text(
                                          cont.address != ''
                                              ? "${cont.address} ${"within the".tr} ${cont.radius.toInt()} km"
                                              : '${cont.address}',

                                          // overflow: TextOverflow.clip,
                                          style: TextStyle(
                                              fontSize: 17..sp,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.k0xFF403C3C),
                                        ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 25..h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SelectionArea(
                                child: Text(
                                  'Category'.tr,
                                  style: TextStyle(
                                      fontSize: 16..sp,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.color),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  cont.selectedCategory = null;
                                  cont.selectedSubCategory = null;
                                  cont.selectedSubSubCategory = null;
                                  Get.to(const SelectCategories())
                                      ?.then((value) {
                                    cont.currentPage.value = 1;
                                    cont.hasMore.value = true;
                                    cont.listingModelList.clear();
                                    cont.getListing();
                                  });
                                },
                                child: Text(
                                  'View all'.tr,
                                  style: TextStyle(
                                      fontSize: 15..sp,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20..h,
                          ),
                          Container(
                            height: 62..h,
                            width: MediaQuery.of(context).size.width,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  cont.categoriesModel?.data?.length ?? 0,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: InkWell(
                                    onTap: () {
                                      cont.selectedCategory =
                                          cont.categoriesModel?.data?[index];
                                      cont.isNavigate = true;
                                      cont.getSubCategories();
                                    },
                                    child: Categories(
                                        imagePath: cont.categoriesModel
                                                ?.data?[index].icon ??
                                            "",
                                        text:
                                            "${cont.categoriesModel?.data?[index].name}"),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: 35..h,
                          ),
                          ListingView()
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Scroll to top button
              ScrollToTopButton(
                scrollController: cont.scrollsController,
              ),
            ],
          );
        },
      ),
    );
  }
}
