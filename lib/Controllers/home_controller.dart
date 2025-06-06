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
import '../Models/AllNotificationModel.dart';
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
import '../view/notification/notification.dart';
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
  String? selectedCurrency = 'USD'; // Default currency
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
  String? status = 'active';
  String? soldStatus;
  String? listingId;
  String? sellerId;
  int isListing = 1;
  bool listingLoading = true;
  FavouriteSellerModel favouriteSellerModel = FavouriteSellerModel();
  AllPackagesModel? allPackagesModel;
  SellerDetailsModel? sellerDetailsModel;
  int? notificationId;
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
  UserData? userData;
  String? searchLatitude;
  String? searchLongitude;
  ScrollController scrollsController = ScrollController();
  ScrollController searchScrollController = ScrollController();

  RxInt currentPage = 1.obs;
  RxBool hasMore = true.obs;

  homeData() async {
    loadingHome = true.obs;
    // Ensure the listener is added only once
    scrollsController.addListener(onScroll);
    searchScrollController.addListener(onScrollSearch);

    currentPage.value = 1; // Reset pagination state BEFORE fetching data
    hasMore.value = true;
    await getCategories();
    await getListing();

    loadingHome = false.obs;
    update();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    //  currentPage.value = 1;
    // scrollsController.addListener(onScroll);
    fetchAccountType();
    super.onInit();
  }

  @override
  void onClose() {
    scrollsController.removeListener(onScroll);
    scrollsController.dispose();
    super.onClose();
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
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    isBusinessAccount = sharedPreferences.getBool("accountType") ?? false;
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

  AllNotificationModel? allNotificationModel;

  Future getAllNotifications() async {
    Response response = await api.postWithForm("api/getAllNotifications", {},
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': "*",
          'Authorization': 'Bearer ${authCont.user?.accessToken}'
        },
        showdialog: true);
    if (response.statusCode == 200) {
      allNotificationModel = AllNotificationModel.fromJson(response.body);
      Get.to(NotificationScreen());
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
    }
  }

  Future<bool> deleteNotification() async {
    Response response = await api.postWithForm(
        "api/deleteNotification",
        {
          'notification_id': notificationId,
        },
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': "*",
          'Authorization': 'Bearer ${authCont.user?.accessToken}'
        },
        showdialog: false);
    if (response.statusCode == 200) {
      errorAlertToast('Notification Delete Successfully'.tr);
      return true;
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
      return false;
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

  Future readNotification() async {
    Response response = await api.postWithForm(
        "api/readNotification",
        {
          'notification_id': notificationId,
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
      errorAlertToast('Notification Delete Successfully'.tr);
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
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

    bool isBusinessAccount = false;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    isBusinessAccount = sharedPreferences.getBool("accountType") ?? false;
    Response response = await api.postWithForm(
        "api/addListing",
        {
          'category_id': selectedCategory?.id,
          'sub_category_id': selectedSubCategory?.id ?? "",
          'sub_sub_category_id': selectedSubSubCategory?.id ?? "",
          'price': price,
          'currency': selectedCurrency ?? 'USD',
          'business_status': isBusinessAccount ? 1 : 0,
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
    bool isBusinessAccount = false;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    isBusinessAccount = sharedPreferences.getBool("accountType") ?? false;
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
          'business_status': isBusinessAccount ? 1 : 0,
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
      Get.offAll(Navigation_Bar());
      errorAlertToast('Post Add Successfully'.tr);
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
    }
  }

  getCoordinatesFromAddress() async {
    final locationCont = Get.put(LocationController());
    if (locationCont.lat != null && locationCont.lng != null) {
      lat = locationCont.lat.toString();
      lng = locationCont.lng.toString();
      Get.log(lat.toString());
      Get.log(lng.toString());
      Get.log(radius.toString());
      return;
    }
    String latestAddress = 'Habana, Cuba';
    if (address != null && address!.isNotEmpty) {
      latestAddress = address!;
    } else if (authCont.user?.city != null) {
      Get.log("user city: ${authCont.user?.city}");
      Get.log("user state: ${authCont.user?.province}");
      latestAddress = '${authCont.user?.city}, Cuba';
    }
    List<geo.Location> locations =
        await geocoding!.locationFromAddress(latestAddress);

    if (locations.isNotEmpty) {
      geo.Location location = locations[0];
      lat = location.latitude.toString();
      lng = location.longitude.toString();
      Get.log(lat.toString());
      Get.log(lng.toString());
      Get.log(radius.toString());
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

  void onScroll() async {
    if (scrollsController.position.pixels >=
        scrollsController.position.maxScrollExtent - 100) {
      if (!isPostLoading.value && hasMore.value) {
        isPostLoading.value = true; // Lock API call
        update();

        Get.log("Fetching feeds...");
        await getListing(isLoadMore: true);
      }
    }
  }

  void onScrollSearch() async {
    if (searchScrollController.position.pixels >=
        searchScrollController.position.maxScrollExtent - 100) {
      if (!isSearchLoading.value && hasMoreSearch.value) {
        isSearchLoading.value = true; // Lock API call
        update();

        Get.log("Fetching search results...");
        await getListingSearch(isLoadMore: true);
      }
    }
  }

  Future<void> getListing({bool isLoadMore = false}) async {
    // if (isPostLoading.value) return;
    await getCoordinatesFromAddress();
    isPostLoading.value = true;
    // selectedCategory = null;
    //     selectedSubCategory = null;
    //     selectedSubSubCategory = null;
    update();

    if (!isLoadMore) {
      currentPage.value = 1;
      listingModelList.clear();
      hasMore.value = true; // Reset hasMore when fetching fresh data
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
        'sub_category_id': selectedSubCategory?.id ?? "",
        'sub_sub_category_id': selectedSubSubCategory?.id ?? "",
        'latitude': lat,
        'longitude': lng,
        'radius': radius ?? "500",
        'min_price': '',
        'max_price': '',
        'search_by_title': ''
      },
      showdialog: false,
    );

    if (response.statusCode == 200) {
      List<dynamic> dataListing = response.body['data']['data'];
      Get.log("HOME POST COUNT ${dataListing.length}");

      if (dataListing.isNotEmpty) {
        listingModelList
            .addAll(dataListing.map((e) => ListingModel.fromJson(e)));
        currentPage.value++; // Increment page correctly
        hasMore.value = dataListing.length == 15; // More pages available?
      } else {
        hasMore.value = false;
      }
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
    }

    isPostLoading.value = false;
    update();
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
    Response response = await api.postWithForm("api/getFavouriteItems", {},
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': "*",
          'Authorization': 'Bearer ${authCont.user?.accessToken}'
        },
        showdialog: true);
    if (response.statusCode == 200) {
      List<dynamic> dataListing = [];
      dataListing.addAll(response.body['data']['data']);
      String isBusinessType = isBusinessAccount ? "1" : "0";
      userFavouriteListingModelList.clear();
      dataListing.forEach((element) {
        if (element["business_status"].toString() == isBusinessType) {
          userFavouriteListingModelList.add(ListingModel.fromJson(element));
        }
      });
      Get.to(FavouriteListings());
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
    }
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

  RxInt personalAcountPost = 0.obs;
  RxInt bussinessPostCount = 0.obs;

  Future getSellerListingByStatus() async {
    personalAcountPost.value = 0;
    bussinessPostCount.value = 0;

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
      userListingModelList.clear();
      dataListing.forEach((element) {
        if (element["business_status"] == 1) {
          bussinessPostCount.value++;
        } else {
          personalAcountPost.value++;
        }
        userListingModelList.add(ListingModel.fromJson(element));
      });
      listingLoading = false;
      update();
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
    }
  }

// Define separate pagination variables for search
  var currentSearchPage = 1.obs;
  var hasMoreSearch = true.obs;
  var isSearchLoading = false.obs;

  Future<void> getListingSearch({bool isLoadMore = false}) async {
    // if (isSearchLoading.value) return;

    isSearchLoading.value = true;
    update();

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

    Response response = await api.postWithForm(
      "api/getListing?page=${currentSearchPage.value}",
      {
        'user_id': authCont.user?.userId ?? "",
        'category_id': selectedCategory?.id ?? "",
        'sub_category_id': selectedSubCategory?.id ?? "",
        'sub_sub_category_id': selectedSubSubCategory?.id ?? "",
        'min_price': minPriceController.text.trim(),
        'max_price': maxPriceController.text.trim(),
        'search_by_title': searchController.text.trim(),
      },
      showdialog: false,
    );

    if (response.statusCode == 200) {
      List<dynamic> dataListing = response.body['data']['data'];
      Get.log("SEARCH LIST COUNT ${dataListing.length}");

      if (dataListing.isNotEmpty) {
        listingModelSearchList
            .addAll(dataListing.map((e) => ListingModel.fromJson(e)));
        currentSearchPage.value++; // Increment page correctly
        hasMoreSearch.value = dataListing.length == 15; // More pages available?
        listingModelList = listingModelSearchList;
        update();
      } else {
        hasMoreSearch.value = false;
      }
    } else {
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
    }

    isSearchLoading.value = false;
    update();
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

  Future getListingDetails(String listingId) async {
    print(searchLongitude);
    Response response = await api.postWithForm(
        "api/getListingDetails",
        {
          'listing_id': listingId,
          'user_id': authCont.user?.userId,
        },
        showdialog: true);
    if (response.statusCode == 200) {
      isListing = 0;
      listingModel = ListingModel.fromJson(response.body["data"]);
      Get.to(FrameScreen());
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

  Future<bool> favouriteSeller() async {
    print("'seller_id': $sellerId,");
    Response response = await api.postWithForm(
        "api/favouriteSeller",
        {
          'seller_id': sellerId,
          'type': isBusinessAccount ? "Business" : "Personal"
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
      errorAlertToast('Something went wrong\nPlease try again!'.tr);
      return false;
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
        isNavigate
            ? {
                // getListing(),
                Get.to(CategoryFrom()),
                // ?.then((value) {
                // selectedCategory = null;
                selectedSubCategory = null,
                selectedSubSubCategory = null,

                // getListing();
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

  Future getSubSubCategoriesBottom() async {
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
      isNavigate
          ? {
              getListingSearch(),
              Get.to(SubSubCategories()),
            }
          : {
              if (subSubCategoriesModel?.data?.isEmpty ?? false)
                {
                  selectedSubSubCategory = null,
                  isSearchScreen ? {Get.back(), getListingSearch()} : Get.back()
                }
              else
                {getListingSearch(), update()}
            };
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