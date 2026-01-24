// ignore_for_file: unused_import

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import 'package:venta_cuba/Controllers/homepage_controller.dart';
import 'package:venta_cuba/Utils/funcations.dart';
import 'package:venta_cuba/util/categories.dart';
import 'package:venta_cuba/view/Chat/custom_text.dart';
import 'package:venta_cuba/view/Navigation%20bar/search.dart';
import 'package:venta_cuba/view/category/select_category.dart';
import 'package:venta_cuba/view/constants/Colors.dart';
import 'package:venta_cuba/view/constants/premium_animations.dart';
import 'package:venta_cuba/view/constants/premium_loading.dart';
import 'package:venta_cuba/view/constants/premium_components.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:venta_cuba/view/frame/frame.dart';
import 'package:venta_cuba/view/home%20screen/widgets/post_view.dart';
import 'package:venta_cuba/view/widgets/scroll_to_top_button.dart';

import '../../Controllers/auth_controller.dart';
import '../../Share Preferences/Share Preferences.dart';
import '../../cities_list/cites_list.dart';
import '../widgets/location_dialog.dart';
import '../auth/login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Use separate HomepageController for homepage-specific state
  // CRITICAL: permanent=true prevents disposal during Get.offAll() navigation
  final homepageCont = Get.put(HomepageController(), permanent: true);
  // Keep HomeController for categories and other shared functionality
  final homeCont = Get.put(HomeController());
  final authCont = Get.put(AuthController());

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
    _initializeAsync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  // Non-blocking initialization
  void _initializeAsync() async {
    try {
      // Heavy operations in background
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _loadDataInBackground();
      });
    } catch (e, stackTrace) {
      Get.log("Error in initState: $e\n$stackTrace", isError: true);
      print('Failed to initialize home screen. Please try again.'.tr);
    }
  }

  // Background data loading - uses HomepageController for listings (SEPARATE from search/category)
  Future<void> _loadDataInBackground() async {
    try {
      await getSaveHistory();

      // Load saved location from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedAddress = prefs.getString("saveAddress");
      bool isAllProvinces = prefs.getBool("isAllProvinces") ?? true;

      Get.log(
          "🏠 HomeScreen: Loading data - savedAddress: $savedAddress, isAllProvinces: $isAllProvinces");

      // If no saved address, set default to "All provinces"
      if (savedAddress == null || savedAddress.isEmpty) {
        savedAddress = "All provinces";
        await prefs.setString("saveAddress", savedAddress);
        await prefs.setString("saveLat", "23.1136");
        await prefs.setString("saveLng", "-82.3666");
        await prefs.setString("saveRadius", "1000.0");
        await prefs.setBool("isAllProvinces", true);
        await prefs.setBool("isAllCities", false);
        await prefs.setStringList("selectedProvinceNames", []);
        await prefs.setStringList("selectedCityNames", []);
        Get.log("🏠 HomeScreen: No saved address, set defaults");
      }

      // Update HomeController with saved address for UI display only
      homeCont.address = savedAddress;
      homeCont.lat = prefs.getString("saveLat") ?? "23.1136";
      homeCont.lng = prefs.getString("saveLng") ?? "-82.3666";
      homeCont.radius = double.parse(prefs.getString("saveRadius") ?? "1000.0");
      homeCont.update();

      Get.log(
          "🏠 HomeScreen: Updated homeCont.address to: ${homeCont.address}");

      // Ensure scroll listener is attached after UI is ready
      homepageCont.ensureScrollListenerAttached();

      // Load categories using HomeController
      await homeCont.getCategories();

      // Load listings using HomepageController (SEPARATE from search/category)
      // Always load if list is empty OR initial load hasn't completed
      if (homepageCont.homepageListings.isEmpty ||
          !homepageCont.hasInitialLoadCompleted.value) {
        Get.log(
            '🏠 HomeScreen: Loading via HomepageController - isEmpty: ${homepageCont.homepageListings.isEmpty}, hasInitialLoadCompleted: ${homepageCont.hasInitialLoadCompleted.value}');
        await homepageCont.loadHomepageData(forceRefresh: true);
      } else {
        Get.log(
            '🏠 HomeScreen: Data already loaded, count: ${homepageCont.homepageListings.length}');
      } // Load categories with retry
      await _loadCategoriesWithRetry();

      // Load listings using HomepageController
      if (homepageCont.homepageListings.isEmpty ||
          !homepageCont.hasInitialLoadCompleted.value) {
        await homepageCont.loadHomepageData(forceRefresh: true);
      }
    } catch (e) {
      Get.log("Error loading background data: $e", isError: true);
    }
  }

// Add retry logic for categories
  Future<void> _loadCategoriesWithRetry() async {
    int retries = 3;
    while (retries > 0) {
      await homeCont.getCategories();

      // Check if categories loaded successfully
      if (homeCont.categoriesModel?.data != null &&
          homeCont.categoriesModel!.data!.isNotEmpty) {
        Get.log("✅ Categories loaded successfully");
        return;
      }

      retries--;
      if (retries > 0) {
        Get.log("⚠️ Categories empty, retrying... ($retries attempts left)");
        await Future.delayed(Duration(seconds: 1));
      }
    }

    Get.log("❌ Failed to load categories after 3 attempts");
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
                  // Refresh homepage using HomepageController (SEPARATE from search/category)
                  homepageCont.homepageListings.clear();
                  homepageCont.currentPage.value = 1;
                  homepageCont.hasMore.value = true;
                  await homepageCont.loadHomepageData(forceRefresh: true);
                },
                child: SingleChildScrollView(
                  controller: homepageCont.scrollController,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 40,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                PremiumComponents.premiumCard(
                                  onTap: () {
                                    cont.getFavouriteItems();
                                    toggleView(false);
                                  },
                                  padding: EdgeInsets.all(8.w),
                                  margin: EdgeInsets.zero,
                                  borderRadius: BorderRadius.circular(20.r),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    child: Center(
                                        child: SvgPicture.asset(
                                            'assets/icons/heartadd.svg',
                                            colorFilter: ColorFilter.mode(
                                              Theme.of(context)
                                                      .iconTheme
                                                      .color ??
                                                  Colors.grey,
                                              BlendMode.srcIn,
                                            ))),
                                  ),
                                ),
                                // Notification icon removed
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 30.h,
                          ),
                          PremiumAnimations.staggeredListItem(
                            index: 0,
                            child: Text(
                              'Welcome Back'.tr,
                              style: TextStyle(
                                  fontSize: 25.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.color),
                            ),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          Container(
                            height: 54.h,
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: InkWell(
                                    onTap: () {
                                      // Clear categories before going to search
                                      cont.selectedCategory = null;
                                      cont.selectedSubCategory = null;
                                      cont.selectedSubSubCategory = null;

                                      Navigator.push(
                                        context,
                                        PremiumPageTransitions.slideFromRight(
                                            const Search()),
                                      ).then((value) {
                                        // Clear category selections...
                                        cont.selectedCategory = null;
                                        cont.selectedSubCategory = null;
                                        cont.selectedSubSubCategory = null;

                                        // Re-attach listener immediately
                                        homepageCont
                                            .ensureScrollListenerAttached();

                                        // OPTIONAL: Add a small delay to double-ensure attachment if UI is heavy
                                        Future.delayed(
                                            Duration(milliseconds: 200), () {
                                          homepageCont
                                              .ensureScrollListenerAttached();
                                        });

                                        cont.update();
                                      });
                                    },
                                    child: Container(
                                      height: 54.h,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Color(0xFF2C2C2C)
                                            : AppColors.k0xFFF0F1F1,
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(width: 8),
                                          Icon(Icons.search_rounded,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white70
                                                  : Color(0xFFA9ABAC)),
                                          SizedBox(width: 8),
                                          CustomText(
                                            text:
                                                'What are you looking for?'.tr,
                                            fontColor:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white70
                                                    : Color(0xFFA9ABAC),
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
                            height: 20.h,
                          ),
                          InkWell(
                            onTap: () async {
                              // Load previously selected provinces and cities
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();

                              // Get saved province and city names
                              List<String> savedProvinceNames = prefs
                                      .getStringList("selectedProvinceNames") ??
                                  [];
                              List<String> savedCityNames =
                                  prefs.getStringList("selectedCityNames") ??
                                      [];
                              bool savedIsAllProvinces =
                                  prefs.getBool("isAllProvinces") ?? true;
                              bool savedIsAllCities =
                                  prefs.getBool("isAllCities") ?? false;

                              // Convert saved names back to objects
                              List<CustomProvinceNameList> initialProvinces =
                                  provinceName
                                      .where((p) => savedProvinceNames
                                          .contains(p.provinceName))
                                      .toList();

                              List<CustomCitiesList> initialCities = citiesList
                                  .where((c) =>
                                      savedCityNames.contains(c.cityName))
                                  .toList();

                              // Show location dialog
                              final result =
                                  await showDialog<Map<String, dynamic>>(
                                context: context,
                                builder: (context) => LocationDialog(
                                  initialProvinces: initialProvinces,
                                  initialCities: initialCities,
                                  isAllProvinces: savedIsAllProvinces,
                                  isAllCities: savedIsAllCities,
                                ),
                              );

                              // Handle result
                              if (result != null) {
                                final provinces = result['provinces']
                                    as List<CustomProvinceNameList>;
                                final cities =
                                    result['cities'] as List<CustomCitiesList>;
                                final isAllProvinces =
                                    result['isAllProvinces'] as bool;
                                final isAllCities =
                                    result['isAllCities'] as bool;

                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                String newAddress = "";

                                // Generate address string based on selection
                                if (isAllProvinces) {
                                  newAddress =
                                      "All provinces"; // Store English key, translate when displaying
                                  await prefs.setString(
                                      "saveAddress", newAddress);
                                  await prefs.setString(
                                      "saveLat", "23.1136"); // Center of Cuba
                                  await prefs.setString("saveLng", "-82.3666");
                                  // Use larger radius to cover all of Cuba (Cuba is ~1250km long)
                                  // Using 1000km to ensure full coverage from east to west
                                  await prefs.setString("saveRadius", "1000.0");
                                } else if (provinces.isNotEmpty) {
                                  // Provinces are selected
                                  if (provinces.length == 1) {
                                    // Single province
                                    if (cities.isEmpty) {
                                      // Single province, no specific cities (all municipalities)
                                      newAddress =
                                          "${provinces[0].provinceName}";
                                      // Get first city from this province for coordinates
                                      final provinceCities = citiesList
                                          .where((city) =>
                                              city.provinceName ==
                                              provinces[0].provinceName)
                                          .toList();
                                      if (provinceCities.isNotEmpty) {
                                        await prefs.setString("saveLat",
                                            provinceCities[0].latitude.trim());
                                        await prefs.setString("saveLng",
                                            provinceCities[0].longitude.trim());
                                      } else {
                                        await prefs.setString(
                                            "saveLat", "23.1136");
                                        await prefs.setString(
                                            "saveLng", "-82.3666");
                                      }
                                    } else if (cities.length == 1) {
                                      // Single province, single city
                                      newAddress =
                                          "${provinces[0].provinceName}, ${cities[0].cityName}";
                                      await prefs.setString(
                                          "saveLat", cities[0].latitude.trim());
                                      await prefs.setString("saveLng",
                                          cities[0].longitude.trim());
                                    } else {
                                      // Single province, multiple cities
                                      newAddress =
                                          "${provinces[0].provinceName} - ${cities.length} ${"municipalities".tr}";
                                      await prefs.setString(
                                          "saveLat", cities[0].latitude.trim());
                                      await prefs.setString("saveLng",
                                          cities[0].longitude.trim());
                                    }
                                  } else {
                                    // Multiple provinces
                                    if (cities.isEmpty) {
                                      // Multiple provinces, no specific cities
                                      newAddress =
                                          "${provinces.length} ${"provinces".tr}";
                                    } else {
                                      // Multiple provinces and cities
                                      newAddress =
                                          "${provinces.length} ${"provinces".tr} - ${cities.length} ${"municipalities".tr}";
                                    }
                                    // Use Cuba center for multiple provinces with larger radius
                                    // Cuba is ~1250km long, so we need at least 700km radius to cover all
                                    await prefs.setString("saveLat", "23.1136");
                                    await prefs.setString(
                                        "saveLng", "-82.3666");
                                  }
                                  await prefs.setString(
                                      "saveAddress", newAddress);
                                  // Use larger radius for multiple provinces to cover all of Cuba
                                  await prefs.setString(
                                      "saveRadius",
                                      provinces.length > 1
                                          ? "1000.0"
                                          : "500.0");
                                }

                                // Save selected province and city names for persistence
                                List<String> provinceNames = provinces
                                    .map((p) => p.provinceName)
                                    .toList();
                                List<String> cityNames =
                                    cities.map((c) => c.cityName).toList();
                                await prefs.setStringList(
                                    "selectedProvinceNames", provinceNames);
                                await prefs.setStringList(
                                    "selectedCityNames", cityNames);
                                await prefs.setBool(
                                    "isAllProvinces", isAllProvinces);
                                await prefs.setBool("isAllCities", isAllCities);

                                // Load the saved lat/lng values back into controller
                                String savedLat =
                                    prefs.getString("saveLat") ?? "23.1136";
                                String savedLng =
                                    prefs.getString("saveLng") ?? "-82.3666";
                                double savedRadius = double.parse(
                                    prefs.getString("saveRadius") ?? "500.0");

                                setState(() {
                                  // Update HomeController address for UI display
                                  cont.address = newAddress;
                                  cont.lat = savedLat;
                                  cont.lng = savedLng;
                                  cont.radius = savedRadius;
                                });

                                // Update HomepageController and reload data (SEPARATE from search/category)
                                homepageCont.address = newAddress;
                                homepageCont.lat = savedLat;
                                homepageCont.lng = savedLng;
                                homepageCont.radius = savedRadius;
                                homepageCont.homepageListings.clear();
                                homepageCont.currentPage.value = 1;
                                homepageCont.hasMore.value = true;
                                homepageCont.hasInitialLoadCompleted.value =
                                    false;
                                await homepageCont.loadHomepageData(
                                    forceRefresh: true);
                              }
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 14.h),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Color(0xFF2C2C2C)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8.w),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white.withValues(alpha: 0.1)
                                          : Color(0xFF0254B8)
                                              .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: SvgPicture.asset(
                                      'assets/icons/location.svg',
                                      width: 20.w,
                                      height: 20.h,
                                      colorFilter: ColorFilter.mode(
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Color(0xFF0254B8),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: cont.address == ''
                                        ? Text(
                                            'Choose a location'.tr,
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white70
                                                  : AppColors.k0xFF403C3C,
                                            ),
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Selected Location'.tr,
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? Colors.white54
                                                      : Colors.grey.shade600,
                                                ),
                                              ),
                                              SizedBox(height: 4.h),
                                              Text(
                                                cont.address == "All provinces"
                                                    ? "All provinces".tr
                                                    : "${cont.address}",
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : AppColors.k0xFF403C3C,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16.sp,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Color(0xFF0254B8),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 25.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SelectionArea(
                                child: Text(
                                  'Category'.tr,
                                  style: TextStyle(
                                      fontSize: 16.sp,
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
                                  Navigator.push(
                                    context,
                                    PremiumPageTransitions.slideFromRight(
                                        const SelectCategories()),
                                  ).then((value) {
                                    // Clear category selections when returning
                                    cont.selectedCategory = null;
                                    cont.selectedSubCategory = null;
                                    cont.selectedSubSubCategory = null;

                                    // Re-attach listener immediately
                                    homepageCont.ensureScrollListenerAttached();
                                    
                                    // Add delayed retry to ensure attachment
                                    Future.delayed(
                                        Duration(milliseconds: 200), () {
                                      homepageCont.ensureScrollListenerAttached();
                                    });
                                    
                                    cont.update();
                                  });
                                },
                                child: Text(
                                  'View all'.tr,
                                  style: TextStyle(
                                      fontSize: 15.sp,
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
                            height: 20.h,
                          ),
                          categoriesList(cont, context),
                          SizedBox(
                            height: 35.h,
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
                scrollController: homepageCont.scrollController,
              ),
            ],
          );
        },
      ),
    );
  }

  Obx categoriesList(HomeController cont, BuildContext context) {
    return Obx(() {
      if (homeCont.loadingCategories.value) {
        return Container(
          height: 62.h,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (homeCont.categoriesLoadFailed.value) {
        return Container(
          height: 62.h,
          child: Center(
            child: TextButton.icon(
              onPressed: () => homeCont.getCategories(),
              icon: Icon(Icons.refresh),
              label: Text('Retry'.tr),
            ),
          ),
        );
      }

      if (cont.categoriesModel?.data?.isEmpty ?? true) {
        return Container(
          height: 62.h,
          child: Center(
            child: Text('No categories available'.tr),
          ),
        );
      }

      return Container(
        height: 62.h,
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: cont.categoriesModel?.data?.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.only(right: 15),
              child: InkWell(
                onTap: () {
                  cont.selectedCategory = cont.categoriesModel?.data?[index];
                  cont.isNavigate = true;
                  cont.getSubCategories();
                },
                child: Categories(
                    imagePath: cont.categoriesModel?.data?[index].icon ?? "",
                    text: "${cont.categoriesModel?.data?[index].name}"),
              ),
            );
          },
        ),
      );
    });
  }
}
