import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart' as geo;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/Controllers/location_controller.dart';

import 'package:venta_cuba/Models/AllPromoCodesModel.dart';
import 'package:venta_cuba/Models/CheckUserPackageModle.dart';
import 'package:venta_cuba/Models/ListingModel.dart';
import 'package:venta_cuba/main.dart';
import 'package:venta_cuba/util/my_button.dart';
import 'package:venta_cuba/view/Chat/custom_text.dart';
import 'package:venta_cuba/view/Navigation%20bar/navigation_bar.dart';
import 'package:venta_cuba/view/Navigation%20bar/post.dart';
import 'package:venta_cuba/view/Navigation%20bar/subCategory.dart';
import 'package:venta_cuba/view/frame/frame.dart';
import 'package:venta_cuba/view/payment/VideoPalyScreen.dart';

import '../Models/AllPackagesModel.dart';
import '../Models/CategoriesModel.dart';
import '../Models/CategoriesModel.dart' as ctg;
import '../Models/FavouriteSellerModel.dart';
import '../Models/SelectedCategoryModel.dart';
import '../Models/SellerDetailsModel.dart';
import '../Models/SubCategoriesModel.dart';
import '../Models/SubCategoriesModel.dart' as sub;
import '../Models/SubSubCategoriesModel.dart';
import '../Models/SubSubCategoriesModel.dart' as subSub;
import '../Utils/funcations.dart';
import '../Utils/image_upload_helper.dart';
import '../api/api_client.dart';
import '../view/PromoCodesScreen/PromoCodesScreen.dart';
import '../view/category/SubSubCategories.dart';
import '../view/category/category_from.dart';

import '../view/profile/favourite_listings.dart';
import '../view/profile/favourite_seller.dart';
import '../view/profile/my_public_page.dart';
import '../view/subscription/Subscription.dart';
import '../view/constants/premium_animations.dart';

List<String> beforeData = [];

//Your package is in pending, waiting for admin approval.
class HomeController extends GetxController {
  HomeController() {
    Get.log("🎯 HOME CONTROLLER CONSTRUCTOR CALLED - NEW VERSION!");
  }

  TextEditingController? priceCont = TextEditingController();
  TextEditingController addressCont = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController titleCont = TextEditingController();
  TextEditingController descriptionCont = TextEditingController();
  RxList<UploadingImage> uploadingImages = <UploadingImage>[].obs;
  Rx<bool> isLoadingImages = false.obs;
  bool isLoading = false;
  int isSelectedReport = 0;
  double subtotal = 0.0;
  TextEditingController makeController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  TextEditingController conditionController = TextEditingController();
  TextEditingController fulfillmentController = TextEditingController();
  TextEditingController paymentController = TextEditingController();
  TextEditingController youTubeController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController minPriceController = TextEditingController();
  TextEditingController maxPriceController = TextEditingController();
  TextEditingController transactionNumberController = TextEditingController();
  TextEditingController reviewController = TextEditingController();

  int paymentTypeId = 1;

  // TextfieldTagsController tagsController = TextfieldTagsController();
  TextEditingController tagsController = TextEditingController();
  List<String> tags = [];
  PackageData? packageData;
  // Removed geocoding - using API calls instead
  String? packageImage;
  String selectedType = "Oldest First";
  double? userRatting = 3.0;
  final authCont = Get.put(AuthController());
  List<bool> isCheckedList = [false, false, false, false, false];
  ApiClient api = ApiClient(appBaseUrl: baseUrl);
  CategoriesModel? categoriesModel;
  SubCategoriesModel? subCategoriesModel;
  SubSubCategoriesModel? subSubCategoriesModel;
  double radius = 50.0;
  RxBool loadingHome = true.obs;
  String? selectedCurrency = 'CUP'; // Default currency
  RxBool isPostLoading = false.obs;
  RxBool loadingCategory = false.obs;
  RxBool loadingSubCategory = false.obs;
  RxBool loadingSubSubCategory = false.obs;
  RxBool isEditingListing = false.obs;

  // Randomization control
  RxBool hasShuffledThisSession = false.obs;
  bool shouldShuffleOnLocationChange = false;
  SelectedCategoryModel? selectedCategoryModel;
  ctg.Data? selectedCategory;
  sub.Data? selectedSubCategory;
  subSub.Data? selectedSubSubCategory;
  List<ListingModel> userFavouriteListingModelList = [];
  List<ListingModel> userListingModelList = [];
  List<ListingModel> listingModelList = [];
  List<ListingModel> listingModelSearchList = [];
  ListingModel? listingModel;
  String furnished = '';
  String jobType = '';
  String? searchLatitude;
  String? searchLongitude;
  String? status = 'active';
  String? soldStatus;
  String? listingId;
  String? sellerId;
  int isListing = 1;
  bool listingLoading = true;
  FavouriteSellerModel favouriteSellerModel = FavouriteSellerModel();
  AllPackagesModel? allPackagesModel;
  SellerDetailsModel? sellerDetailsModel;
  String? lat = "23.124792615936276";
  String? lng = '-82.38597269330762';
  String? lat1;
  String? lng1;
  String? address = "4JF7+RM6, Av. Paseo, La Habana, Cuba";
  String? userNameTr;
  String? phoneNoTr;
  String? cardNumberController;
  String? expiryMonthController;
  String? expiryYearController;
  String? cvc;
  String type = "Other";
  List<String> postImages = [];
  int isType = 0;
  String c = '';
  bool isNavigate = false;
  bool isSearchScreen = false;
  List<int> showBelowFields = [0, 0, 0, 0, 0, 0];
  Map<String, dynamic> optionalInformation = {};
  // int isSelect = -1;
  // int isSelect1 = -1;
  // int isSelect2 = -1;
  ScrollController scrollsController = ScrollController();
  ScrollController searchScrollController = ScrollController();
  RxBool isFetching = false.obs; // Prevent concurrent fetches
  RxInt currentPage = 1.obs;
  RxBool hasMore = true.obs;
  RxBool isScrollListenerActive = true.obs;

  // Add variables to track last used location and radius
  String? lastLat;
  String? lastLng;
  double? lastRadius;
  RxBool shouldFetchData =
      false.obs; // Flag to determine if data should be fetched

  // Define separate pagination variables for search
  var currentSearchPage = 1.obs;
  var hasMoreSearch = true.obs;
  var isSearchLoading = false.obs;

  // Method to shuffle listings for new login sessions only
  Future<void> shuffleListingsOnLogin() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String currentSessionId = prefs.getString('current_session_id') ?? '';

      // Generate new session id if none exists or if it's a fresh login
      if (currentSessionId.isEmpty || !hasShuffledThisSession.value) {
        String newSessionId = DateTime.now().millisecondsSinceEpoch.toString();
        await prefs.setString('current_session_id', newSessionId);

        if (listingModelList.isNotEmpty) {
          listingModelList.shuffle();
          hasShuffledThisSession.value = true;
          update();
          Get.log("📝 Listings shuffled for new session: $newSessionId");
        }
      } else {
        Get.log("📝 Shuffle skipped - same session or list is empty");
      }
    } catch (e) {
      Get.log("📝 Error in shuffleListingsOnLogin: $e");
    }
  }

  // Method to shuffle listings when location changes
  void shuffleListingsOnLocationChange() {
    if (listingModelList.isNotEmpty) {
      listingModelList.shuffle();
      update();
      Get.log("📝 Listings shuffled due to location change");
    } else {
      Get.log("📝 Location shuffle skipped - list is empty");
    }
  }

  // Method to force shuffle after location change - called directly from UI
  void forceShuffleAfterLocationChange() {
    shouldShuffleOnLocationChange = true;
  }

  // Method to reset shuffle flag and session (called on logout/app restart)
  Future<void> resetShuffleSession() async {
    try {
      hasShuffledThisSession.value = false;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_session_id');
      Get.log("📝 Shuffle session reset for next login");
    } catch (e) {
      Get.log("📝 Error resetting shuffle session: $e");
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchAccountType();

    // Attach scroll listener for infinite scroll
    scrollsController.addListener(onScroll);
    searchScrollController.addListener(onScrollSearch);
    Get.log("📜 Scroll listeners attached in onInit");

    // Reset shuffle session on app start (fresh app launch)
    // This ensures shuffling happens when app is reopened
    resetShuffleSession().then((_) {
      Get.log("📝 Shuffle session reset on app initialization");
    });
  }

  @override
  void onClose() {
    scrollsController.removeListener(onScroll);
    searchScrollController.removeListener(onScrollSearch);
    scrollsController.dispose();
    searchScrollController.dispose();
    super.onClose();
  }

  void resetScrollController() {
    scrollsController.removeListener(onScroll);
    scrollsController.dispose();
    scrollsController = ScrollController();
    scrollsController.addListener(onScroll);
    Get.log("📜 Scroll controller reset and listener attached");
  }

  void ensureScrollListenerAttached() {
    try {
      // Remove existing listeners if present to avoid duplicates
      scrollsController.removeListener(onScroll);
      searchScrollController.removeListener(onScrollSearch);
    } catch (e) {
      // Listeners weren't attached, that's fine
    }

    // Add the listeners
    scrollsController.addListener(onScroll);
    searchScrollController.addListener(onScrollSearch);
    Get.log("📜 Scroll listeners ensured to be attached");
  }

  // Test method to manually trigger scroll
  void testScrollEvent() {
    Get.log("📜 MANUAL SCROLL TEST");
    if (scrollsController.hasClients) {
      Get.log(
          "📜 TEST: pixels=${scrollsController.position.pixels}, maxExtent=${scrollsController.position.maxScrollExtent}");
      onScroll();
    } else {
      Get.log("📜 TEST: No clients attached");
    }
  }

  // DEBUG: Test method to load many items without pagination
  Future<void> testLoadManyItems() async {
    Get.log("🧪 DEBUG: Loading many items without pagination");
    isPostLoading.value = true;
    update();

    try {
      await getCoordinatesFromAddress();
      listingModelList.clear();

      // Load multiple pages at once for testing
      for (int page = 1; page <= 5; page++) {
        Get.log("🧪 DEBUG: Loading page $page");

        Response response = await api.postData(
          "api/getListing?page=$page",
          {
            'user_id': authCont.user?.userId ?? "",
            'category_id': selectedCategory?.id ?? "",
            'sub_category_id': selectedSubCategory?.id ?? "",
            'sub_sub_category_id': selectedSubSubCategory?.id ?? "",
            'latitude': lat ?? "",
            'longitude': lng ?? "",
            'radius': radius.toString(),
            'address': address ?? "",
          },
          headers: {
            'Accept': 'application/json',
            'Access-Control-Allow-Origin': "*",
            'Authorization': 'Bearer ${authCont.user?.accessToken}'
          },
        ).timeout(Duration(seconds: 30));

        if (response.statusCode == 200) {
          List<dynamic> dataListing = response.body['data']['data'] ?? [];
          Get.log("🧪 DEBUG: Page $page returned ${dataListing.length} items");

          if (dataListing.isNotEmpty) {
            for (var element in dataListing) {
              try {
                if (element != null && element is Map<String, dynamic>) {
                  listingModelList.add(ListingModel.fromJson(element));
                }
              } catch (e) {
                Get.log("🧪 DEBUG: Error parsing item: $e");
              }
            }
          } else {
            Get.log("🧪 DEBUG: Page $page returned empty data, stopping");
            break;
          }
        } else {
          Get.log(
              "🧪 DEBUG: Page $page failed with status ${response.statusCode}");
          break;
        }
      }

      Get.log("🧪 DEBUG: Total items loaded: ${listingModelList.length}");
      listingModelList.shuffle();
    } catch (e) {
      Get.log("🧪 DEBUG: Error in testLoadManyItems: $e");
    } finally {
      isPostLoading.value = false;
      update();
    }
  }

  // Load initial pages to ensure enough content for scrolling
  Future<void> _loadInitialPages() async {
    try {
      await getCoordinatesFromAddress();
      listingModelList.clear();
      currentPage.value = 1;
      hasMore.value = true;

      // Load enough pages to ensure scrollability (at least 10 items)
      for (int i = 0; i < 15 && hasMore.value; i++) {
        await _loadSinglePage();
        if (listingModelList.length >= 20)
          break; // Stop if we have enough items
      }

      // Apply initial shuffle
      if (shouldShuffleOnLocationChange) {
        shuffleListingsOnLocationChange();
        shouldShuffleOnLocationChange = false;
      } else {
        await shuffleListingsOnLogin();
      }
    } catch (e) {
      Get.log("🔄 DEBUG: Error in _loadInitialPages: $e");
    } finally {
      isPostLoading.value = false;
      isFetching.value = false;
      update();
    }
  }

  // Load a single page (helper method)
  Future<void> _loadSinglePage() async {
    Get.log(
        "🔄 DEBUG: _loadSinglePage called! Loading single page ${currentPage.value}");

    // Check if no location is selected
    bool noLocationSelected = false;
    if (address == null ||
        address == '' ||
        address == "4JF7+RM6, Av. Paseo, La Habana, Cuba" ||
        (lat == "23.124792615936276" &&
            lng == "-82.38597269330762" &&
            radius == 50.0)) {
      noLocationSelected = true;
      Get.log(
          "📍 _loadSinglePage: No location selected - loading user's own posts via dedicated API");
    }

    late Response response;

    if (noLocationSelected) {
      // When no location selected, call API specifically for user's own posts
      Map<String, dynamic> requestData = {
        'user_id': authCont.user?.userId ?? "",
        'category_id': selectedCategory?.id ?? "",
        'sub_category_id': selectedSubCategory?.id ?? "",
        'sub_sub_category_id': selectedSubSubCategory?.id ?? "",
        'latitude': "",
        'longitude': "",
        'radius': "",
        'min_price': '',
        'max_price': '',
        'search_by_title': '',
      };

      response = await api
          .postData(
            "api/getListing?page=${currentPage.value}",
            requestData,
            headers: {
              'Accept': 'application/json',
              'Access-Control-Allow-Origin': "*",
              'Authorization':
                  'Bearer ${authCont.user?.accessToken ?? tokenMain ?? ""}'
            },
            showdialog: false,
          )
          .timeout(Duration(seconds: 30));
    } else {
      // Normal location-based API call
      Map<String, dynamic> requestData = {
        'user_id': authCont.user?.userId ?? "",
        'category_id': selectedCategory?.id ?? "",
        'sub_category_id': selectedSubCategory?.id ?? "",
        'sub_sub_category_id': selectedSubSubCategory?.id ?? "",
        'latitude': lat ?? "23.124792615936276",
        'longitude': lng ?? "-82.38597269330762",
        'radius': radius.toString(),
        'min_price': '',
        'max_price': '',
        'search_by_title': ''
      };

      response = await api
          .postData(
            "api/getListing?page=${currentPage.value}",
            requestData,
            headers: {
              'Accept': 'application/json',
              'Access-Control-Allow-Origin': "*",
              'Authorization':
                  'Bearer ${authCont.user?.accessToken ?? tokenMain ?? ""}'
            },
            showdialog: false,
          )
          .timeout(Duration(seconds: 30));
    }

    if (response.statusCode == 200) {
      List<dynamic> dataListing = response.body['data']['data'] ?? [];
      Get.log(
          "🔄 DEBUG: Page ${currentPage.value} returned ${dataListing.length} items");

      if (dataListing.isNotEmpty) {
        List<ListingModel> newListings = [];

        // Parse items with error handling
        for (var element in dataListing) {
          try {
            if (element != null && element is Map<String, dynamic>) {
              newListings.add(ListingModel.fromJson(element));
            }
          } catch (e) {
            Get.log("🔄 DEBUG: Error parsing item: $e");
          }
        }

        // Apply user filtering when no location is selected
        if (noLocationSelected) {
          String currentUserId = authCont.user?.userId ?? "";
          newListings = newListings.where((listing) {
            return listing.userId == currentUserId;
          }).toList();
          Get.log(
              "After user filtering (_loadSinglePage no location): ${newListings.length} items");
        }

        // Apply business/personal account filtering
        String currentAccountType = authCont.isBusinessAccount ? "1" : "0";
        newListings = newListings.where((listing) {
          return listing.businessStatus == currentAccountType;
        }).toList();

        // Add filtered items to the main list
        listingModelList.addAll(newListings);
        currentPage.value++;
      } else {
        hasMore.value = false;
      }
    } else {
      Get.log("🔄 DEBUG: API call failed with status ${response.statusCode}");
      hasMore.value = false;
    }
  }

  Future<void> homeData() async {
    try {
      await loadLastLocationAndRadius();
      bool locationChanged = hasLocationOrRadiusChanged();

      if (locationChanged || listingModelList.isEmpty) {
        // Set flag to shuffle on location change
        if (locationChanged) {
          shouldShuffleOnLocationChange = true;
        }
        loadingHome = true.obs;
        // Ensure scroll listeners are attached (avoid duplicates)
        ensureScrollListenerAttached();
        currentPage.value = 1;
        hasMore.value = true;
        await getCategories();
        Get.log("🏠 homeData: About to call getListing()");
        await getListing();
        Get.log("🏠 homeData: getListing() completed");
        // Load favorite sellers list silently to ensure it's available for checking
        await _loadFavoriteSellersSilently();
        saveLocationAndRadius();
      }
    } catch (e, stackTrace) {
      Get.log("Error in homeData: $e\n$stackTrace", isError: true);
      print('Failed to load data. Please try again.'.tr);
    } finally {
      loadingHome = false.obs;
      update();
    }
  }

  void onScroll() {
    if (isFetching.value || !scrollsController.hasClients) return;
    if (scrollsController.position.pixels >=
        scrollsController.position.maxScrollExtent - 100) {
      if (!isPostLoading.value && hasMore.value) {
        Get.log("onScroll: Triggering getListing, page=${currentPage.value}");
        getListing(isLoadMore: true);
      }
    }
  }

  Future<void> getListing({bool isLoadMore = false}) async {
    Get.log("🚀 NEW getListing method called! isLoadMore: $isLoadMore");
    if (isPostLoading.value) return;
    isPostLoading.value = true;
    update();

    try {
      await getCoordinatesFromAddress();
      if (!isLoadMore) {
        currentPage.value = 1;
        listingModelList.clear();
        hasMore.value = true;
      }

      if (!hasMore.value) {
        isPostLoading.value = false;
        update();
        return;
      }

      Get.log("🔄 NEW getListing: Fetching Page: ${currentPage.value}");

      // Check if no location is selected (NEW CODE LOGIC)
      bool noLocationSelected = false;
      if (address == null ||
          address == '' ||
          address == "4JF7+RM6, Av. Paseo, La Habana, Cuba" ||
          (lat == "23.124792615936276" &&
              lng == "-82.38597269330762" &&
              radius == 50.0)) {
        noLocationSelected = true;
        Get.log(
            "📍 No location selected - will filter to user's own posts only");
      }

      // API CALL - Different logic based on location selection
      Map<String, dynamic> requestData = {
        'user_id': authCont.user?.userId ?? "",
        'category_id': selectedCategory?.id ?? "",
        'sub_category_id': selectedSubCategory?.id ?? "",
        'sub_sub_category_id': selectedSubSubCategory?.id ?? "",
        'latitude': noLocationSelected ? "" : (lat ?? "23.124792615936276"),
        'longitude': noLocationSelected ? "" : (lng ?? "-82.38597269330762"),
        'radius': noLocationSelected ? "" : radius.toString(),
        'min_price': '',
        'max_price': '',
        'search_by_title': ''
      };

      Response response = await api.postData(
        "api/getListing?page=${currentPage.value}",
        requestData,
        headers: {
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': "*",
          'Authorization':
              'Bearer ${authCont.user?.accessToken ?? tokenMain ?? ""}'
        },
        showdialog: false,
      );

      if (response.statusCode == 200) {
        List<dynamic> dataListing = response.body['data']['data'] ?? [];
        Get.log("HOME POST COUNT ${dataListing.length}");

        if (dataListing.isNotEmpty) {
          List<ListingModel> newListings =
              dataListing.map((e) => ListingModel.fromJson(e)).toList();

          // Apply client-side category filtering for consistency with search
          newListings = applyCategoryFilter(newListings);
          Get.log("After category filtering: ${newListings.length} items");

          // Apply user filtering when no location is selected (NEW CODE LOGIC)
          if (noLocationSelected) {
            String currentUserId = authCont.user?.userId ?? "";
            Get.log("🔍 DEBUGGING: Current user ID: '${currentUserId}'");
            Get.log(
                "🔍 DEBUGGING: Total listings before user filter: ${newListings.length}");

            // Debug: Show user IDs of all listings
            for (int i = 0; i < newListings.length && i < 5; i++) {
              Get.log(
                  "🔍 DEBUGGING: Listing ${i + 1} user_id: '${newListings[i].userId}', title: '${newListings[i].title}'");
            }

            newListings = newListings.where((listing) {
              bool matches = listing.userId == currentUserId;
              if (!matches) {
                Get.log(
                    "🔍 DEBUGGING: Filtered out listing '${listing.title}' (user_id: '${listing.userId}' != '${currentUserId}')");
              }
              return matches;
            }).toList();
            Get.log(
                "After user filtering (no location): ${newListings.length} items");
          }

          // Apply business/personal account filtering (was missing!)
          String currentAccountType = authCont.isBusinessAccount ? "1" : "0";
          Get.log(
              "🔍 DEBUGGING: Account type filter - isBusinessAccount: ${authCont.isBusinessAccount}, looking for businessStatus: '${currentAccountType}'");

          for (int i = 0; i < newListings.length && i < 5; i++) {
            Get.log(
                "🔍 DEBUGGING: Listing ${i + 1} businessStatus: '${newListings[i].businessStatus}', title: '${newListings[i].title}'");
          }

          newListings = newListings.where((listing) {
            bool matches = listing.businessStatus == currentAccountType;
            if (!matches) {
              Get.log(
                  "🔍 DEBUGGING: Filtered out listing '${listing.title}' (businessStatus: '${listing.businessStatus}' != '${currentAccountType}')");
            }
            return matches;
          }).toList();
          Get.log(
              "After business/personal filtering (${authCont.isBusinessAccount ? 'Business' : 'Personal'}): ${newListings.length} items");

          // Apply duplicate filtering to prevent duplicate items when loading more pages
          Set<String> existingIds = <String>{};
          for (var listing in listingModelList) {
            String id = listing.id?.toString() ?? '';
            if (id.isNotEmpty) {
              existingIds.add(id);
            }
          }

          // Filter out duplicates
          List<ListingModel> uniqueNewListings = [];
          for (var listing in newListings) {
            String id = listing.id?.toString() ?? '';
            if (id.isNotEmpty && !existingIds.contains(id)) {
              uniqueNewListings.add(listing);
            }
          }
          Get.log(
              "After duplicate filtering (home): ${uniqueNewListings.length} items (removed ${newListings.length - uniqueNewListings.length} duplicates)");

          listingModelList.addAll(uniqueNewListings);

          // Shuffle listings on first load
          if (currentPage.value == 1) {
            if (shouldShuffleOnLocationChange) {
              // Always shuffle when location changes
              shuffleListingsOnLocationChange();
              shouldShuffleOnLocationChange = false; // Reset flag
            } else {
              // Regular login-based shuffle
              await shuffleListingsOnLogin();
            }
          }

          currentPage.value++;
          hasMore.value =
              dataListing.length == 15; // Simple pagination logic from old code
        } else {
          hasMore.value = false;
        }
        saveLocationAndRadius();
      } else {
        Get.log("API error: ${response.statusCode}, ${response.body}",
            isError: true);
        print('Failed to fetch listings. Please try again.'.tr);
      }
    } catch (e, stackTrace) {
      Get.log("Error in getListing: $e\n$stackTrace", isError: true);
      print('Something went wrong. Please try again.'.tr);
    } finally {
      isPostLoading.value = false;
      update();
    }
  }

// Check if location or radius has changed
  bool hasLocationOrRadiusChanged() {
    return lat != lastLat || lng != lastLng || radius != lastRadius;
  }

  // Save current location and radius to cache
  void saveLocationAndRadius() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastLat', lat ?? '');
    await prefs.setString('lastLng', lng ?? '');
    await prefs.setDouble('lastRadius', radius);
    lastLat = lat;
    lastLng = lng;
    lastRadius = radius;
  }

  // Load last location and radius from cache
  Future<void> loadLastLocationAndRadius() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    lastLat = prefs.getString('lastLat') ?? lat;
    lastLng = prefs.getString('lastLng') ?? lng;
    lastRadius = prefs.getDouble('lastRadius') ?? radius;
  }

// Date Setting on post
  String checkMonth(int month) {
    String? lanCode = Get.locale?.languageCode;
    bool en = lanCode == "en";
    switch (month) {
      case 1:
        return en ? "Januray" : "Enero";
      case 2:
        return en ? "February" : "febrero";
      case 3:
        return en ? "March" : "Marzo";
      case 4:
        return en ? "April" : "Abril";
      case 5:
        return en ? "May" : "Puede";
      case 6:
        return en ? "June" : "Junio";
      case 7:
        return en ? "July" : "Julio";
      case 8:
        return en ? "August" : "Agosto";
      case 9:
        return en ? "September" : "septiembre";
      case 10:
        return en ? "October" : "octubre";
      case 11:
        return en ? "November" : "noviembre";
      case 12:
        return en ? "December" : "diciembre";
      default:
        return en ? "December" : "diciembre";
    }
  }

  int noOfDays(String? updatedOn) {
    final updatedDate = updatedOn ?? DateTime.now().toString();
    final currentDate = DateTime.now();
    final differenceInDays =
        currentDate.difference(DateTime.parse(updatedDate.toString())).inDays;
    return differenceInDays;
  }

  setCategoryNull() {}

  String setDaysAgo(String? updatedOn) {
    String? lanCode = Get.locale?.languageCode;
    bool en = lanCode == "en";
    int days = noOfDays(updatedOn);
    if (en) {
      return "${'updated'.tr} $days ${'days_2'.tr} ${'ago_2'.tr}";
    } else {
      return "${'updated'.tr} ${'ago_2'.tr} $days ${'days_2'.tr}";
    }
  }

  format(DateTime date) {
    String? lanCode = Get.locale?.languageCode;
    bool en = lanCode == "en";
    var suffix = "th";
    var digit = date.day % 10;
    if ((digit > 0 && digit < 4) && (date.day < 11 || date.day > 13)) {
      suffix = ["st", "nd", "rd"][digit - 1];
    }
    if (!en) {
      suffix = "de";
    }
    String month = checkMonth(date.month);
    if (!en) {
      return new DateFormat("d '$suffix' '$month'").format(date);
    }
    return new DateFormat("'$month' d'$suffix'").format(date);
  }

  bool isBusinessAccount = false;

  fetchAccountType() async {
    await authCont.fetchAccountType();
    isBusinessAccount = authCont.isBusinessAccount;
    update();
  }

  Future getAllPackages() async {
    Response response =
        await api.postWithForm("api/getAllPackages", {}, showdialog: true);
    if (response.statusCode == 200) {
      allPackagesModel = AllPackagesModel.fromJson(response.body);
      Get.to(SubscriptionScreen());
    } else {}
  }

  String? imagePath;

  filePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      packageImage = File(result.files.single.path!).path;
      imagePath = packageImage;
      update();
    } else {
      // User canceled the picker
    }
    update();
  }

  ImagePicker picker = ImagePicker();
  String? videoPath;

  Future<void> pickVideo() async {
    try {
      final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

      if (pickedFile != null) {
        File videoFile = File(pickedFile.path);

        int fileSizeInBytes = videoFile.lengthSync();
        double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB <= 20.0) {
          // Allow up to 20MB
          videoPath = pickedFile.path;
          update();
          Get.to(VideoPlayerScreenFile(
            file: videoFile,
          ));
        } else {}
      }
    } catch (e) {}
  }

  String selectedValue = 'No';
  String selectedValueYourself = 'Yes';
  int numberOfPromoCodes = 1;
  bool isEnterPromoCode = false;
  TextEditingController promoCode = TextEditingController();

  Future buyPackage() async {
    Get.log("Authorization': 'Bearer ${authCont.user?.accessToken}");
    List<String> image = [];
    image.add(packageImage ?? "");
    List<String>? video = [];
    video.add(videoPath ?? "");
    final response = await api.postWithForm(
        "api/buyPackage",
        isEnterPromoCode
            ? {
                'package_id': 2,
                'user_phone': phoneNoTr,
                'user_name': userNameTr,
                'type': "PromoCode",
                'promo_code': promoCode.text,
                'buy_own_subscription':
                    selectedValueYourself == 'No' ? "0" : "1",
              }
            : {
                'package_id': paymentTypeId,
                'transaction_id': transactionNumberController.text,
                'user_phone': phoneNoTr,
                'cardHolderName': userNameTr,
                'creditCardNumber': cardNumberController ?? "",
                'expirationMonth': expiryMonthController ?? "",
                'expirationYear': expiryYearController ?? "",
                'type': type,
                'cvv': cvc ?? "",
                'user_name': userNameTr,
                'buy_own_subscription':
                    selectedValueYourself == 'No' ? "0" : "1",
                'generate_promo':
                    selectedValue == 'No' ? "0" : numberOfPromoCodes.toString()
              },
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${authCont.user?.accessToken}'
        },
        // headers: {
        //   'Content-Type': 'application/json; charset=UTF-8',
        //   'Accept': 'application/json',
        //   'Access-Control-Allow-Origin': "*",
        //   'Authorization': 'Bearer ${authCont.user?.accessToken}'
        // },
        imageKey: "video",
        image: video,
        showdialog: true);
    if (response.statusCode == 200) {
      isEnterPromoCode = false;
      Get.offAll(Navigation_Bar());
      if (response.body['message'] ==
          "Your package is already active, you cannot purchase another package.") {
      } else if (response.body['message'] == "Invalid promo code") {}
      if (isEnterPromoCode) {
      } else if (type == "Other") {
        // errorAlertToast(
        //     "Promotion code applied successfully. Your subscription has started"
        //         .tr);
      } else {}
    } else {}
  }

  AllPromoCodesModel? allPromoCodesModel;

  promoCodesAndPackage() async {
    showLoading();
    await getAllPromoCodes();
    await checkUserPackageProfile();
    Get.back();
    Get.to(PromoCodeScreen());
  }

  Future reportListing(String id, String reason) async {
    Response response = await api.postWithForm(
        "api/reportListing",
        {
          'listing_id': '${id}',
          'reason': '${reason}',
          'description': '',
        },
        headers: {
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': "*",
          'Authorization': 'Bearer ${authCont.user?.accessToken}'
        },
        showdialog: true);
    if (response.statusCode == 200) {
      Get.back();
    } else {}
  }

  Future getAllPromoCodes() async {
    Response response = await api.postWithForm("api/getAllPromoCodes", {},
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': "*",
          'Authorization': 'Bearer ${authCont.user?.accessToken}'
        },
        showdialog: false);
    if (response.statusCode == 200) {
      allPromoCodesModel = AllPromoCodesModel.fromJson(response.body);
    } else {
      print('Something went wrong\nPlease try again!'.tr);
    }
  }

  Future ratting() async {
    Response response = await api.postWithForm(
        "api/addListingAndSellerReviews",
        {
          'seller_id': '${listingModel?.user?.id}',
          'listing_id': '${listingModel?.id}',
          'response_time_rating': '${userRatting}',
          'friendliness_rating': '${userRatting}',
          'item_as_described_rating': '${userRatting}',
          'comment': reviewController.text
        },
        headers: {
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': "*",
          'Authorization': 'Bearer ${authCont.user?.accessToken}'
        },
        showdialog: false);
    if (response.statusCode == 200) {
      print("Add successfully".tr);
    } else {
      print('Something went wrong\nPlease try again!'.tr);
    }
  }

  Future checkUserPackage() async {
    Response response = await api.postWithForm("api/checkUserPackage", {},
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': "*",
          'Authorization': 'Bearer ${authCont.user?.accessToken}'
        },
        showdialog: false);
    if (response.statusCode == 200) {
      Get.log(" pending check: ${response.body['status']}");
      if (response.body['data'] != null &&
          response.body['data']['status'] == "pending") {
        _showSubscriptionDialog();
        return;
      }
      if (response.body["message"] == "No subscription found" ||
          response.body["message"] == "No se encontró ninguna suscripción") {
        // errorAlertToast('No subscription found'.tr);
      }
      if (response.body["message"] == "Your package has expired" ||
          response.body["message"] == "Tu paquete ha caducado") {
        print('Your package has expired'.tr);
      }
      if (response.body["listing_count"] != null &&
          response.body["listing_count"] > 1000) {
        // errorAlertToast('${response.body["message"]}');
        getAllPackages();
      }

      // }else if(response.body["data"]['status']=="pending"){
    } else {
      print('Something went wrong\nPlease try again!'.tr);
    }
  }

  void _showSubscriptionDialog() {
    showDialog(
      barrierDismissible: false,
      context: navigatorKey.currentState!.context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: CustomText(
            text: 'Subscription Pending'.tr,
            fontWeight: FontWeight.w700,
          ),
          content: CustomText(
            text: 'Your subscription will be approved within 72 hours.'.tr,
            fontWeight: FontWeight.w700,
          ),
          actions: [
            InkWell(
              onTap: () {
                authCont.currentIndexBottomAppBar = 0;
                Get.offAll(Navigation_Bar());
              },
              child: SizedBox(
                  height: 40.h, child: MyButton(text: 'Go to Home'.tr)),
            )
          ],
        );
      },
    );
  }

  CheckUserPackageModel? checkUserPackageModel;

  Future checkUserPackageProfile() async {
    Response response = await api.postWithForm("api/checkUserPackage", {},
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': "*",
          'Authorization': 'Bearer ${authCont.user?.accessToken}'
        },
        showdialog: false);
    if (response.statusCode == 200) {
      checkUserPackageModel = CheckUserPackageModel.fromJson(response.body);
    } else {
      print('Something went wrong\nPlease try again!'.tr);
    }
  }

  Future<bool> deleteListing() async {
    try {
      // Enhanced validation
      if (listingModel?.id == null) {
        print('Error: No listing ID available for deletion');
        return false;
      }

      // Check authentication
      if (authCont.user?.accessToken == null ||
          authCont.user?.accessToken == "") {
        print('Error: No valid authentication token');
        return false;
      }

      // Add retry mechanism for network issues
      int retryCount = 0;
      const maxRetries = 2;

      while (retryCount <= maxRetries) {
        try {
          Response response = await api
              .postWithForm(
                  "api/deleteListing",
                  {
                    'listing_id': listingModel?.id,
                  },
                  headers: {
                    'Accept': 'application/json',
                    'Access-Control-Allow-Origin': "*",
                    'Authorization': 'Bearer ${authCont.user?.accessToken}'
                  },
                  showdialog: false)
              .timeout(Duration(seconds: 15));

          if (response.statusCode == 200) {
            print('Listing Delete Successfully'.tr);

            // Sync deletion with home screen list
            syncDeletedItemFromHomeScreen();

            return true;
          } else if (response.statusCode == 401) {
            print('Authentication failed - token may be expired');
            // Try to refresh token
            await authCont.getuserDetail();
            if (retryCount < maxRetries) {
              retryCount++;
              continue;
            }
            return false;
          } else if (response.statusCode == 500) {
            // Server error - retry
            if (retryCount < maxRetries) {
              retryCount++;
              await Future.delayed(Duration(seconds: 1)); // Brief delay
              continue;
            }
            print(
                'Server error - delete failed with status: ${response.statusCode}');
            return false;
          } else {
            print('Delete failed with status: ${response.statusCode}');
            print('Response body: ${response.body}');
            return false;
          }
        } on TimeoutException {
          if (retryCount < maxRetries) {
            retryCount++;
            print(
                'Delete request timed out, retrying... (${retryCount}/${maxRetries})');
            continue;
          }
          print('Delete request timed out after $maxRetries retries');
          return false;
        } catch (networkError) {
          if (retryCount < maxRetries) {
            retryCount++;
            print(
                'Network error, retrying... (${retryCount}/${maxRetries}): $networkError');
            await Future.delayed(Duration(seconds: 1));
            continue;
          }
          print('Network error after $maxRetries retries: $networkError');
          return false;
        }
      }

      return false;
    } catch (e) {
      print('Unexpected exception during delete: $e');
      return false;
    }
  }

  /// Sync deleted item from home screen listing to keep lists in sync
  void syncDeletedItemFromHomeScreen() {
    if (listingModel?.id != null) {
      final deletedItemId = listingModel!.id;

      // Remove from main home screen list
      final initialCount = listingModelList.length;
      listingModelList.removeWhere((listing) => listing.id == deletedItemId);
      final finalCount = listingModelList.length;

      if (finalCount < initialCount) {
        // Trigger UI update for home screen
        update();

        // Also remove from search list if present
        listingModelSearchList
            .removeWhere((listing) => listing.id == deletedItemId);
      } else {}
    }
  }

  /// Sync multiple deleted items from home screen listing for bulk operations
  void syncMultipleDeletedItemsFromHomeScreen(List<int> deletedIds) {
    if (deletedIds.isNotEmpty) {
      // Remove from main home screen list
      final initialCount = listingModelList.length;
      listingModelList
          .removeWhere((listing) => deletedIds.contains(listing.id));
      final finalCount = listingModelList.length;

      if (finalCount < initialCount) {
        final removedCount = initialCount - finalCount;
        Get.log("🗑️ Removed $removedCount expired listings from home screen");

        // Trigger UI update for home screen
        update();

        // Also remove from search list if present
        listingModelSearchList
            .removeWhere((listing) => deletedIds.contains(listing.id));
      } else {}
    }
  }

  /// Delete all listings for current tab (active, inactive, or sold)
  Future<bool> deleteAllListings() async {
    try {
      // Get current account type for filtering
      String currentAccountType = authCont.isBusinessAccount ? "1" : "0";

      // Filter listings based on current account type and current tab
      List<ListingModel> listingsToDelete = userListingModelList
          .where((listing) => listing.businessStatus == currentAccountType)
          .toList();

      if (listingsToDelete.isEmpty) {
        return true; // Nothing to delete
      }

      // Make ALL API calls concurrently for super fast deletion
      List<Future<bool>> futures = listingsToDelete.map((listing) async {
        try {
          if (listing.id == null) {
            return false;
          }

          Response response = await api.postWithForm(
              "api/deleteListing",
              {
                'listing_id': listing.id,
              },
              headers: {
                'Accept': 'application/json',
                'Access-Control-Allow-Origin': "*",
                'Authorization': 'Bearer ${authCont.user?.accessToken}'
              },
              showdialog: false);

          if (response.statusCode == 200) {
            return true;
          } else {
            return false;
          }
        } catch (e) {
          return false;
        }
      }).toList();

      // Wait for ALL requests to complete simultaneously
      List<bool> results = await Future.wait(futures);
      int successCount = results.where((success) => success).length;

      // Remove successfully deleted listings from local list
      if (successCount > 0) {
        // Get list of IDs that were successfully deleted for sync with home screen
        List<int> deletedIds = [];
        for (int i = 0; i < listingsToDelete.length; i++) {
          if (results[i] && listingsToDelete[i].id != null) {
            deletedIds.add(listingsToDelete[i].id!);
          }
        }

        userListingModelList.removeWhere(
            (listing) => listing.businessStatus == currentAccountType);

        // Sync deletion with home screen list
        syncMultipleDeletedItemsFromHomeScreen(deletedIds);

        // Update the counters
        if (authCont.isBusinessAccount) {
          bussinessPostCount = userListingModelList
              .where((listing) => listing.businessStatus == "1")
              .length;
        } else {
          personalAcountPost = userListingModelList
              .where((listing) => listing.businessStatus == "0")
              .length;
        }

        update(); // Trigger UI rebuild
      }

      return successCount > 0; // Return true if at least one was deleted
    } catch (e) {
      return false;
    }
  }

  Future markASoldListing() async {
    Response response = await api.postWithForm(
        "api/markASoldListing",
        {
          'listing_id': listingId,
        },
        headers: {
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': "*",
          'Authorization': 'Bearer ${authCont.user?.accessToken}'
        },
        showdialog: true);
    if (response.statusCode == 200) {
      Get.offAll(Navigation_Bar());
      print('Mark a Sold Successfully'.tr);
    } else {
      print('Something went wrong\nPlease try again!'.tr);
    }
  }

  listingSaveDraft(BuildContext context) async {
    optionalInformation.addAll({
      'type': selectedCategory?.name == "Cars & Bikes"
          ? "Cars & Bikes"
          : selectedCategory?.name == "Real Estate"
              ? "Real Estate"
              : selectedCategory?.name == "Services"
                  ? "Services"
                  : "Others",
      'listing_details': {
        "make": makeController.text.trim(),
        "model": modelController.text.trim(),
        "furnished": furnished,
        "job_type": jobType,
      },
      'optional_details': {
        'phone_number': phoneController.text.trim(),
        'website': websiteController.text.trim(),
        'condition': conditionController.text.trim(),
        'fulfillment': fulfillmentController.text.trim(),
        'payment': paymentController.text.trim(),
      },
      'video_link': youTubeController.text.trim(),
    });
    String rawPrice = priceCont?.text.replaceAll(' ', '') ?? "0";
    Map<String, dynamic> data = {
      'category': jsonDecode(jsonEncode(selectedCategory)),
      'sub_category': jsonDecode(jsonEncode(selectedSubCategory)) ?? "",
      'sub_sub_category': jsonDecode(jsonEncode(selectedSubSubCategory)) ?? "",
      'price': rawPrice,
      'currency': selectedCurrency ?? 'USD',
      'title': titleCont.text.trim(),
      'latitude': lat,
      'longitude': lng,
      'address': addressCont.text.trim(),
      'description': descriptionCont.text.trim(),
      'additional_features': optionalInformation,
      'tag': tags,
      'gallery': postImages,
    };
    final SharedPreferences prefss = await SharedPreferences.getInstance();
    prefss.setString('listing_data', jsonEncode(data));
    Navigator.push(
        context,
        PremiumPageTransitions.slideFromRight(
          Navigation_Bar(),
        ));
  }

  listingGetDraft() async {
    final SharedPreferences prefss = await SharedPreferences.getInstance();
    final String data = prefss.getString('listing_data') ?? "{}";
    listingModel = ListingModel.fromJson(jsonDecode(data));

    furnished =
        listingModel?.additionalFeatures?.listingDetails?.furnished ?? "";
    jobType = listingModel?.additionalFeatures?.listingDetails?.jobType ?? "";
    modelController.text =
        listingModel?.additionalFeatures?.listingDetails?.model ?? "";
    makeController.text =
        listingModel?.additionalFeatures?.listingDetails?.make ?? "";
    titleCont.text =
        listingModel?.title == "null" ? "" : "$listingModel?.title}";
    // Format price with spaces
    String rawPrice = listingModel?.price.toString() ?? "0";
    if (rawPrice != "0") {
      priceCont?.text = PriceFormatter().formatNumber(int.parse(rawPrice));
    } else {
      priceCont?.text = "";
    }
    descriptionCont.text = listingModel?.description ?? "";
    addressCont.text = listingModel?.address ?? "";
    listingModel?.tag?.forEach((element) {
      tags.add(element);
    });
    listingModel?.gallery?.forEach((element) {
      postImages.add(element);
    });
    lat = listingModel?.latitude.toString();
    lng = listingModel?.longitude.toString();
    youTubeController.text = listingModel?.additionalFeatures?.videoLink ?? "";
    phoneController.text =
        listingModel?.additionalFeatures?.optionalDetails?.phoneNumber ?? "";
    websiteController.text =
        listingModel?.additionalFeatures?.optionalDetails?.website ?? "";
    conditionController.text =
        listingModel?.additionalFeatures?.optionalDetails?.condition ?? "";
    fulfillmentController.text =
        listingModel?.additionalFeatures?.optionalDetails?.fulfillment ?? "";
    paymentController.text =
        listingModel?.additionalFeatures?.optionalDetails?.payment ?? "";
    update();
  }

  Future addListing(BuildContext context) async {
    String tagsData = "";
    String price = "0";
    String rawPrice = priceCont?.text.replaceAll(RegExp(r'[^\d]'), '') ?? "0";
    if (rawPrice.isEmpty) rawPrice = "0";
    (priceCont != null && priceCont!.text.isEmpty)
        ? price = "0"
        : price = rawPrice;
    for (int i = 0; i < tags.length; i++) {
      if (i == 0) {
        tagsData = "${tags[i]}";
      } else {
        tagsData = "$tagsData,${tags[i]}";
      }
    }
    tags.forEach((element) {});
    optionalInformation.addAll({
      'type': selectedCategory?.name == "Cars & Bikes"
          ? "Cars & Bikes"
          : selectedCategory?.name == "Real Estate"
              ? "Real Estate"
              : selectedCategory?.name == "Services"
                  ? "Services"
                  : "Others",
      'listing_details': {
        "make": makeController.text.trim(),
        "model": modelController.text.trim(),
        "furnished": furnished,
        "job_type": jobType,
      },
      'optional_details': {
        'phone_number': phoneController.text.trim(),
        'website': websiteController.text.trim(),
        'condition': conditionController.text.trim(),
        'fulfillment': fulfillmentController.text.trim(),
        'payment': paymentController.text.trim(),
      },
      'video_link': youTubeController.text.trim(),
    });

    // Additional debugging for authorization
    print(
        "🔥 BEFORE API CALL - authCont.user?.accessToken: ${authCont.user?.accessToken}");
    print(
        "🔥 BEFORE API CALL - authCont.user is null: ${authCont.user == null}");

    // Try to refresh token if it's null or empty
    if (authCont.user?.accessToken == null ||
        authCont.user?.accessToken == "") {
      await authCont.getuserDetail();

      if (authCont.user?.accessToken == null ||
          authCont.user?.accessToken == "") {
        print('Authentication error. Please login again.');
        return;
      }
    }

    // Use tokenMain as fallback if user token is still null
    String authToken = authCont.user?.accessToken ?? tokenMain ?? "";

    // Debug the request data
    Map<String, dynamic> requestData = {
      'category_id': selectedCategory?.id,
      'sub_category_id': selectedSubCategory?.id ?? "",
      'sub_sub_category_id': selectedSubSubCategory?.id ?? "",
      'price': price,
      'currency': selectedCurrency ?? 'USD',
      'business_status': authCont.isBusinessAccount ? 1 : 0,
      'title': titleCont.text.trim(),
      'latitude': (lat ?? lat1).toString(),
      'longitude': (lng ?? lng1).toString(),
      'address': addressCont.text.trim(),
      'description': descriptionCont.text.trim(),
      'additional_features': jsonEncode(optionalInformation),
      'tag': tagsData.isEmpty ? "" : tagsData,
    };

    // Remove empty fields that might cause server validation issues
    requestData.removeWhere((key, value) => value == null);

    // Ensure required fields have default values
    if (requestData['sub_sub_category_id'] == "") {
      requestData.remove('sub_sub_category_id');
    }
    if (requestData['tag'] == "") {
      requestData.remove('tag');
    }
    Response response;

    if (postImages.isNotEmpty) {
      try {
        // Process and compress images before upload
        List<String> processedImages =
            await ImageUploadHelper.processImagesForUpload(postImages);

        if (processedImages.isEmpty) {
          return;
        }

        // Use multipart form with proper authentication
        response = await api.postWithForm(
          "api/addListing",
          requestData,
          image: processedImages,
          imageKey: "gallery[]",
          headers: {
            'Authorization': 'Bearer $authToken',
            // Remove Content-Type header as it will be set automatically for multipart
          },
          showdialog: true,
        );

        // Log response for debugging
        print('📥 Response Status: ${response.statusCode}');
        if (response.statusCode != 200) {
          print('❌ Response Body: ${response.body}');
        }
      } catch (e) {
        print('❌ Error during image upload: $e');
        print(
            'Failed to upload images. Please check your connection and try again.');
        return;
      }
    } else {
      // Use JSON for text-only posts
      response = await api.postData(
        "api/addListing",
        requestData,
        headers: {
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': "*",
          'Authorization': 'Bearer $authToken'
        },
        showdialog: true,
      );
    }

    if (response.statusCode == 200) {
      if (response.body["message"] ==
          "Your free limit is completed. For more listing, you can purchase package.") {
        getAllPackages();
      } else if (response.body["message"] ==
          "Your package is in pending, waiting for admin approval.") {
        showPendingDialog(context);
      } else {
        final SharedPreferences prefss = await SharedPreferences.getInstance();
        prefss.remove('listing_data');
        priceCont?.clear();
        titleCont.clear();
        addressCont.clear();
        descriptionCont.clear();
        tagsController.clear();

        // Clear all tags and optional information
        tags.clear();
        optionalInformation.clear();

        // Clear YouTube and optional detail controllers
        youTubeController.clear();
        phoneController.clear();
        websiteController.clear();
        conditionController.clear();
        fulfillmentController.clear();
        paymentController.clear();
        makeController.clear();
        modelController.clear();

        // Clear uploaded images
        postImages.clear();
        uploadingImages.clear();

        // Reset expansion states to closed
        showBelowFields = [0, 0, 0, 0, 0, 0];

        // Reset other form state
        furnished = '';
        jobType = '';

        selectedCategory = null;
        selectedSubCategory = null;
        selectedSubSubCategory = null;
        selectedCurrency = 'USD';
        authCont.currentIndexBottomAppBar = 3;

        // Refresh listings data after successful post creation
        status = "active";
        soldStatus = null;

        // Force refresh the listings
        await getSellerListingByStatus();

        Get.offAll(Navigation_Bar());
        print('Post Add Successfully'.tr);
      }
    } else {
      print('Something went wrong\nPlease try again!'.tr);
    }
  }

  Future editListing(BuildContext context) async {
    isEditingListing.value = true;
    update();

    String tagsData = "";
    for (int i = 0; i < tags.length; i++) {
      if (i == 0) {
        tagsData = "${tags[i]}";
      } else {
        tagsData = "$tagsData,${tags[i]}";
      }
    }
    optionalInformation.addAll({
      'type': selectedCategory?.name == "Cars & Bikes"
          ? "Cars & Bikes"
          : selectedCategory?.name == "Real Estate"
              ? "Real Estate"
              : selectedCategory?.name == "Services"
                  ? "Services"
                  : "Others",
      'listing_details': {
        "make": makeController.text.trim(),
        "model": modelController.text.trim(),
        "furnished": furnished,
        "job_type": jobType,
      },
      'optional_details': {
        'phone_number': phoneController.text.trim(),
        'website': websiteController.text.trim(),
        'condition': conditionController.text.trim(),
        'fulfillment': fulfillmentController.text.trim(),
        'payment': paymentController.text.trim(),
      },
      'video_link': youTubeController.text.trim(),
    });
    // Remove spaces and other formatting from price
    String rawPrice = priceCont?.text.replaceAll(RegExp(r'[^\d]'), '') ?? "0";
    if (rawPrice.isEmpty) rawPrice = "0";

    // Prepare request data
    Map<String, dynamic> requestData = {
      'listing_id': listingModel?.id,
      'category_id': selectedCategory?.id,
      'sub_category_id': selectedSubCategory?.id ?? "",
      'sub_sub_category_id': selectedSubSubCategory?.id ?? "",
      'price': rawPrice,
      'currency': selectedCurrency ?? 'USD',
      'title': titleCont.text.trim(),
      'business_status': authCont.isBusinessAccount ? 1 : 0,
      'address': addressCont.text.trim(),
      'latitude': lat.toString(),
      'longitude': lng.toString(),
      'description': descriptionCont.text.trim(),
      'additional_features': jsonEncode(optionalInformation),
      'tag': tagsData
    };

    // Remove empty fields that might cause server validation issues
    requestData.removeWhere((key, value) => value == null);

    // Ensure required fields have default values
    if (requestData['sub_sub_category_id'] == "") {
      requestData.remove('sub_sub_category_id');
    }
    if (requestData['tag'] == "") {
      requestData.remove('tag');
    }

    // Ensure authentication token is available
    String authToken = authCont.user?.accessToken ?? tokenMain ?? "";

    Response response;

    if (postImages.isNotEmpty) {
      try {
        // Process and compress images before upload
        print('📤 Processing ${postImages.length} images for edit...');
        List<String> processedImages =
            await ImageUploadHelper.processImagesForUpload(postImages);

        if (processedImages.isEmpty) {
          print('Failed to process images. Please try again.');
          isEditingListing.value = false;
          update();
          return;
        }

        // Use multipart form with proper authentication
        response = await api.postWithForm(
          "api/editListing",
          requestData,
          image: processedImages,
          imageKey: "gallery[]",
          headers: {
            'Authorization': 'Bearer $authToken',
            // Remove Content-Type header as it will be set automatically for multipart
          },
          showdialog: true,
        );

        // Log response for debugging
        print('📥 Response Status: ${response.statusCode}');
        if (response.statusCode != 200) {
          print('❌ Response Body: ${response.body}');
        }
      } catch (e) {
        print('❌ Error during image upload: $e');
        print(
            'Failed to upload images. Please check your connection and try again.');
        isEditingListing.value = false;
        update();
        return;
      }
    } else {
      try {
        // Use JSON for text-only posts
        response = await api.postData(
          "api/editListing",
          requestData,
          headers: {
            'Accept': 'application/json',
            'Access-Control-Allow-Origin': "*",
            'Authorization': 'Bearer $authToken'
          },
          showdialog: true,
        );
      } catch (e) {
        print('❌ Error during text-only post update: $e');
        print(
            'Failed to update listing. Please check your connection and try again.');
        isEditingListing.value = false;
        update();
        return;
      }
    }
    if (response.statusCode == 200) {
      priceCont?.clear();
      titleCont.clear();
      addressCont.clear();
      descriptionCont.clear();
      tagsController.clear();

      // Clear all tags and optional information
      tags.clear();
      optionalInformation.clear();

      // Clear YouTube and optional detail controllers
      youTubeController.clear();
      phoneController.clear();
      websiteController.clear();
      conditionController.clear();
      fulfillmentController.clear();
      paymentController.clear();
      makeController.clear();
      modelController.clear();

      // Clear uploaded images
      postImages.clear();
      uploadingImages.clear();

      // Reset expansion states to closed
      showBelowFields = [0, 0, 0, 0, 0, 0];

      // Reset other form state
      furnished = '';
      jobType = '';

      selectedCategory = null;
      selectedSubCategory = null;
      selectedCurrency = 'USD';
      selectedSubSubCategory = null;

      // Refresh listings data after successful post edit
      status = "active";
      soldStatus = null;

      // Force refresh the listings
      await getSellerListingByStatus();

      Get.offAll(Navigation_Bar());
      print('Post Updated Successfully'.tr);
    } else {
      print('Something went wrong\nPlease try again!'.tr);
    }

    isEditingListing.value = false;
    update();
  }

  Future<void> getCoordinatesFromAddress() async {
    try {
      final locationCont = Get.put(LocationController());
      if (locationCont.lat != null && locationCont.lng != null) {
        lat = locationCont.lat.toString();
        lng = locationCont.lng.toString();
        Get.log("Coordinates from LocationController: $lat, $lng");
        return;
      }
      String latestAddress = 'Habana, Cuba';
      if (address != null && address!.isNotEmpty) {
        latestAddress = address!;
      } else if (authCont.user?.city != null) {
        latestAddress = '${authCont.user?.city}, Cuba';
      }
      // Get coordinates from address using Google Geocoding API
      Map<String, double>? coordinates =
          await _getCoordinatesFromAddress(latestAddress);
      if (coordinates != null) {
        lat = coordinates['lat'].toString();
        lng = coordinates['lng'].toString();
        Get.log("Geocoded coordinates: $lat, $lng, radius: $radius");
      } else {
        Get.log("No coordinates found for address: $latestAddress",
            isError: true);
        print('Unable to fetch location. Using default coordinates.'.tr);
        lat = "23.124792615936276"; // Fallback default
        lng = "-82.38597269330762";
      }
    } catch (e, stackTrace) {
      Get.log("Error in getCoordinatesFromAddress: $e\n$stackTrace",
          isError: true);
      print('Failed to get coordinates. Using default coordinates.'.tr);
      lat = "23.124792615936276"; // Fallback default
      lng = "-82.38597269330762";
    }
  }

  showPendingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
              'Your package is in pending, waiting for admin approval.'.tr),
        );
      },
    );
  }

  void onScrollSearch() async {
    Get.log("=== SCROLL SEARCH DEBUG ===");
    Get.log("Current pixels: ${searchScrollController.position.pixels}");
    Get.log("Max extent: ${searchScrollController.position.maxScrollExtent}");
    Get.log(
        "Trigger point: ${searchScrollController.position.maxScrollExtent - 100}");
    Get.log("Is search loading: ${isSearchLoading.value}");
    Get.log("Has more search: ${hasMoreSearch.value}");
    Get.log("Current search results count: ${listingModelSearchList.length}");

    if (searchScrollController.position.pixels >=
        searchScrollController.position.maxScrollExtent - 100) {
      if (!isSearchLoading.value && hasMoreSearch.value) {
        Get.log("🚀 Triggering search pagination...");
        await getListingSearch(isLoadMore: true);
      } else {
        Get.log(
            "❌ Pagination blocked - Loading: ${isSearchLoading.value}, HasMore: ${hasMoreSearch.value}");
      }
    }
  }

  // Future getListing() async {
  //   isPostLoading.value = true;
  //   update();
  //    listingModelList.clear();
  //   await getCoordinatesFromAddress();
  //   Get.log("""{
  //         'user_id': ${authCont.user?.userId},
  //         'category_id': ${selectedCategory?.id},
  //         'sub_category_id': ${selectedSubCategory?.id},
  //         'sub_sub_category_id': ${selectedSubSubCategory?.id},
  //         'latitude': ${lat},
  //         'longitude': ${lng},
  //         'radius': ${radius},
  //         'min_price': '',
  //         'max_price': '',
  //         'search_by_title': ''
  //       }""");
  //        Get.log("Authorization': 'Bearer ${authCont.user?.accessToken}");
  //   Response response = await api.postWithForm(
  //       "api/getListing?page=1",
  //       {
  //         'user_id': authCont.user?.userId ?? "",
  //         'category_id': selectedCategory?.id ?? "",
  //         'sub_category_id': selectedSubCategory?.id ?? "",
  //         'sub_sub_category_id': selectedSubSubCategory?.id ?? "",
  //         'latitude': lat,
  //         'longitude': lng,
  //         'radius': radius??"500",
  //         'min_price': '',
  //         'max_price': '',
  //         'search_by_title': ''
  //       },
  //       showdialog: false);
  //   if (response.statusCode == 200) {
  //     List<dynamic> dataListing = [];
  //     dataListing.addAll(response.body['data']['data']);
  //     String isBusinessType = isBusinessAccount ? "1" : "0";

  //     dataListing.forEach((element) {
  //       //  if (element["business_status"].toString() == isBusinessType) {
  //       listingModelList.add(ListingModel.fromJson(element));
  //       // }
  //     });
  //     isPostLoading.value = false;

  //     update();
  //     isType = 0;
  //   } else {
  //      isPostLoading.value = false;

  //     update();
  //     errorAlertToast('Something went wrong\nPlease try again!'.tr);
  //   }
  // }

  Future getSellerDetails(
      String businessType, int onScreen, bool isNavigate) async {
    Response response = await api.postWithForm("api/getSellerDetails",
        {'seller_id': sellerId, 'reviews_type': "all", "type": selectedType},
        showdialog: true);
    if (response.statusCode == 200) {
      sellerDetailsModel = SellerDetailsModel.fromJson(response.body);

      if (!isBusinessAccount) {
        sellerDetailsModel?.data?.sellerListings?.data
            ?.removeWhere((element) => element.businessStatus == '1');
      } else {
        sellerDetailsModel?.data?.sellerListings?.data
            ?.removeWhere((element) => element.businessStatus == '0');
      }
      if (isNavigate) {
        Get.to(MyPublicPage(
          businessType: businessType,
          onScreen: onScreen,
        ));
      }
    } else {
      print('Something went wrong\nPlease try again!'.tr);
    }
  }

  Future getSellerDetails1(String reviewsType) async {
    var headers = {'Accept': 'application/json'};
    var request = http.MultipartRequest(
        'POST', Uri.parse('https://ventacuba.co/api/getSellerDetails'));
    request.fields
        .addAll({'seller_id': sellerId!, 'reviews_type': reviewsType});

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String data = await response.stream.bytesToString();
      sellerDetailsModel = SellerDetailsModel.fromJson(jsonDecode(data));
    } else {
      await response.stream.bytesToString();
      print('Something went wrong\nPlease try again!'.tr);
    }
  }

  Future getFavouriteItems() async {
    fetchAccountType();
    int currentPage = 1;
    bool hasMore = true;
    userFavouriteListingModelList.clear();

    while (hasMore) {
      Response response = await api.postWithForm(
        "api/getFavouriteItems",
        {'page': currentPage.toString()},
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': "*",
          'Authorization': 'Bearer ${authCont.user?.accessToken}'
        },
        showdialog: currentPage == 1, // only show dialog on first page
      );

      if (response.statusCode == 200) {
        var body = response.body['data'];
        List<dynamic> dataListing = body['data'];

        for (var element in dataListing) {
          userFavouriteListingModelList.add(ListingModel.fromJson(element));
        }

        currentPage++;
        hasMore = currentPage <= (body['last_page'] ?? 1);
      } else {
        print('Something went wrong\nPlease try again!');
        hasMore = false;
      }
    }

    print(
        "Total Favourite Listing Count: ${userFavouriteListingModelList.length}");
    Get.to(FavouriteListings());
  }

  Future getFavouriteSeller() async {
    Response response = await api.postWithForm("api/getFavouriteSeller", {},
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': "*",
          'Authorization': 'Bearer ${authCont.user?.accessToken}'
        },
        showdialog: true);
    if (response.statusCode == 200) {
      favouriteSellerModel = FavouriteSellerModel.fromJson(response.body);
      if (!isBusinessAccount) {
        favouriteSellerModel.data
            ?.removeWhere((element) => element.type == "Business");
      } else {
        favouriteSellerModel.data
            ?.removeWhere((element) => element.type == "Personal");
      }

      Get.to(FavouriteSeller());
    } else {
      print('Something went wrong\nPlease try again!'.tr);
    }
  }

  int personalAcountPost = 0;
  int bussinessPostCount = 0;

  // Add a flag to prevent concurrent calls
  bool _isLoadingListings = false;

  Future getSellerListingByStatus() async {
    // Prevent concurrent calls
    if (_isLoadingListings) {
      return;
    }

    _isLoadingListings = true;

    try {
      // Reset counts before fetching new data
      personalAcountPost = 0;
      bussinessPostCount = 0;

      fetchAccountType();
      Map<String, dynamic> data = {};
      if (status != null) {
        data.addAll({'status': status});
      } else if (soldStatus != null) {
        data.addAll({'sold_status': soldStatus});
      }

      Response response = await api.postWithForm(
          "api/getSellerListingByStatus",
          headers: {
            'Accept': 'application/json',
            'Access-Control-Allow-Origin': "*",
            'Authorization': 'Bearer ${authCont.user?.accessToken}'
          },
          data,
          showdialog: false);

      if (response.statusCode == 200) {
        List<dynamic> dataListing = [];
        dataListing.addAll(response.body['data']);

        // Clear the list before adding new data
        userListingModelList.clear();

        // Reset counters again to ensure clean state
        int tempBusinessCount = 0;
        int tempPersonalCount = 0;

        // Process each listing
        dataListing.forEach((element) {
          var businessStatus = element["business_status"];
          print(
              '🔥 Listing business_status: $businessStatus (type: ${businessStatus.runtimeType})');

          ListingModel listing = ListingModel.fromJson(element);
          userListingModelList.add(listing);

          // Count listings by business status (handle both string and int types)
          String businessStatusStr = businessStatus.toString();
          if (businessStatusStr == "1") {
            tempBusinessCount++;
          } else if (businessStatusStr == "0") {
            tempPersonalCount++;
          } else {}
        });

        // Update the actual counters only after processing all listings
        bussinessPostCount = tempBusinessCount;
        personalAcountPost = tempPersonalCount;

        print(
            '🔥 Final counts - Total listings: ${userListingModelList.length}');

        listingLoading = false;
        update();
      } else {
        print('Something went wrong\nPlease try again!'.tr);
      }
    } catch (e) {
      print('Something went wrong\nPlease try again!'.tr);
    } finally {
      _isLoadingListings = false;
    }
  }

  Future<void> getListingSearch({bool isLoadMore = false}) async {
    if (isSearchLoading.value) return;

    isSearchLoading.value = true;
    update();

    try {
      // Ensure coordinates are available
      await getCoordinatesFromAddress();

      if (!isLoadMore) {
        currentSearchPage.value = 1;
        listingModelSearchList.clear();
        hasMoreSearch.value = true; // Reset hasMore when fetching fresh data
      }

      if (!hasMoreSearch.value) {
        isSearchLoading.value = false;
        update();
        return;
      }

      Get.log("Fetching Search Page: ${currentSearchPage.value}");
      Get.log(
          "Search Filters - Min: '${minPriceController.text.trim()}', Max: '${maxPriceController.text.trim()}', Search: '${searchController.text.trim()}'");
      Get.log("Location - Lat: '${lat}', Lng: '${lng}', Radius: '${radius}'");

      // Check if no location is selected for search
      bool noLocationSelected = false;
      if (address == null ||
          address == '' ||
          address == "4JF7+RM6, Av. Paseo, La Habana, Cuba" ||
          (lat == "23.124792615936276" &&
              lng == "-82.38597269330762" &&
              radius == 50.0)) {
        noLocationSelected = true;
        Get.log(
            "📍 SEARCH: No location selected - will search only user's own posts");
      }

      // Send appropriate category filters to backend
      // Build request data based on location selection
      Map<String, dynamic> requestData = {
        'user_id': authCont.user?.userId ?? "",
        'category_id': selectedCategory?.id ?? "",
        'sub_category_id': selectedSubCategory?.id ?? "",
        'sub_sub_category_id': selectedSubSubCategory?.id ?? "",
        'latitude': noLocationSelected ? "" : (lat ?? "23.124792615936276"),
        'longitude': noLocationSelected ? "" : (lng ?? "-82.38597269330762"),
        'radius': noLocationSelected ? "" : radius.toString(),
        'min_price': minPriceController.text.trim(),
        'max_price': maxPriceController.text.trim(),
        'search_by_title': searchController.text.trim(),
      };

      Get.log("=== SEARCH REQUEST DEBUG ===");
      Get.log("Search Text: '${searchController.text.trim()}'");
      Get.log("Selected Category ID: ${selectedCategory?.id}");
      Get.log("Selected Category Name: ${selectedCategory?.name}");
      Get.log("Selected SubCategory ID: ${selectedSubCategory?.id}");
      Get.log("Selected SubCategory Name: ${selectedSubCategory?.name}");
      Get.log("Selected SubSubCategory ID: ${selectedSubSubCategory?.id}");
      Get.log("Selected SubSubCategory Name: ${selectedSubSubCategory?.name}");
      Get.log("Min Price: '${minPriceController.text.trim()}'");
      Get.log("Max Price: '${maxPriceController.text.trim()}'");
      Get.log("Latitude: ${lat}");
      Get.log("Longitude: ${lng}");
      Get.log("Radius: ${radius}");
      Get.log("Full Request Data: $requestData");

      Response response = await api.postData(
        "api/getListing?page=${currentSearchPage.value}",
        requestData,
        headers: {
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': "*",
          'Authorization': 'Bearer ${authCont.user?.accessToken}'
        },
        showdialog: false,
      );

      Get.log("Response Status: ${response.statusCode}");
      Get.log("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> dataListing = response.body['data']['data'] ?? [];
        Get.log("=== SEARCH RESPONSE DEBUG ===");
        Get.log("API returned ${dataListing.length} items");

        if (dataListing.isNotEmpty) {
          List<ListingModel> newListings = [];

          // Parse each search item with error handling to prevent crashes
          for (var element in dataListing) {
            try {
              if (element != null && element is Map<String, dynamic>) {
                // Parse the item - ListingModel.fromJson handles null values gracefully
                newListings.add(ListingModel.fromJson(element));
              }
            } catch (e, stackTrace) {
              Get.log("Search: Error parsing listing item: $e", isError: true);
              Get.log("Search: Stack trace: $stackTrace", isError: true);
              Get.log("Search: Problematic element: $element", isError: true);
            }
          }

          // Debug: Log first few items to verify category filtering
          for (int i = 0;
              i < (newListings.length > 3 ? 3 : newListings.length);
              i++) {
            Get.log(
                "Item ${i + 1}: '${newListings[i].title}' - Category: ${newListings[i].category?.name} (ID: ${newListings[i].category?.id})");
          }

          // LOCATION-BASED FILTERING LOGIC (same as home page)
          // Check if no location is selected
          bool noLocationSelected = false;
          // Check for default location or empty location
          if (address == null ||
              address == '' ||
              address == "4JF7+RM6, Av. Paseo, La Habana, Cuba" ||
              (lat == "23.124792615936276" &&
                  lng == "-82.38597269330762" &&
                  radius == 50.0)) {
            noLocationSelected = true;
            Get.log(
                "📍 SEARCH: No location selected - will filter to user's own posts only");
          }

          // Log the search results
          if (noLocationSelected) {
            Get.log(
                "📍 SEARCH NO LOCATION: API returned ${newListings.length} own posts");
          } else {
            Get.log(
                "📍 SEARCH LOCATION SELECTED: Showing ${newListings.length} posts from location: ${address}");
          }

          // Apply client-side price filtering
          newListings = applyPriceFilter(newListings);
          Get.log("After price filtering: ${newListings.length} items");

          // Apply client-side category filtering as backup
          newListings = applyCategoryFilter(newListings);
          Get.log("After category filtering: ${newListings.length} items");

          // Filter duplicates based on titles
          Set<String> existingTitles = listingModelSearchList
              .where((item) => item.title != null && item.title!.isNotEmpty)
              .map((item) => item.title!.toLowerCase().trim())
              .toSet();

          List<ListingModel> uniqueItems = newListings.where((item) {
            if (item.title == null || item.title!.isEmpty) {
              return true; // Allow items with no title
            }
            String itemTitle = item.title!.toLowerCase().trim();
            return !existingTitles.contains(itemTitle);
          }).toList();

          Get.log(
              "Filtered ${newListings.length - uniqueItems.length} duplicate titles");
          listingModelSearchList.addAll(uniqueItems);
          currentSearchPage.value++; // Increment page correctly
          hasMoreSearch.value = dataListing.length ==
              15; // More pages available if exactly 15 items returned
          listingModelList = listingModelSearchList;

          Get.log("=== PAGINATION UPDATE ===");
          Get.log("Added ${newListings.length} new items");
          Get.log("Total search results: ${listingModelSearchList.length}");
          Get.log("Next page will be: ${currentSearchPage.value}");
          Get.log(
              "Has more pages: ${hasMoreSearch.value} (based on API returning ${dataListing.length} items)");

          // Apply sorting after fetching data
          applySortingToSearchList();
          Get.log(
              "Final search results count: ${listingModelSearchList.length}");
          update();
        } else {
          hasMoreSearch.value = false;
          Get.log("No more search results available");
        }
      } else {
        Get.log("API Error: ${response.statusCode}, ${response.body}",
            isError: true);
        print('Something went wrong\nPlease try again!'.tr);
      }
    } catch (e, stackTrace) {
      Get.log("Error in getListingSearch: $e\n$stackTrace", isError: true);
      print('Something went wrong. Please try again.'.tr);
    } finally {
      isSearchLoading.value = false;
      update();
    }
  }

  // Method to apply sorting to search results
  void applySortingToSearchList() {
    switch (selectedType) {
      case "Newest First":
        listingModelSearchList.sort((a, b) {
          DateTime dateA =
              DateTime.tryParse(a.updatedAt ?? '') ?? DateTime.now();
          DateTime dateB =
              DateTime.tryParse(b.updatedAt ?? '') ?? DateTime.now();
          return dateB.compareTo(dateA); // Newest first
        });
        break;
      case "Oldest First":
        listingModelSearchList.sort((a, b) {
          DateTime dateA =
              DateTime.tryParse(a.updatedAt ?? '') ?? DateTime.now();
          DateTime dateB =
              DateTime.tryParse(b.updatedAt ?? '') ?? DateTime.now();
          return dateA.compareTo(dateB); // Oldest first
        });
        break;
      case "Highest Price":
        listingModelSearchList.sort((a, b) {
          double priceA = double.tryParse(a.price ?? '0') ?? 0;
          double priceB = double.tryParse(b.price ?? '0') ?? 0;
          return priceB.compareTo(priceA); // Highest first
        });
        break;
      case "Lowest Price":
        listingModelSearchList.sort((a, b) {
          double priceA = double.tryParse(a.price ?? '0') ?? 0;
          double priceB = double.tryParse(b.price ?? '0') ?? 0;
          return priceA.compareTo(priceB); // Lowest first
        });
        break;
    }
  }

  // Method to apply client-side price filtering
  List<ListingModel> applyPriceFilter(List<ListingModel> listings) {
    String minPriceText = minPriceController.text.trim();
    String maxPriceText = maxPriceController.text.trim();

    // If no price filters are set, return all listings
    if (minPriceText.isEmpty && maxPriceText.isEmpty) {
      return listings;
    }

    double? minPrice;
    double? maxPrice;

    // Parse min price
    if (minPriceText.isNotEmpty) {
      try {
        minPrice = double.parse(minPriceText);
      } catch (e) {
        Get.log("Invalid min price format: $minPriceText");
      }
    }

    // Parse max price
    if (maxPriceText.isNotEmpty) {
      try {
        maxPrice = double.parse(maxPriceText);
      } catch (e) {
        Get.log("Invalid max price format: $maxPriceText");
      }
    }

    // Filter listings based on price
    return listings.where((listing) {
      double? listingPrice;
      try {
        listingPrice = double.parse(listing.price ?? '0');
      } catch (e) {
        return false; // Exclude listings with invalid price
      }

      // Check min price constraint
      if (minPrice != null && listingPrice < minPrice) {
        return false;
      }

      // Check max price constraint
      if (maxPrice != null && listingPrice > maxPrice) {
        return false;
      }

      return true;
    }).toList();
  }

  // Method to apply client-side category filtering
  List<ListingModel> applyCategoryFilter(List<ListingModel> listings) {
    // If no category is selected, return all listings
    if (selectedCategory == null &&
        selectedSubCategory == null &&
        selectedSubSubCategory == null) {
      Get.log("No category filter applied - showing all listings");
      return listings;
    }

    return listings.where((listing) {
      // Check sub-subcategory first (most specific)
      if (selectedSubSubCategory != null) {
        bool matches = listing.subSubCategory?.id == selectedSubSubCategory?.id;
        Get.log(
            "SubSubCategory filter: ${listing.title} - Expected: ${selectedSubSubCategory?.id}, Got: ${listing.subSubCategory?.id}, Match: $matches");
        return matches;
      }

      // Check subcategory - show posts from subcategory AND all its sub-subcategories
      if (selectedSubCategory != null) {
        // Check if post belongs directly to the subcategory
        bool directSubCategoryMatch =
            listing.subCategory?.id == selectedSubCategory?.id;

        // Check if post belongs to a sub-subcategory under this subcategory
        bool subSubCategoryMatch = false;
        if (listing.subSubCategory != null) {
          // Parse subCategoryId from the sub-subcategory to compare with selected subcategory
          try {
            int? subSubCategoryParentId =
                int.tryParse(listing.subSubCategory?.subCategoryId ?? '');
            subSubCategoryMatch =
                subSubCategoryParentId == selectedSubCategory?.id;
          } catch (e) {
            Get.log("Error parsing subCategoryId: $e");
          }
        }

        bool matches = directSubCategoryMatch || subSubCategoryMatch;
        Get.log(
            "SubCategory filter: ${listing.title} - Expected SubCategory: ${selectedSubCategory?.id}, Got SubCategory: ${listing.subCategory?.id}, Got SubSubCategory Parent: ${listing.subSubCategory?.subCategoryId}, Direct Match: $directSubCategoryMatch, SubSub Match: $subSubCategoryMatch, Final Match: $matches");
        return matches;
      }

      // Check main category
      if (selectedCategory != null) {
        bool matches = listing.category?.id == selectedCategory?.id;
        Get.log(
            "Category filter: ${listing.title} - Expected: ${selectedCategory?.id}, Got: ${listing.category?.id}, Match: $matches");
        return matches;
      }

      return true;
    }).toList();
  }

  Future getListingDetails(String listingId, {bool showDialog = true}) async {
    try {
      // Validate listingId
      if (listingId.isEmpty || listingId == "null") {
        if (showDialog) {
          print('Invalid listing ID'.tr);
        }
        return;
      }

      // Try multipart first (original approach), then fallback to JSON
      Response response;
      try {
        response = await api.postWithForm(
          "api/getListingDetails",
          {
            'listing_id': listingId,
            'user_id': authCont.user?.userId ?? "",
          },
          headers: {
            'Accept': 'application/json',
            'Access-Control-Allow-Origin': "*",
            'Authorization': 'Bearer ${authCont.user?.accessToken}'
          },
          showdialog: false,
        );
      } catch (e) {
        response = await api.postData(
          "api/getListingDetails",
          {
            'listing_id': listingId,
            'user_id': authCont.user?.userId ?? "",
          },
          headers: {
            'Accept': 'application/json',
            'Access-Control-Allow-Origin': "*",
            'Authorization': 'Bearer ${authCont.user?.accessToken}'
          },
          showdialog: false,
        );
      }

      if (response.statusCode == 200) {
        if (response.body != null && response.body["data"] != null) {
          isListing = 0;
          listingModel = ListingModel.fromJson(response.body["data"]);

          // Cross-check and update isSellerFavorite with local favorite sellers list
          _updateSellerFavoriteStatus();

          update(); // Ensure UI updates when listing details are fetched
          if (showDialog) {
            Get.to(FrameScreen());
          }
        } else {
          // Don't show toast for chat screen (showDialog = false) to avoid annoying users
          if (showDialog) {
            print('No listing data found'.tr);
          }
        }
      } else {
        print(
            "🔥 getListingDetails error: ${response.statusCode} - ${response.body}");

        // Set listingModel to null to trigger the loading/error state in UI
        listingModel = null;
        update();

        // Don't show toast for chat screen (showDialog = false) to avoid annoying users
        if (showDialog) {
          if (response.statusCode == 500) {
            print('Listing not found or has been removed.'.tr);
            // Go back if this was opened from a direct action
            Get.back();
          } else {
            print('Something went wrong\nPlease try again!'.tr);
          }
        }
      }
    } catch (e) {
      // Set listingModel to null to trigger the loading/error state in UI
      listingModel = null;
      update();
      if (showDialog) {
        print('Listing not found or has been removed.'.tr);
        // Go back if this was opened from a direct action
        Get.back();
      }
    }
  }

  bool isFavouriteScreen = false;
  String favouriteId = "";

  Future<bool> favouriteItem() async {
    Response response = await api.postWithForm(
        "api/favouriteItem",
        {
          'item_id': isFavouriteScreen
              ? favouriteId
              : listingModel?.id.toString() ?? "",
        },
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': "*",
          'Authorization': 'Bearer ${authCont.user?.accessToken}'
        },
        showdialog: false);
    if (response.statusCode == 200) {
      isFavouriteScreen = false;
      return true;
    } else {
      print('Something went wrong\nPlease try again!'.tr);
      return false;
    }
  }

  /// Helper method to sync favorite status in home listing when changed from favorites screen
  void syncFavoriteStatusInHomeListing(
      String itemId, String newFavoriteStatus) {
    try {
      // Find and update the corresponding item in listingModelList
      for (int i = 0; i < listingModelList.length; i++) {
        if (listingModelList[i].itemId == itemId) {
          listingModelList[i].isFavorite = newFavoriteStatus;
          break;
        }
      }

      // Also update in search results if they exist
      for (int i = 0; i < listingModelSearchList.length; i++) {
        if (listingModelSearchList[i].itemId == itemId) {
          listingModelSearchList[i].isFavorite = newFavoriteStatus;
          break;
        }
      }
    } catch (e) {}
  }

  /// Helper method to sync favorite status in favorites list when changed from home screen
  void syncFavoriteStatusInFavoritesList(
      String itemId, String newFavoriteStatus) {
    try {
      if (newFavoriteStatus == "0") {
        // Remove from favorites list if unfavorited
        userFavouriteListingModelList
            .removeWhere((item) => item.itemId == itemId);
      } else {
        // If favorited, we don't need to add it here as it will be fetched next time
        // the favorites screen is opened
        print(
            "Item $itemId favorited - will be available in next favorites refresh");
      }
    } catch (e) {}
  }

  /// Helper method to sync favorite status in home screen when changed from favorites screen
  void syncFavoriteStatusInHomeScreen(String itemId, String newFavoriteStatus) {
    try {
      bool itemFound = false;

      // Update in main listing list
      for (int i = 0; i < listingModelList.length; i++) {
        if (listingModelList[i].itemId == itemId) {
          listingModelList[i].isFavorite = newFavoriteStatus;
          itemFound = true;
          print(
              "Updated item $itemId favorite status to $newFavoriteStatus in main listing list");
          break;
        }
      }

      // Update in search list
      for (int i = 0; i < listingModelSearchList.length; i++) {
        if (listingModelSearchList[i].itemId == itemId) {
          listingModelSearchList[i].isFavorite = newFavoriteStatus;
          print(
              "Updated item $itemId favorite status to $newFavoriteStatus in search list");
          break;
        }
      }

      // Update the current listing model if it matches
      if (listingModel?.itemId == itemId) {
        listingModel?.isFavorite = newFavoriteStatus;
        print(
            "Updated current listing model $itemId favorite status to $newFavoriteStatus");
      }

      if (itemFound) {
        print(
            "Successfully synced item $itemId to favorite status $newFavoriteStatus");
      } else {}

      // Force update all GetBuilder widgets
      update();

      // Also trigger update on the next frame to ensure UI rebuilds
      WidgetsBinding.instance.addPostFrameCallback((_) {
        update();
      });

      // Force update using GetX's global update mechanism
      Get.forceAppUpdate();
    } catch (e) {}
  }

  /// Helper method to sync seller favorite status in home screen when changed from favorites screen
  void syncSellerFavoriteStatusInHomeScreen(
      String sellerId, String newFavoriteStatus) {
    try {
      // Update in main listing list
      for (int i = 0; i < listingModelList.length; i++) {
        if (listingModelList[i].user?.id.toString() == sellerId) {
          listingModelList[i].isSellerFavorite = newFavoriteStatus;
          print(
              "Updated seller $sellerId favorite status to $newFavoriteStatus in home screen");
        }
      }

      // Update in search list
      for (int i = 0; i < listingModelSearchList.length; i++) {
        if (listingModelSearchList[i].user?.id.toString() == sellerId) {
          listingModelSearchList[i].isSellerFavorite = newFavoriteStatus;
        }
      }

      // Update the current listing model if it matches
      if (listingModel?.user?.id.toString() == sellerId) {
        listingModel?.isSellerFavorite = newFavoriteStatus;
      }

      update();
    } catch (e) {}
  }

  /// Helper method to sync multiple favorite status changes at once
  void syncMultipleFavoriteStatusInHomeScreen(
      List<String> itemIds, String newFavoriteStatus) {
    try {
      for (String itemId in itemIds) {
        // Update in main listing list
        for (int i = 0; i < listingModelList.length; i++) {
          if (listingModelList[i].itemId == itemId) {
            listingModelList[i].isFavorite = newFavoriteStatus;
            break;
          }
        }

        // Update in search list
        for (int i = 0; i < listingModelSearchList.length; i++) {
          if (listingModelSearchList[i].itemId == itemId) {
            listingModelSearchList[i].isFavorite = newFavoriteStatus;
            break;
          }
        }
      }

      // Update the current listing model if it matches any of the items
      if (listingModel?.itemId != null &&
          itemIds.contains(listingModel?.itemId)) {
        listingModel?.isFavorite = newFavoriteStatus;
      }

      update();
      print(
          "Updated ${itemIds.length} items favorite status to $newFavoriteStatus in home screen");
    } catch (e) {}
  }

  /// Helper method to sync multiple seller favorite status changes at once
  void syncMultipleSellerFavoriteStatusInHomeScreen(
      List<String> sellerIds, String newFavoriteStatus) {
    try {
      for (String sellerId in sellerIds) {
        // Update in main listing list
        for (int i = 0; i < listingModelList.length; i++) {
          if (listingModelList[i].user?.id.toString() == sellerId) {
            listingModelList[i].isSellerFavorite = newFavoriteStatus;
          }
        }

        // Update in search list
        for (int i = 0; i < listingModelSearchList.length; i++) {
          if (listingModelSearchList[i].user?.id.toString() == sellerId) {
            listingModelSearchList[i].isSellerFavorite = newFavoriteStatus;
          }
        }
      }

      // Update the current listing model if it matches any of the sellers
      if (listingModel?.user?.id != null &&
          sellerIds.contains(listingModel?.user?.id.toString())) {
        listingModel?.isSellerFavorite = newFavoriteStatus;
      }

      update();
      print(
          "Updated ${sellerIds.length} sellers favorite status to $newFavoriteStatus in home screen");
    } catch (e) {}
  }

  Future<bool> favouriteSeller() async {
    Response response = await api.postWithForm(
        "api/favouriteSeller",
        {
          'seller_id': sellerId,
          'type': authCont.isBusinessAccount ? "Business" : "Personal"
        },
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': "*",
          'Authorization': 'Bearer ${authCont.user?.accessToken}'
        },
        showdialog: false);
    if (response.statusCode == 200) {
      // Update local favorite sellers list to keep it in sync
      _updateLocalFavoriteSellersList();
      return true;
    } else {
      print('Something went wrong\nPlease try again!'.tr);
      return false;
    }
  }

  /// Remove all favourite listings
  Future<bool> removeAllFavouriteListings() async {
    try {
      // Create a list of all item IDs to remove
      List<String> itemIds = userFavouriteListingModelList
          .map((item) => item.itemId ?? "")
          .where((id) => id.isNotEmpty)
          .toList();

      if (itemIds.isEmpty) {
        return true; // Nothing to remove
      }

      // Make ALL API calls concurrently for super fast deletion
      List<Future<bool>> futures = itemIds.map((itemId) async {
        try {
          Response response =
              await api.postWithForm("api/favouriteItem", {'item_id': itemId},
                  headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                    'Accept': 'application/json',
                    'Access-Control-Allow-Origin': "*",
                    'Authorization': 'Bearer ${authCont.user?.accessToken}'
                  },
                  showdialog: false);

          if (response.statusCode == 200) {
            return true;
          } else {
            return false;
          }
        } catch (e) {
          return false;
        }
      }).toList();

      // Wait for ALL requests to complete simultaneously
      List<bool> results = await Future.wait(futures);
      int successCount = results.where((success) => success).length;

      // Clear the local list regardless of individual failures
      userFavouriteListingModelList.clear();

      // Sync with home screen - mark all removed items as unfavorited
      syncMultipleFavoriteStatusInHomeScreen(itemIds, "0");

      return successCount > 0; // Return true if at least one was removed
    } catch (e) {
      return false;
    }
  }

  /// Remove all favourite sellers
  Future<bool> removeAllFavouriteSellers() async {
    try {
      // Create a list of all seller IDs to remove
      List<String> sellerIds = favouriteSellerModel.data
              ?.map((seller) => seller.sellerId ?? "")
              .where((id) => id.isNotEmpty)
              .toList() ??
          [];

      if (sellerIds.isEmpty) {
        return true; // Nothing to remove
      }

      // Make ALL API calls concurrently for super fast deletion
      List<Future<bool>> futures = sellerIds.map((sellerIdToRemove) async {
        try {
          Response response = await api.postWithForm(
              "api/favouriteSeller",
              {
                'seller_id': sellerIdToRemove,
                'type': authCont.isBusinessAccount ? "Business" : "Personal"
              },
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'Accept': 'application/json',
                'Access-Control-Allow-Origin': "*",
                'Authorization': 'Bearer ${authCont.user?.accessToken}'
              },
              showdialog: false);

          if (response.statusCode == 200) {
            return true;
          } else {
            print(
                "Failed to remove seller $sellerIdToRemove: ${response.statusCode}");
            return false;
          }
        } catch (e) {
          return false;
        }
      }).toList();

      // Wait for ALL requests to complete simultaneously
      List<bool> results = await Future.wait(futures);
      int successCount = results.where((success) => success).length;

      // Clear the local list regardless of individual failures
      favouriteSellerModel.data?.clear();

      // Sync with home screen - mark all removed sellers as unfavorited
      syncMultipleSellerFavoriteStatusInHomeScreen(sellerIds, "0");

      return successCount > 0; // Return true if at least one was removed
    } catch (e) {
      return false;
    }
  }

  /// Helper method to check if a seller is in the favorite sellers list
  bool _isSellerInFavoritesList(String? sellerId) {
    if (sellerId == null || favouriteSellerModel.data == null) {
      return false;
    }

    return favouriteSellerModel.data!
        .any((seller) => seller.sellerId == sellerId);
  }

  /// Helper method to update the isSellerFavorite status based on local favorite sellers list
  void _updateSellerFavoriteStatus() {
    if (listingModel?.user?.id != null) {
      String currentSellerId = listingModel!.user!.id.toString();
      bool isInFavorites = _isSellerInFavoritesList(currentSellerId);

      // Update the isSellerFavorite field to match the actual favorite status
      listingModel!.isSellerFavorite = isInFavorites ? "1" : "0";

      print(
          "Updated isSellerFavorite for seller $currentSellerId: ${listingModel!.isSellerFavorite}");
    }
  }

  /// Helper method to update local favorite sellers list after adding/removing a seller
  void _updateLocalFavoriteSellersList() {
    if (sellerId == null) return;

    bool isCurrentlyInFavorites = _isSellerInFavoritesList(sellerId);

    if (isCurrentlyInFavorites) {
      // Remove from favorites list
      favouriteSellerModel.data
          ?.removeWhere((seller) => seller.sellerId == sellerId);

      // Sync with home screen
      syncSellerFavoriteStatusInHomeScreen(sellerId ?? "", "0");
    } else {
      // Add to favorites list - we need to get seller details to add to the list
      // For now, we'll just refresh the favorites list from the server
      _refreshFavoriteSellersList();

      // Sync with home screen
      syncSellerFavoriteStatusInHomeScreen(sellerId ?? "", "1");
    }
  }

  /// Helper method to refresh the favorite sellers list from server
  Future<void> _refreshFavoriteSellersList() async {
    try {
      Response response = await api.postWithForm("api/getFavouriteSeller", {},
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
            'Access-Control-Allow-Origin': "*",
            'Authorization': 'Bearer ${authCont.user?.accessToken}'
          },
          showdialog: false);

      if (response.statusCode == 200) {
        favouriteSellerModel = FavouriteSellerModel.fromJson(response.body);
        if (!isBusinessAccount) {
          favouriteSellerModel.data
              ?.removeWhere((element) => element.type == "Business");
        } else {
          favouriteSellerModel.data
              ?.removeWhere((element) => element.type == "Personal");
        }
      }
    } catch (e) {}
  }

  /// Helper method to load favorite sellers list silently during app initialization
  Future<void> _loadFavoriteSellersSilently() async {
    // Only load if user is logged in
    if (authCont.user?.accessToken == null ||
        authCont.user?.accessToken == "") {
      return;
    }

    try {
      Response response = await api.postWithForm("api/getFavouriteSeller", {},
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
            'Access-Control-Allow-Origin': "*",
            'Authorization': 'Bearer ${authCont.user?.accessToken}'
          },
          showdialog: false);

      if (response.statusCode == 200) {
        favouriteSellerModel = FavouriteSellerModel.fromJson(response.body);
        if (!isBusinessAccount) {
          favouriteSellerModel.data
              ?.removeWhere((element) => element.type == "Business");
        } else {
          favouriteSellerModel.data
              ?.removeWhere((element) => element.type == "Personal");
        }
        print(
            "Loaded favorite sellers list silently: ${favouriteSellerModel.data?.length ?? 0} sellers");
      }
    } catch (e) {
      // Don't show error to user since this is a background operation
    }
  }

  Future getCategories() async {
    Response response =
        await api.postWithForm("api/getCategories", {}, showdialog: false);
    if (response.statusCode == 200) {
      categoriesModel = CategoriesModel.fromJson(response.body);
      isType = 0;
    } else {
      print('Something went wrong\nPlease try again!'.tr);
    }
  }

  Future getSubCategories() async {
    loadingSubCategory = true.obs;
    loadingCategory = true.obs;
    update();
    try {
      Response response = await api.postWithForm("api/getSubCategories",
          {'category_id': selectedCategory?.id.toString()},
          showdialog: false);

      if (response.statusCode == 200) {
        subCategoriesModel = SubCategoriesModel.fromJson(response.body);
        isType = 1;

        // Check if this is being called from search screen
        if (isSearchScreen) {
          // For search screen, just update the data without navigation
          update();
        } else {
          // Original navigation logic for other screens
          isNavigate
              ? {
                  // getListing(),
                  Get.to(CategoryFrom()),
                  // ?.then((value) {
                  // selectedCategory = null;
                  selectedSubCategory = null,
                  selectedSubSubCategory = null,

                  // getListing();
                  // Reset price filter when category changes in search screen
                  if (isSearchScreen)
                    {
                      minPriceController.clear(),
                      maxPriceController.clear(),
                    },
                  getListingSearch(),
                  // })
                }
              : {
                  if (subCategoriesModel?.data?.isEmpty ?? false)
                    {
                      selectedSubCategory = null,
                      selectedSubSubCategory = null,
                      // Don't call Get.back() when in edit mode (isNavigate = false)
                      // The Get.back() was causing the edit screen to close unexpectedly
                      if (isNavigate) Get.back(),
                    }
                  else
                    {update()}
                };
        }
      } else {
        print('Something went wrong\nPlease try again!'.tr);
      }
    } catch (e) {
    } finally {
      loadingSubCategory = false.obs;
      loadingCategory = false.obs;
    }
  }

  Future getSubCategoriesBottom() async {
    // Reset sub-subcategory selections when loading new subcategories
    resetSubSubCategorySelections();

    Response response = await api.postWithForm("api/getSubCategories",
        {'category_id': selectedCategory?.id.toString()},
        showdialog: true);
    if (response.statusCode == 200) {
      subCategoriesModel = SubCategoriesModel.fromJson(response.body);
      isSubSubCategories = false;
      update();
      if (subCategoriesModel?.data?.isEmpty ?? false) {
        Get.to(Post(isUpdate: false));
      } else {
        Get.to(CategoryFromBottom());
      }
    } else {
      print('Something went wrong\nPlease try again!'.tr);
    }
  }

  bool isSubSubCategories = false;

  /// Reset subcategory and sub-subcategory selections
  void resetSubCategorySelections() {
    selectedSubCategory = null;
    selectedSubSubCategory = null;
    subCategoriesModel = null;
    subSubCategoriesModel = null;
    isSubSubCategories = false;
    update();
  }

  /// Reset only sub-subcategory selections
  void resetSubSubCategorySelections() {
    selectedSubSubCategory = null;
    subSubCategoriesModel = null;
    isSubSubCategories = false;
    update();
  }

  Future getSubSubCategoriesBottom() async {
    // Reset sub-subcategory selection when loading new sub-subcategories
    selectedSubSubCategory = null;

    Response response = await api.postWithForm(
        "api/getSubSubCategories",
        {
          'category_id': selectedCategory?.id.toString(),
          'sub_category_id': selectedSubCategory?.id.toString(),
        },
        showdialog: true);
    loadingSubSubCategory = false.obs;
    loadingCategory = false.obs;
    update();
    if (response.statusCode == 200) {
      subSubCategoriesModel = SubSubCategoriesModel.fromJson(response.body);
      if (subSubCategoriesModel?.data?.isEmpty ?? false) {
        Get.to(Post(isUpdate: false));
      } else {
        isSubSubCategories = true;
        update();
      }
    } else {
      print('Something went wrong\nPlease try again!'.tr);
    }
  }

  Future getSubSubCategories() async {
    loadingSubSubCategory = true.obs;
    loadingCategory = true.obs;
    update();
    Response response = await api.postWithForm(
        "api/getSubSubCategories",
        {
          'category_id': selectedCategory?.id.toString(),
          'sub_category_id': selectedSubCategory?.id.toString(),
        },
        showdialog: false);
    loadingSubSubCategory = false.obs;
    loadingCategory = false.obs;
    update();
    if (response.statusCode == 200) {
      subSubCategoriesModel = SubSubCategoriesModel.fromJson(response.body);
      isType = 2;

      // Only clear listings and reset pagination when navigating (not during edit initialization)
      if (isNavigate) {
        currentPage.value = 1;
        hasMore.value = true;
        listingModelList.clear();
        currentSearchPage.value = 1;
        listingModelSearchList.clear();
      }
      update();

      // Check if this is being called from search screen
      if (isSearchScreen) {
        // For search screen, just update the data without navigation
        update();
      } else {
        // Original navigation logic for other screens
        isNavigate
            ? {
                getListingSearch(),
                Get.to(SubSubCategories()),
              }
            : {
                if (subSubCategoriesModel?.data?.isEmpty ?? false)
                  {
                    selectedSubSubCategory = null,
                    isSearchScreen
                        ? {
                            // Reset price filter when category changes in search screen
                            minPriceController.clear(),
                            maxPriceController.clear(),
                            // Don't call Get.back() when in edit mode (isNavigate = false)
                            if (isNavigate) Get.back(),
                            getListingSearch()
                          }
                        : {
                            // Don't call Get.back() when in edit mode (isNavigate = false)
                            if (isNavigate) Get.back()
                          }
                  }
                else
                  {
                    // Reset price filter when category changes in search screen
                    if (isSearchScreen)
                      {
                        minPriceController.clear(),
                        maxPriceController.clear(),
                      },
                    getListingSearch(),
                    update()
                  }
              };
      }
    } else {
      print('Something went wrong\nPlease try again!'.tr);
    }
  }

  Future<void> getLatLong(String city, String province) async {
    try {
      String address = '$city, $province';
      Map<String, double>? coordinates =
          await _getCoordinatesFromAddress(address);

      if (coordinates != null) {
        Get.log(
            'Latitude: ${coordinates['lat']}, Longitude: ${coordinates['lng']}');
        lat1 = "${coordinates['lat']}";
        lng1 = "${coordinates['lng']}";
        lat = "${coordinates['lat']}";
        lng = "${coordinates['lng']}";
      }
    } catch (e) {}
  }

  // API-based geocoding replacement function
  Future<Map<String, double>?> _getCoordinatesFromAddress(
      String address) async {
    const apiKey = 'AIzaSyBx95Bvl9O-US2sQpqZ41GdsHIprnXvJv8';
    final encodedAddress = Uri.encodeComponent(address);
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$encodedAddress&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return {
            'lat': location['lat'].toDouble(),
            'lng': location['lng'].toDouble(),
          };
        }
      }
    } catch (e) {}
    return null;
  }
}


// {"status":false,"errors":"Sending credit card numbers directly to the Stripe API is generally unsafe. We suggest you use test tokens that map to the test card you are using, see https:\/\/stripe.com\/docs\/testing. To enable testing raw card data APIs, see https:\/\/support.stripe.com\/questions\/enabling-access-to-raw-card-data-apis."}
// flutter: {status: false, errors: Sending credit card numbers directly to the Stripe API is generally unsafe. We suggest you use test tokens that map to the test card you are using, see https://stripe.com/docs/testing. To enable testing raw card data APIs, see https://support.stripe.com/questions/enabling-access-to-raw-card-data-apis.}