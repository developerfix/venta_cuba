import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
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
import '../Models/user_data.dart';
import '../Utils/funcations.dart';
import '../api/api_client.dart';
import '../view/PromoCodesScreen/PromoCodesScreen.dart';
import '../view/category/SubSubCategories.dart';
import '../view/category/category_from.dart';

import '../view/profile/favourite_listings.dart';
import '../view/profile/favourite_seller.dart';
import '../view/profile/my_public_page.dart';
import '../view/subscription/Subscription.dart';
import 'package:venta_cuba/Models/CategoriesModel.dart' as cta;

List<String> beforeData = [];

//Your package is in pending, waiting for admin approval.
class HomeController extends GetxController {
  TextEditingController? priceCont = TextEditingController(text: "0");
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
  final geocoding = geo.GeocodingPlatform.instance;
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

  @override
  void onInit() {
    super.onInit();
    fetchAccountType();
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
    Get.log("Scroll controller reset");
  }

  Future<void> homeData() async {
    try {
      await loadLastLocationAndRadius();
      if (hasLocationOrRadiusChanged() || listingModelList.isEmpty) {
        loadingHome = true.obs;
        scrollsController.addListener(onScroll);
        searchScrollController.addListener(onScrollSearch);
        currentPage.value = 1;
        hasMore.value = true;
        await getCategories();
        await getListing();
        // Load favorite sellers list silently to ensure it's available for checking
        await _loadFavoriteSellersSilently();
        saveLocationAndRadius();
      }
    } catch (e, stackTrace) {
      Get.log("Error in homeData: $e\n$stackTrace", isError: true);
      errorAlertToast('Failed to load data. Please try again.'.tr);
    } finally {
      loadingHome = false.obs;
      print('doneee');
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

      Get.log("Fetching Page: ${currentPage.value}");
      Response response = await api.postWithForm(
        "api/getListing?page=${currentPage.value}",
        {
          'user_id': authCont.user?.userId ?? "",
          'category_id': selectedCategory?.id ?? "",
          // For subcategory filtering, don't send sub_category_id to server
          // Let client-side filtering handle subcategory + sub-subcategory logic
          'sub_category_id': selectedSubSubCategory != null
              ? selectedSubCategory?.id ?? ""
              : "",
          'sub_sub_category_id': selectedSubSubCategory?.id ?? "",
          'latitude': lat ?? "23.124792615936276",
          'longitude': lng ?? "-82.38597269330762",
          'radius': radius.toString(),
          'min_price': '',
          'max_price': '',
          'search_by_title': ''
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

          listingModelList.addAll(newListings);
          currentPage.value++;
          hasMore.value = dataListing.length == 15;
        } else {
          hasMore.value = false;
        }
        saveLocationAndRadius();
      } else {
        Get.log("API error: ${response.statusCode}, ${response.body}",
            isError: true);
        errorAlertToast('Failed to fetch listings. Please try again.'.tr);
      }
    } catch (e, stackTrace) {
      Get.log("Error in getListing: $e\n$stackTrace", isError: true);
      errorAlertToast('Something went wrong. Please try again.'.tr);
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
      return "${'updated'.tr} $days ${'days'.tr} ${'ago'.tr}";
    } else {
      return "${'updated'.tr} ${'ago'.tr} $days ${'days'.tr}";
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
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
    }
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
          print("File size: $fileSizeInMB MB");
        } else {
          errorAlertToast("Please select a video less than 20MB".tr);
        }
      }
    } catch (e) {
      print("Error picking video: $e");
    }
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
                'transaction_id': transactionNumberController?.text,
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
    print("objhkjjhghject...........${response.body}");
    print("object...........${response.statusCode}");
    if (response.statusCode == 200) {
      isEnterPromoCode = false;
      Get.offAll(Navigation_Bar());
      if (response.body['message'] ==
          "Your package is already active, you cannot purchase another package.") {
        errorAlertToast(
            "Your package is already active, you cannot purchase another package."
                .tr);
      } else if (response.body['message'] == "Invalid promo code") {
        errorAlertToast("Invalid promo code".tr);
      }
      if (isEnterPromoCode) {
        errorAlertToast(
            "Promo add successfully.Please Wait for admin approval.".tr);
      } else if (type == "Other") {
        // errorAlertToast(
        //     "Promotion code applied successfully. Your subscription has started"
        //         .tr);
      } else {
        selectedValue == 'Yes'
            ? errorAlertToast("Promo Code Generate Successfully.".tr)
            : errorAlertToast(
                "Package buy successfully.Please Wait for admin approval.".tr);
      }
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
    }
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
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': "*",
          'Authorization': 'Bearer ${authCont.user?.accessToken}'
        },
        showdialog: true);
    if (response.statusCode == 200) {
      Get.back();
      errorAlertToast("Reporting List Successfully.".tr);
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
    }
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
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
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
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': "*",
          'Authorization': 'Bearer ${authCont.user?.accessToken}'
        },
        showdialog: false);
    if (response.statusCode == 200) {
      errorAlertToast("Add successfully".tr);
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
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
        errorAlertToast('Your package has expired'.tr);
      }
      if (response.body["listing_count"] != null &&
          response.body["listing_count"] > 1000) {
        // errorAlertToast('${response.body["message"]}');
        getAllPackages();
      }

      // }else if(response.body["data"]['status']=="pending"){
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
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
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
    }
  }

  Future<bool> deleteListing() async {
    Response response = await api.postWithForm(
        "api/deleteListing",
        {
          'listing_id': listingModel?.id,
        },
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': "*",
          'Authorization': 'Bearer ${authCont.user?.accessToken}'
        },
        showdialog: false);
    if (response.statusCode == 200) {
      errorAlertToast('Listing Delete Successfully'.tr);
      return true;
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
      return false;
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

      print("Deleting ${listingsToDelete.length} listings concurrently...");

      // Make ALL API calls concurrently for super fast deletion
      List<Future<bool>> futures = listingsToDelete.map((listing) async {
        try {
          if (listing.id == null) {
            print("Skipping listing with null id");
            return false;
          }

          Response response = await api.postWithForm(
              "api/deleteListing",
              {
                'listing_id': listing.id,
              },
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'Accept': 'application/json',
                'Access-Control-Allow-Origin': "*",
                'Authorization': 'Bearer ${authCont.user?.accessToken}'
              },
              showdialog: false);

          if (response.statusCode == 200) {
            print("Successfully deleted listing ${listing.id}");
            return true;
          } else {
            print(
                "Failed to delete listing ${listing.id}: ${response.statusCode}");
            return false;
          }
        } catch (e) {
          print("Error deleting listing ${listing.id}: $e");
          return false;
        }
      }).toList();

      // Wait for ALL requests to complete simultaneously
      List<bool> results = await Future.wait(futures);
      int successCount = results.where((success) => success).length;

      // Remove successfully deleted listings from local list
      if (successCount > 0) {
        userListingModelList.removeWhere(
            (listing) => listing.businessStatus == currentAccountType);

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

      print("Deleted $successCount out of ${listingsToDelete.length} listings");
      return successCount > 0; // Return true if at least one was deleted
    } catch (e) {
      print("Error deleting all listings: $e");
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
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': "*",
          'Authorization': 'Bearer ${authCont.user?.accessToken}'
        },
        showdialog: true);
    if (response.statusCode == 200) {
      Get.offAll(Navigation_Bar());
      errorAlertToast('Mark a Sold Successfully'.tr);
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
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
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>$data");
    final SharedPreferences prefss = await SharedPreferences.getInstance();
    prefss.setString('listing_data', jsonEncode(data));
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Navigation_Bar(),
        ));
    print("hhhhhh");
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
    print(jsonEncode(listingModel));
  }

  Future addListing(BuildContext context) async {
    String tagsData = "";
    String price = "0";
    String rawPrice = priceCont?.text.replaceAll(' ', '') ?? "0";
    (priceCont != null && priceCont!.text.isEmpty)
        ? price = "0"
        : price = rawPrice;
    print("price...$price");
    print("currency...$selectedCurrency");
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

    print('isBusinessAccount:${authCont.isBusinessAccount}');
    print('postImages:$postImages');
    Response response = await api.postWithForm(
        "api/addListing",
        {
          'category_id': selectedCategory?.id,
          'sub_category_id': selectedSubCategory?.id ?? "",
          'sub_sub_category_id': selectedSubSubCategory?.id ?? "",
          'price': price,
          'currency': selectedCurrency ?? 'USD',
          'business_status': authCont.isBusinessAccount ? 1 : 0,
          'title': titleCont.text.trim(),
          'latitude': lat ?? lat1,
          'longitude': lng ?? lng1,
          'address': addressCont.text.trim(),
          'description': descriptionCont.text.trim(),
          'additional_features': jsonEncode(optionalInformation),
          'tag': tagsData,
        },
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': "*",
          'Authorization': 'Bearer ${authCont.user?.accessToken}'
        },
        imageKey: "gallery[]",
        image: postImages,
        showdialog: true);

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
        selectedCategory = null;
        selectedSubCategory = null;
        selectedSubSubCategory = null;
        selectedCurrency = 'USD';
        authCont.currentIndexBottomAppBar = 3;

        // Refresh listings data after successful post creation
        status = "active";
        soldStatus = null;

        Get.offAll(Navigation_Bar());
        errorAlertToast('Post Add Successfully'.tr);
      }
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
    }
  }

  Future editListing(BuildContext context) async {
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
    print(selectedSubCategory?.id);
    print(selectedSubSubCategory?.id);
    // Remove spaces from price
    String rawPrice = priceCont?.text.replaceAll(' ', '') ?? "0";
    Response response = await api.postWithForm(
        "api/editListing",
        {
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
        },
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': "*",
          'Authorization': 'Bearer ${authCont.user?.accessToken}'
        },
        imageKey: "gallery[]",
        image: postImages,
        showdialog: true);
    if (response.statusCode == 200) {
      priceCont?.clear();
      titleCont.clear();
      addressCont.clear();
      descriptionCont.clear();
      tagsController.clear();
      selectedCategory = null;
      selectedSubCategory = null;
      selectedCurrency = 'USD';
      selectedSubSubCategory = null;

      // Refresh listings data after successful post edit
      status = "active";
      soldStatus = null;

      Get.offAll(Navigation_Bar());
      errorAlertToast('Post Add Successfully'.tr);
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
    }
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
      List<geo.Location> locations =
          await geocoding!.locationFromAddress(latestAddress);
      if (locations.isNotEmpty) {
        geo.Location location = locations[0];
        lat = location.latitude.toString();
        lng = location.longitude.toString();
        Get.log("Geocoded coordinates: $lat, $lng, radius: $radius");
      } else {
        Get.log("No coordinates found for address: $latestAddress",
            isError: true);
        errorAlertToast(
            'Unable to fetch location. Using default coordinates.'.tr);
        lat = "23.124792615936276"; // Fallback default
        lng = "-82.38597269330762";
      }
    } catch (e, stackTrace) {
      Get.log("Error in getCoordinatesFromAddress: $e\n$stackTrace",
          isError: true);
      errorAlertToast(
          'Failed to get coordinates. Using default coordinates.'.tr);
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
    print(sellerId);
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
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
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
      print(data);
    } else {
      String data = await response.stream.bytesToString();
      print(data);
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
      print(response.reasonPhrase);
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
        print('Page $currentPage: ${dataListing.length} items');

        for (var element in dataListing) {
          userFavouriteListingModelList.add(ListingModel.fromJson(element));
        }

        currentPage++;
        hasMore = currentPage <= (body['last_page'] ?? 1);
      } else {
        errorAlertToast('Something went wrong\nPlease try again!');
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
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
    }
  }

  int personalAcountPost = 0;
  int bussinessPostCount = 0;

  // Add a flag to prevent concurrent calls
  bool _isLoadingListings = false;

  Future getSellerListingByStatus() async {
    // Prevent concurrent calls
    if (_isLoadingListings) {
      print('getSellerListingByStatus already in progress, skipping...');
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

      print('🔥 Calling getSellerListingByStatus API with data: $data');

      Response response = await api.postWithForm(
          "api/getSellerListingByStatus",
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
            'Access-Control-Allow-Origin': "*",
            'Authorization': 'Bearer ${authCont.user?.accessToken}'
          },
          data,
          showdialog: false);

      if (response.statusCode == 200) {
        List<dynamic> dataListing = [];
        dataListing.addAll(response.body['data']);
        print('🔥 API Response: ${dataListing.length} listings received');

        // Clear the list before adding new data
        userListingModelList.clear();

        // Reset counters again to ensure clean state
        int tempBusinessCount = 0;
        int tempPersonalCount = 0;

        // Process each listing
        dataListing.forEach((element) {
          print('dataListing business_status${element["business_status"]}');

          ListingModel listing = ListingModel.fromJson(element);
          userListingModelList.add(listing);

          // Count listings by business status
          if (element["business_status"] == "1") {
            tempBusinessCount++;
            print('dataListing bussinessPostCount ++"${tempBusinessCount}');
          } else if (element["business_status"] == "0") {
            tempPersonalCount++;
            print('dataListing personalAcountPost ++"${tempPersonalCount}');
          }
        });

        // Update the actual counters only after processing all listings
        bussinessPostCount = tempBusinessCount;
        personalAcountPost = tempPersonalCount;

        print(
            '🔥 Final counts - Total listings: ${userListingModelList.length}');
        print('🔥 Final counts - Business: ${bussinessPostCount}');
        print('🔥 Final counts - Personal: ${personalAcountPost}');

        listingLoading = false;
        update();
      } else {
        errorAlertToast('Something went wrong\nPlease try again!'.tr);
      }
    } catch (e) {
      print('🔥 Error in getSellerListingByStatus: $e');
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
    } finally {
      _isLoadingListings = false;
    }
  }

// Define separate pagination variables for search
  var currentSearchPage = 1.obs;
  var hasMoreSearch = true.obs;
  var isSearchLoading = false.obs;

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

      // When subcategory is selected (but not sub-subcategory), we need to get all posts
      // under the category so client-side filtering can include sub-subcategory posts
      Map<String, dynamic> requestData = {
        'user_id': authCont.user?.userId ?? "",
        'category_id': selectedCategory?.id ?? "",
        // For subcategory filtering, don't send sub_category_id to server
        // Let client-side filtering handle subcategory + sub-subcategory logic
        'sub_category_id':
            selectedSubSubCategory != null ? selectedSubCategory?.id ?? "" : "",
        'sub_sub_category_id': selectedSubSubCategory?.id ?? "",
        'latitude': lat ?? "23.124792615936276",
        'longitude': lng ?? "-82.38597269330762",
        'radius': radius.toString(),
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

      Response response = await api.postWithForm(
        "api/getListing?page=${currentSearchPage.value}",
        requestData,
        showdialog: false,
      );

      Get.log("Response Status: ${response.statusCode}");
      Get.log("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> dataListing = response.body['data']['data'] ?? [];
        Get.log("=== SEARCH RESPONSE DEBUG ===");
        Get.log("API returned ${dataListing.length} items");

        if (dataListing.isNotEmpty) {
          List<ListingModel> newListings =
              dataListing.map((e) => ListingModel.fromJson(e)).toList();

          // Debug: Log first few items to verify category filtering
          for (int i = 0;
              i < (newListings.length > 3 ? 3 : newListings.length);
              i++) {
            Get.log(
                "Item ${i + 1}: '${newListings[i].title}' - Category: ${newListings[i].category?.name} (ID: ${newListings[i].category?.id})");
          }

          // Apply client-side price filtering
          newListings = applyPriceFilter(newListings);
          Get.log("After price filtering: ${newListings.length} items");

          // Apply client-side category filtering as backup
          newListings = applyCategoryFilter(newListings);
          Get.log("After category filtering: ${newListings.length} items");

          listingModelSearchList.addAll(newListings);
          currentSearchPage.value++; // Increment page correctly
          hasMoreSearch.value =
              dataListing.length == 15; // More pages available?
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
        errorAlertToast('Something went wrong\nPlease try again!'.tr);
      }
    } catch (e, stackTrace) {
      Get.log("Error in getListingSearch: $e\n$stackTrace", isError: true);
      errorAlertToast('Something went wrong. Please try again.'.tr);
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

  // Future getListingSearch({bool isLoadingShow = true}) async {
  //   print(searchLongitude);
  //   Response response = await api.postWithForm(
  //       "api/getListing",
  //       {
  //         'user_id': authCont.user?.userId ?? "",
  //         'category_id': selectedCategory?.id ?? "",
  //         'sub_category_id': selectedSubCategory?.id ?? "",
  //         'sub_sub_category_id': selectedSubSubCategory?.id ?? "",
  //         'min_price': minPriceController.text.trim(),
  //         'max_price': maxPriceController.text.trim(),
  //         'search_by_title': searchController.text.trim(),
  //         // 'latitude': searchLatitude,
  //         // 'longitude': searchLongitude,
  //         // 'radius': "$radius",
  //       },
  //       showdialog: isLoadingShow);
  //   if (response.statusCode == 200) {
  //     List<dynamic> dataListing = [];
  //     dataListing.addAll(response.body['data']['data']);
  //     listingModelSearchList.clear();
  //     String isBusinessType = isBusinessAccount ? "1" : "0";
  //     dataListing.forEach((element) {
  //       //    if (element["business_status"].toString() == isBusinessType) {
  //       listingModelSearchList.add(ListingModel.fromJson(element));
  //       //  }
  //     });
  //     update();
  //   } else {
  //     errorAlertToast('Something went wrong\nPlease try again!'.tr);
  //   }
  // }

  Future getListingDetails(String listingId, {bool showDialog = true}) async {
    Response response = await api.postWithForm(
        "api/getListingDetails",
        {
          'listing_id': listingId,
          'user_id': authCont.user?.userId,
        },
        showdialog: showDialog);
    if (response.statusCode == 200) {
      isListing = 0;
      listingModel = ListingModel.fromJson(response.body["data"]);

      // Cross-check and update isSellerFavorite with local favorite sellers list
      _updateSellerFavoriteStatus();

      update(); // Ensure UI updates when listing details are fetched
      if (showDialog) {
        Get.to(FrameScreen());
      }
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
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
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
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

      print("Synced favorite status for item $itemId to $newFavoriteStatus");
    } catch (e) {
      print("Error syncing favorite status: $e");
    }
  }

  /// Helper method to sync favorite status in favorites list when changed from home screen
  void syncFavoriteStatusInFavoritesList(
      String itemId, String newFavoriteStatus) {
    try {
      if (newFavoriteStatus == "0") {
        // Remove from favorites list if unfavorited
        userFavouriteListingModelList
            .removeWhere((item) => item.itemId == itemId);
        print("Removed item $itemId from favorites list");
      } else {
        // If favorited, we don't need to add it here as it will be fetched next time
        // the favorites screen is opened
        print(
            "Item $itemId favorited - will be available in next favorites refresh");
      }
    } catch (e) {
      print("Error syncing favorite status in favorites list: $e");
    }
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
      } else {
        print("Warning: Item $itemId not found in main listing list for sync");
      }

      // Force update all GetBuilder widgets
      update();

      // Also trigger update on the next frame to ensure UI rebuilds
      WidgetsBinding.instance.addPostFrameCallback((_) {
        update();
      });

      // Force update using GetX's global update mechanism
      Get.forceAppUpdate();
    } catch (e) {
      print("Error syncing favorite status in home screen: $e");
    }
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
    } catch (e) {
      print("Error syncing seller favorite status in home screen: $e");
    }
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
    } catch (e) {
      print("Error syncing multiple favorite status in home screen: $e");
    }
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
    } catch (e) {
      print("Error syncing multiple seller favorite status in home screen: $e");
    }
  }

  Future<bool> favouriteSeller() async {
    print("'seller_id': $sellerId,");
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
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
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

      print("Removing ${itemIds.length} favourite listings concurrently...");

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
            print("Successfully removed listing $itemId");
            return true;
          } else {
            print("Failed to remove listing $itemId: ${response.statusCode}");
            return false;
          }
        } catch (e) {
          print("Error removing listing $itemId: $e");
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

      print("Removed $successCount out of ${itemIds.length} listings");
      return successCount > 0; // Return true if at least one was removed
    } catch (e) {
      print("Error removing all favourite listings: $e");
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

      print("Removing ${sellerIds.length} favourite sellers concurrently...");

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
            print("Successfully removed seller $sellerIdToRemove");
            return true;
          } else {
            print(
                "Failed to remove seller $sellerIdToRemove: ${response.statusCode}");
            return false;
          }
        } catch (e) {
          print("Error removing seller $sellerIdToRemove: $e");
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

      print("Removed $successCount out of ${sellerIds.length} sellers");
      return successCount > 0; // Return true if at least one was removed
    } catch (e) {
      print("Error removing all favourite sellers: $e");
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
      print("Removed seller $sellerId from local favorites list");

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
        print("Refreshed favorite sellers list");
      }
    } catch (e) {
      print("Error refreshing favorite sellers list: $e");
    }
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
      print("Error loading favorite sellers list silently: $e");
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
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
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
                      Get.back(),
                    }
                  else
                    {update()}
                };
        }
      } else {
        errorAlertToast('Something went wrong\nPlease try again!'.tr);
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
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
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
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
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
      currentPage.value = 1;
      hasMore.value = true;
      listingModelList.clear();
      currentSearchPage.value = 1;
      listingModelSearchList.clear();
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
                            Get.back(),
                            getListingSearch()
                          }
                        : Get.back()
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
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
    }
  }

  Future<void> getLatLong(String city, String province) async {
    try {
      String address = '$city, $province';
      List<geo.Location> locations = await geo.locationFromAddress(address);

      if (locations.isNotEmpty) {
        geo.Location location = locations.first;
        Get.log(
            'Latitude: ${location.latitude}, Longitude: ${location.longitude}');
        lat1 = "${location.latitude}";
        lng1 = "${location.longitude}";
        lat = "${location.latitude}";
        lng = "${location.longitude}";
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }
}


// {"status":false,"errors":"Sending credit card numbers directly to the Stripe API is generally unsafe. We suggest you use test tokens that map to the test card you are using, see https:\/\/stripe.com\/docs\/testing. To enable testing raw card data APIs, see https:\/\/support.stripe.com\/questions\/enabling-access-to-raw-card-data-apis."}
// flutter: {status: false, errors: Sending credit card numbers directly to the Stripe API is generally unsafe. We suggest you use test tokens that map to the test card you are using, see https://stripe.com/docs/testing. To enable testing raw card data APIs, see https://support.stripe.com/questions/enabling-access-to-raw-card-data-apis.}