import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as map;

import 'package:lottie/lottie.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:venta_cuba/view/Chat/custom_text.dart';
import 'package:venta_cuba/view/Navigation%20bar/post.dart';
import 'package:venta_cuba/view/constants/premium_animations.dart';

import 'package:venta_cuba/view/constants/Colors.dart';
import '../../Controllers/auth_controller.dart';
import '../../Controllers/home_controller.dart';
import '../../Utils/funcations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../util/my_button.dart';
import '../Chat/pages/chat_page.dart';
import '../RattingScreen/rattingScreen.dart';
import '../auth/login.dart';

class FrameScreen extends StatefulWidget {
  const FrameScreen({super.key});

  @override
  State<FrameScreen> createState() => _FrameScreenState();
}

class _FrameScreenState extends State<FrameScreen> {
  final authCont = Get.put(AuthController());
  final homeCont = Get.put(HomeController());

  Future<void> _launchUrl(String uri) async {
    final Uri _url = Uri.parse(uri);
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

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

  /// Helper function to check if an optional detail value is valid and not null/empty
  bool _isValidOptionalDetail(String? value) {
    return value != null && value != 'null' && value.trim().isNotEmpty;
  }

  @override
  void initState() {
    print(
        "object.........>>>>>>>>>>>>>....${jsonEncode(homeCont.listingModel)}");
    homeCont.sellerId = homeCont.listingModel?.user?.id.toString();
    homeCont.checkUserPackage();

    // Update seller favorite status when frame screen is opened
    // This ensures the heart icon shows the correct state even when coming from favorite listings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSellerFavoriteStatus();
      // Fetch fresh seller details to get updated profile image
      _fetchLatestSellerDetails();
    });

    // center =
    //     map.LatLng(double.parse(home.listingModel!.latitude!), double.parse(home.listingModel!.longitude!));
    super.initState();
  }

  /// Update seller favorite status based on the current favorite sellers list
  void _updateSellerFavoriteStatus() {
    if (homeCont.listingModel?.user?.id != null) {
      String currentSellerId = homeCont.listingModel!.user!.id.toString();
      bool isInFavorites = homeCont.favouriteSellerModel.data
              ?.any((seller) => seller.sellerId == currentSellerId) ??
          false;

      // Update the isSellerFavorite field to match the actual favorite status
      homeCont.listingModel!.isSellerFavorite = isInFavorites ? "1" : "0";

      print(
          "Frame: Updated isSellerFavorite for seller $currentSellerId: ${homeCont.listingModel!.isSellerFavorite}");
      homeCont.update();
    }
  }

  /// Fetch latest seller details to get updated profile image
  void _fetchLatestSellerDetails() async {
    if (homeCont.listingModel?.user?.id != null) {
      homeCont.sellerId = homeCont.listingModel!.user!.id.toString();
      await homeCont.getSellerDetails(
        homeCont.listingModel?.businessStatus ?? "0",
        0,
        false, // Don't navigate, just fetch data
      );
    }
  }

  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl));
    } else {
      print("Could not open the map.");
      throw 'Could not open the map.';
    }
  }

  late map.GoogleMapController mapController;
  bool _isMapLoading = true;
  int _currentImageIndex = 0;
  PageController _pageController = PageController();
  // San Francisco Coordinates

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onMapCreated(map.GoogleMapController controller) {
    try {
      print("🔥 🗺️ Google Maps controller created successfully!");
      mapController = controller;
      setState(() {
        _isMapLoading = false;
      });
    } catch (e) {
      print("🔥 ❌ ERROR creating Google Maps controller: $e");
      setState(() {
        _isMapLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GetBuilder<HomeController>(
        builder: (cont) {
          // Check if listingModel is null and show loading or error state
          if (cont.listingModel == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Loading listing details...'),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final String day = cont.listingModel!.updatedAt != null
              ? cont.format(DateTime.parse(cont.listingModel!.updatedAt!))
              : cont.format(DateTime.now());
          cont.noOfDays(cont.listingModel?.updatedAt);
          return SelectionArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: 400.h,
                        width: MediaQuery.of(context).size.width,
                        child: Stack(
                          children: [
                            // Image Carousel with PageView
                            PageView.builder(
                              itemCount:
                                  cont.listingModel!.gallery?.length ?? 0,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FullScreenCarousel(
                                          images: cont.listingModel!.gallery!,
                                          initialIndex: index,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: cont.listingModel!.gallery![index],
                                    child: Image.network(
                                      cont.listingModel!.gallery![index],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Image Counter Badge - Bottom Right
                            if (cont.listingModel!.gallery != null &&
                                cont.listingModel!.gallery!.length > 1)
                              Positioned(
                                bottom: 20,
                                right: 20,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${_currentImageIndex + 1}/${cont.listingModel!.gallery!.length}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 5.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "${day} | ${cont.setDaysAgo(cont.listingModel!.updatedAt)}",
                                    style: TextStyle(
                                        fontSize: 16..sp,
                                        fontWeight: FontWeight.w400,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "${cont.listingModel?.title}",
                              // '${cont.listingModel?.user?.firstName} ${cont.listingModel?.user?.lastName}',
                              style: TextStyle(
                                  fontSize: 20..sp,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.color),
                            ),
                            Text(
                              cont.listingModel!.price == "0"
                                  ? ""
                                  : "${PriceFormatter().formatNumber(int.parse(cont.listingModel!.price ?? '0'))}\$ ${PriceFormatter().getCurrency(cont.listingModel!.currency)}",
                              style: TextStyle(
                                  fontSize: 20..sp,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.color),
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    cont.listingModel!.title!,
                                    // '${cont.listingModel?.user?.firstName} ${cont.listingModel?.user?.lastName}',
                                    style: TextStyle(
                                        fontSize: 26..sp,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.color),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 9..h),
                            Text(
                              'Description'.tr,
                              style: TextStyle(
                                  fontSize: 18..sp,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.color),
                            ),
                            SizedBox(height: 10..h),
                            Text(
                              '${cont.listingModel?.description}',
                              style: TextStyle(
                                  fontSize: 15..sp,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color),
                            ),
                            SizedBox(height: 10..h),
                            Visibility(
                              visible:
                                  cont.listingModel?.additionalFeatures?.type ==
                                          "Cars & Bikes"
                                      ? true
                                      : false,
                              child: Column(
                                children: [
                                  Text(
                                    '${cont.listingModel?.additionalFeatures?.listingDetails?.make}',
                                    style: TextStyle(
                                        fontSize: 18..sp,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.color),
                                  ),
                                  SizedBox(
                                    height: 20..h,
                                  ),
                                  Text(
                                    '${cont.listingModel?.additionalFeatures?.listingDetails?.model}',
                                    style: TextStyle(
                                        fontSize: 15..sp,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.k0xFFA9ABAC),
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible:
                                  cont.listingModel?.additionalFeatures?.type ==
                                          "Real Estate"
                                      ? true
                                      : false,
                              child: Column(
                                children: [
                                  Text(
                                    'Furnished'.tr,
                                    style: TextStyle(
                                        fontSize: 18..sp,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.color),
                                  ),
                                  Text(
                                    '${cont.listingModel?.additionalFeatures?.listingDetails?.furnished}',
                                    style: TextStyle(
                                        fontSize: 15..sp,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.k0xFFA9ABAC),
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible:
                                  cont.listingModel?.additionalFeatures?.type ==
                                          "Services"
                                      ? true
                                      : false,
                              child: Column(
                                children: [
                                  Text(
                                    "Job Type".tr,
                                    style: TextStyle(
                                        fontSize: 18..sp,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.color),
                                  ),
                                  SizedBox(
                                    height: 20..h,
                                  ),
                                  Text(
                                    '${cont.listingModel?.additionalFeatures?.listingDetails?.jobType}',
                                    style: TextStyle(
                                        fontSize: 15..sp,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.k0xFFA9ABAC),
                                  ),
                                ],
                              ),
                            ),
                            Divider(),
                            Text(
                              'Tags'.tr,
                              style: TextStyle(
                                  fontSize: 18..sp,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.color),
                            ),
                            SizedBox(height: 10..h),
                            SizedBox(
                              height: 40.h,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: cont.listingModel?.tag?.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.only(right: 10.0.w),
                                    child: Container(
                                      height: 40.h,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .dividerColor)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                            child: Text(cont.listingModel
                                                    ?.tag?[index] ??
                                                "")),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 10..h),
                            Divider(),
                            Text(
                              'Optional Details'.tr,
                              style: TextStyle(
                                  fontSize: 18..sp,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.color),
                            ),
                            SizedBox(height: 10..h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Website'.tr,
                                  style: TextStyle(
                                      fontSize: 15..sp,
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color),
                                ),
                                if (_isValidOptionalDetail(cont
                                    .listingModel
                                    ?.additionalFeatures
                                    ?.optionalDetails
                                    ?.website))
                                  Text(
                                    '${cont.listingModel?.additionalFeatures?.optionalDetails?.website}',
                                    style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w400,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color),
                                  ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Phone Number'.tr,
                                  style: TextStyle(
                                      fontSize: 15..sp,
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color),
                                ),
                                if (_isValidOptionalDetail(cont
                                    .listingModel
                                    ?.additionalFeatures
                                    ?.optionalDetails
                                    ?.phoneNumber))
                                  Text(
                                    '${cont.listingModel?.additionalFeatures?.optionalDetails?.phoneNumber}',
                                    style: TextStyle(
                                        fontSize: 15..sp,
                                        fontWeight: FontWeight.w400,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color),
                                  ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Condition'.tr,
                                  style: TextStyle(
                                      fontSize: 15..sp,
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color),
                                ),
                                if (_isValidOptionalDetail(cont
                                    .listingModel
                                    ?.additionalFeatures
                                    ?.optionalDetails
                                    ?.condition))
                                  Text(
                                    '${cont.listingModel?.additionalFeatures?.optionalDetails?.condition}',
                                    style: TextStyle(
                                        fontSize: 15..sp,
                                        fontWeight: FontWeight.w400,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color),
                                  ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Fulfillment'.tr,
                                  style: TextStyle(
                                      fontSize: 15..sp,
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color),
                                ),
                                if (_isValidOptionalDetail(cont
                                    .listingModel
                                    ?.additionalFeatures
                                    ?.optionalDetails
                                    ?.fulfillment))
                                  Text(
                                    '${cont.listingModel?.additionalFeatures?.optionalDetails?.fulfillment}',
                                    style: TextStyle(
                                        fontSize: 15..sp,
                                        fontWeight: FontWeight.w400,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color),
                                  ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Payment'.tr,
                                  style: TextStyle(
                                      fontSize: 15..sp,
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color),
                                ),
                                if (_isValidOptionalDetail(cont
                                    .listingModel
                                    ?.additionalFeatures
                                    ?.optionalDetails
                                    ?.payment))
                                  Text(
                                    '${cont.listingModel?.additionalFeatures?.optionalDetails?.payment}',
                                    style: TextStyle(
                                        fontSize: 15..sp,
                                        fontWeight: FontWeight.w400,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color),
                                  ),
                              ],
                            ),
                            SizedBox(height: 9..h),
                            Divider(),
                            Text(
                              "Give rating".tr,
                              style: TextStyle(
                                  fontSize: 15..sp,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color),
                            ),
                            SizedBox(height: 9..h),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return RattingScreen();
                                        });
                                  },
                                  child: Row(
                                    children: _buildStarRating(double.parse(cont
                                                .listingModel?.averageRating
                                                .toString() ==
                                            "null"
                                        ? "0"
                                        : "${cont.listingModel?.averageRating}")),
                                  ),
                                ),
                                SizedBox(width: 8..w),
                                Text('${cont.listingModel?.averageRating}')
                              ],
                            ),
                            SizedBox(height: 10..h),
                            Divider(),
                            Text(
                              'Location'.tr,
                              style: TextStyle(
                                  fontSize: 18..sp,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.color),
                            ),
                            SizedBox(height: 10..h),
                            InkWell(
                              onTap: () => openMap(
                                  double.parse(
                                      homeCont.listingModel!.latitude!),
                                  double.parse(
                                      homeCont.listingModel!.longitude!)),
                              child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Theme.of(context).dividerColor)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 150,
                                      width: double.maxFinite,
                                      child: Stack(
                                        children: [
                                          map.GoogleMap(
                                            zoomControlsEnabled: false,
                                            myLocationButtonEnabled: false,
                                            rotateGesturesEnabled: false,
                                            scrollGesturesEnabled: false,
                                            zoomGesturesEnabled: false,
                                            onMapCreated: _onMapCreated,
                                            initialCameraPosition:
                                                map.CameraPosition(
                                              target: map.LatLng(
                                                  double.parse(homeCont
                                                              .listingModel
                                                              ?.latitude
                                                              .toString() ==
                                                          "null"
                                                      ? "0.0"
                                                      : homeCont.listingModel!
                                                          .latitude
                                                          .toString()),
                                                  double.parse(homeCont
                                                              .listingModel
                                                              ?.longitude
                                                              .toString() ==
                                                          'null'
                                                      ? "0.0"
                                                      : homeCont.listingModel!
                                                          .longitude
                                                          .toString())),
                                              zoom: 11.0,
                                            ),
                                            markers: {
                                              map.Marker(
                                                markerId: map.MarkerId("1"),
                                                position: map.LatLng(
                                                    double.parse(homeCont
                                                                .listingModel
                                                                ?.latitude
                                                                .toString() ==
                                                            "null"
                                                        ? "0.0"
                                                        : homeCont.listingModel!
                                                            .latitude
                                                            .toString()),
                                                    double.parse(homeCont
                                                                .listingModel
                                                                ?.longitude
                                                                .toString() ==
                                                            'null'
                                                        ? "0.0"
                                                        : homeCont.listingModel!
                                                            .longitude
                                                            .toString())),
                                                infoWindow: map.InfoWindow(
                                                  title: 'Marker Title',
                                                  snippet: 'Marker Snippet',
                                                ),
                                              ),
                                            },
                                          ),
                                          Center(
                                            child: Container(
                                              height: 100,
                                              width: 100,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color:
                                                          Colors.blueAccent)),
                                            ),
                                          ),
                                          if (_isMapLoading)
                                            Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${cont.listingModel?.address}',
                                      style: TextStyle(
                                          fontSize: 15..sp,
                                          fontWeight: FontWeight.w400,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Divider(),
                            SizedBox(
                              height: 20..h,
                            ),
                            Text(
                              'YouTube Video'.tr,
                              style: TextStyle(
                                  fontSize: 18..sp,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.color),
                            ),
                            SizedBox(
                              height: 10..h,
                            ),
                            InkWell(
                              onTap: () {
                                _launchUrl(cont.listingModel?.additionalFeatures
                                        ?.videoLink ??
                                    "");
                              },
                              child: Text(
                                '${cont.listingModel?.additionalFeatures?.videoLink}',
                                style: TextStyle(
                                    fontSize: 15..sp,
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color),
                              ),
                            ),
                            SizedBox(
                              height: 20..h,
                            ),
                            Divider(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(
                                      text: "About the seller".tr,
                                      fontSize: 20..sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        cont.sellerId = cont
                                            .listingModel?.user?.id
                                            .toString();
                                        await cont.getSellerDetails(
                                            cont.listingModel?.businessStatus ??
                                                "0",
                                            0,
                                            true);
                                      },
                                      child: CustomText(
                                        text: "View profile".tr,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        fontColor: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 40,
                                      width: 40,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(600.r),
                                        child: CachedNetworkImage(
                                          imageUrl: cont.listingModel
                                                      ?.businessStatus ==
                                                  "0"
                                              ? "${cont.sellerDetailsModel?.data?.sellerAbout?.profileImage ?? cont.listingModel?.user?.profileImage}"
                                              : "${cont.sellerDetailsModel?.data?.sellerAbout?.businessLogo ?? cont.listingModel?.user?.businessLogo}",
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            height: 40.h,
                                            width: 40.w,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          placeholder: (context, url) =>
                                              SizedBox(
                                                  height: 40.h,
                                                  width: 40.w,
                                                  child: Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ))),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20.w,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: cont.listingModel
                                                      ?.businessStatus ==
                                                  "0"
                                              ? "${cont.listingModel?.user?.firstName} ${cont.listingModel?.user?.lastName}"
                                              : cont.listingModel?.user
                                                      ?.businessName ??
                                                  "No business",
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18,
                                        ),
                                        Row(
                                          children: [
                                            Row(
                                              children: _buildStarRating(
                                                  double.parse(cont
                                                          .sellerDetailsModel
                                                          ?.data
                                                          ?.sellerAbout
                                                          ?.averageRating
                                                          .toString() ??
                                                      "0")),
                                            ),
                                            SizedBox(
                                              width: 8..w,
                                            ),
                                            Text(cont
                                                        .sellerDetailsModel
                                                        ?.data
                                                        ?.sellerAbout
                                                        ?.averageRating !=
                                                    null
                                                ? '${cont.sellerDetailsModel?.data?.sellerAbout?.averageRating.toString()}'
                                                : "0"),
                                            SizedBox(width: 3),
                                            Text(cont
                                                        .sellerDetailsModel
                                                        ?.data
                                                        ?.sellerRatings!
                                                        .length ==
                                                    null
                                                ? "(0)"
                                                : '(${cont.sellerDetailsModel?.data?.sellerRatings!.length})')
                                          ],
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    InkWell(
                                      onTap: () async {
                                        print(
                                            "object.............${cont.listingModel?.isSellerFavorite}");
                                        if (authCont.user?.email == "") {
                                          Navigator.push(
                                            context,
                                            PremiumPageTransitions
                                                .slideFromBottom(Login()),
                                          );
                                        } else {
                                          cont.listingModel?.isSellerFavorite ==
                                                  "0"
                                              ? cont.listingModel
                                                  ?.isSellerFavorite = "1"
                                              : cont.listingModel
                                                  ?.isSellerFavorite = "0";

                                          cont.isLoading = true;
                                          cont.update();
                                          bool isAddedF =
                                              await cont.favouriteSeller();
                                          cont.isLoading = false;
                                          cont.update();
                                          if (isAddedF) {
                                            print("Successfully".tr);
                                            print(
                                                "isSellerFavorite.............${cont.listingModel?.isSellerFavorite}");
                                            print(
                                                "object.............${jsonEncode(homeCont.listingModel)}");

                                            // Sync seller favorite status with home screen
                                            String sellerId = cont
                                                    .listingModel?.user?.id
                                                    .toString() ??
                                                "";
                                            String newStatus = cont.listingModel
                                                    ?.isSellerFavorite ??
                                                "0";
                                            cont.syncSellerFavoriteStatusInHomeScreen(
                                                sellerId, newStatus);
                                          } else {
                                            // Revert the UI change if the API call failed
                                            cont.listingModel
                                                        ?.isSellerFavorite ==
                                                    "0"
                                                ? cont.listingModel
                                                    ?.isSellerFavorite = "1"
                                                : cont.listingModel
                                                    ?.isSellerFavorite = "0";
                                          }
                                          cont.update();
                                        }
                                      },
                                      child: Container(
                                          height: 24..h,
                                          width: 24..w,
                                          child: cont.isLoading == true
                                              ? Lottie.asset(
                                                  'assets/images/h.json')
                                              : cont.listingModel
                                                          ?.isSellerFavorite ==
                                                      "1"
                                                  ? Icon(
                                                      Icons.favorite,
                                                      color: Colors.red,
                                                    )
                                                  : Icon(
                                                      Icons.favorite_border)),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15),
                                InkWell(
                                  onTap: () async {
                                    cont.sellerId =
                                        cont.listingModel?.user?.id.toString();
                                    await cont.getSellerDetails(
                                        cont.listingModel?.businessStatus ??
                                            "0",
                                        0,
                                        true);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color:
                                              Theme.of(context).dividerColor),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText(
                                            text: "View seller's other listing"
                                                .tr),
                                        Icon(Icons.arrow_forward_ios,
                                            size: 14.r)
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15),
                                InkWell(
                                  onTap: () async {
                                    cont.sellerId =
                                        cont.listingModel?.user?.id.toString();
                                    await cont.getSellerDetails(
                                        cont.listingModel?.businessStatus ??
                                            "0",
                                        1,
                                        true);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color:
                                              Theme.of(context).dividerColor),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText(
                                            text: "View seller's ratings".tr),
                                        Icon(Icons.arrow_forward_ios,
                                            size: 14.r)
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text("Listing ID".tr),
                                    Text("${cont.listingModel?.id}"),
                                  ],
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 160.h,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 30,
                          width: 30,
                          padding: EdgeInsets.only(left: 7),
                          decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              shape: BoxShape.circle),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Theme.of(context).iconTheme.color,
                            size: 16,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 5),
                                    Center(
                                      child: Container(
                                        height: 7,
                                        width: 45,
                                        decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).dividerColor,
                                            borderRadius:
                                                BorderRadius.circular(100)),
                                      ),
                                    ),
                                    SizedBox(height: 17),
                                    GestureDetector(
                                        onTap: () => Get.back(),
                                        child: Icon(Icons.close)),
                                    SizedBox(height: 17),
                                    InkWell(
                                      onTap: () {
                                        Get.back();
                                        showModalBottomSheet(
                                          isScrollControlled: true,
                                          context: context,
                                          builder: (context) => Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: GetBuilder<HomeController>(
                                              builder: (cont) {
                                                return SingleChildScrollView(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(height: 5),
                                                      Center(
                                                        child: Container(
                                                          height: 7,
                                                          width: 45,
                                                          decoration: BoxDecoration(
                                                              color: Colors
                                                                  .black45,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100)),
                                                        ),
                                                      ),
                                                      SizedBox(height: 17),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          GestureDetector(
                                                              onTap: () =>
                                                                  Get.back(),
                                                              child: Icon(
                                                                  Icons.close)),
                                                          CustomText(
                                                            text:
                                                                "Report listing"
                                                                    .tr,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 18,
                                                          ),
                                                          SizedBox(
                                                            width: 10.w,
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 17),
                                                      CustomText(
                                                          text:
                                                              "Privately report an inappropriate listing to VentaCuba for review,Your feedback helps us build a safer community for all."
                                                                  .tr),
                                                      SizedBox(height: 15.h),
                                                      RadioListTile(
                                                        value: 0,
                                                        groupValue: cont
                                                            .isSelectedReport,
                                                        onChanged: (value) {
                                                          cont.isSelectedReport =
                                                              0;
                                                          cont.update();
                                                        },
                                                        title: CustomText(
                                                            text:
                                                                "Scam/Prohibited"
                                                                    .tr),
                                                      ),
                                                      RadioListTile(
                                                        value: 1,
                                                        groupValue: cont
                                                            .isSelectedReport,
                                                        onChanged: (value) {
                                                          cont.isSelectedReport =
                                                              1;
                                                          cont.update();
                                                        },
                                                        title: CustomText(
                                                            text: "Duplicated"
                                                                .tr),
                                                      ),
                                                      RadioListTile(
                                                        value: 2,
                                                        groupValue: cont
                                                            .isSelectedReport,
                                                        onChanged: (value) {
                                                          cont.isSelectedReport =
                                                              2;
                                                          cont.update();
                                                        },
                                                        title: CustomText(
                                                            text:
                                                                "No longer relevant"
                                                                    .tr),
                                                      ),
                                                      RadioListTile(
                                                        value: 3,
                                                        groupValue: cont
                                                            .isSelectedReport,
                                                        onChanged: (value) {
                                                          cont.isSelectedReport =
                                                              3;
                                                          cont.update();
                                                        },
                                                        title: CustomText(
                                                            text:
                                                                "MisCategorized"
                                                                    .tr),
                                                      ),
                                                      RadioListTile(
                                                        value: 4,
                                                        groupValue: cont
                                                            .isSelectedReport,
                                                        onChanged: (value) {
                                                          cont.isSelectedReport =
                                                              4;
                                                          cont.update();
                                                        },
                                                        title: CustomText(
                                                            text: "Other".tr),
                                                      ),
                                                      SizedBox(
                                                        height: 30.h,
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          cont.reportListing(
                                                              "${cont.listingModel?.id}",
                                                              cont.isSelectedReport ==
                                                                      0
                                                                  ? "Scam/Prohibited"
                                                                  : cont.isSelectedReport ==
                                                                          1
                                                                      ? "Duplicated"
                                                                      : cont.isSelectedReport ==
                                                                              2
                                                                          ? "No longer relevant"
                                                                          : cont.isSelectedReport == 3
                                                                              ? "MissCategorized"
                                                                              : "Other");
                                                        },
                                                        child: MyButton(
                                                            text: 'Submit'.tr),
                                                      ),
                                                      SizedBox(
                                                        height: 30.h,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Icon(Icons.report),
                                          SizedBox(width: 20),
                                          CustomText(text: "Report listing".tr)
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 15.h),
                                    GestureDetector(
                                      onTap: () {
                                        final title =
                                            cont.listingModel!.title ?? "";
                                        final imageUrl = (cont.listingModel!
                                                        .gallery !=
                                                    null &&
                                                cont.listingModel!.gallery!
                                                    .isNotEmpty)
                                            ? cont.listingModel!.gallery!.first
                                            : null;
                                        // If you have a listing URL, construct it here. Otherwise, leave as empty string.
                                        // final listingId = cont.listingModel!.id?.toString() ?? "";
                                        // final listingUrl = "https://ventacuba.com/listing/$listingId";
                                        String shareContent = title;
                                        if (imageUrl != null &&
                                            imageUrl.isNotEmpty) {
                                          shareContent += "\n$imageUrl";
                                        }
                                        final params = ShareParams(
                                          text: shareContent,
                                          subject: title,
                                        );
                                        SharePlus.instance.share(params);
                                      },
                                      child: Row(
                                        children: [
                                          Icon(Icons.ios_share_rounded),
                                          SizedBox(width: 20),
                                          CustomText(text: "Share listing".tr)
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 40),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 30,
                          width: 30,
                          padding: EdgeInsets.only(left: 0),
                          decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              shape: BoxShape.circle),
                          child: Icon(
                            Icons.more_vert,
                            color: Theme.of(context).iconTheme.color,
                            size: 19,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 20,
                  right: 20,
                  child: Container(
                    // height: 150.h,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Column(
                      children: [
                        Divider(),
                        Container(
                          // height: 65..h,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 5..h,
                                    ),
                                    Text(
                                      'Total Price'.tr,
                                      style: TextStyle(
                                          fontSize: 12..sp,
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color),
                                    ),
                                    Text(
                                      cont.listingModel!.price == "0"
                                          ? ""
                                          : "${PriceFormatter().formatNumber(int.parse(cont.listingModel!.price ?? '0'))}\$ ${PriceFormatter().getCurrency(cont.listingModel!.currency)}",
                                      style: TextStyle(
                                          fontSize: 16..sp,
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.color),
                                    )
                                  ],
                                ),
                              ),
                              Flexible(
                                  flex: 2,
                                  child: cont.isListing == 1
                                      ? InkWell(
                                          onTap: () async {
                                            if (authCont.user?.email == "") {
                                              Navigator.push(
                                                context,
                                                PremiumPageTransitions
                                                    .slideFromBottom(Login()),
                                              );
                                            } else {
                                              cont.listingId = cont
                                                  .listingModel?.id
                                                  .toString();
                                              cont.markASoldListing();
                                            }
                                          },
                                          child: Container(
                                            width: 182..w,
                                            height: 40.h,
                                            decoration: BoxDecoration(
                                                color: AppColors.k0xFF0254B8,
                                                borderRadius:
                                                    BorderRadius.circular(60)),
                                            child: Center(
                                              child: Text(
                                                'Mark a sold'.tr,
                                                style: TextStyle(
                                                    fontSize: 14..sp,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        )
                                      : cont.isListing == 11
                                          ? SizedBox(
                                              width: 1,
                                            )
                                          : InkWell(
                                              onTap: () async {
                                                if (authCont.user?.email ==
                                                    "") {
                                                  Navigator.push(
                                                    context,
                                                    PremiumPageTransitions
                                                        .slideFromBottom(
                                                            Login()),
                                                  );
                                                } else {
                                                  cont.listingModel
                                                              ?.isFavorite ==
                                                          "0"
                                                      ? cont.listingModel
                                                          ?.isFavorite = "1"
                                                      : cont.listingModel
                                                          ?.isFavorite = "0";
                                                  cont.update();
                                                  bool isAddedF = await cont
                                                      .favouriteItem();
                                                  if (isAddedF) {
                                                    errorAlertToast(
                                                        "Successfully".tr);

                                                    // Sync listing favorite status with home screen
                                                    String itemId = cont
                                                            .listingModel
                                                            ?.itemId ??
                                                        "";
                                                    String newStatus = cont
                                                            .listingModel
                                                            ?.isFavorite ??
                                                        "0";
                                                    cont.syncFavoriteStatusInHomeScreen(
                                                        itemId, newStatus);
                                                  } else {
                                                    cont.listingModel
                                                                ?.isFavorite ==
                                                            "0"
                                                        ? cont.listingModel
                                                            ?.isFavorite = "1"
                                                        : cont.listingModel
                                                            ?.isFavorite = "0";
                                                  }
                                                }
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 10),
                                                // height: MediaQuery.of(context).size.height,
                                                decoration: BoxDecoration(
                                                    color:
                                                        AppColors.k0xFF0254B8,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            60)),
                                                child: Center(
                                                  child: Text(
                                                    cont.listingModel
                                                                ?.isFavorite ==
                                                            '0'
                                                        ? 'Add to Favorites'.tr
                                                        : 'Remove to Favorites'
                                                            .tr,
                                                    style: TextStyle(
                                                        fontSize: 14..sp,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            )),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h),
                        InkWell(
                          onTap: () async {
                            if (authCont.user?.email == "") {
                              Get.to(Login());
                            } else if (authCont.user?.userId.toString() ==
                                cont.listingModel?.user?.id.toString()) {
                              errorAlertToast("This is your post".tr);
                            } else {
                              String? id =
                                  "${authCont.user?.userId}_${cont.listingModel?.userId}";
                              // Navigate to chat with the listing owner
                              try {
                                // For now, just navigate to chat page directly
                                print(
                                    'Starting chat with user: ${cont.listingModel?.userId}');
                              } catch (e) {
                                print('Error starting chat: $e');
                              }
                              Get.to(
                                ChatPage(
                                  createChatid: id.trim(),
                                  senderId: "${authCont.user?.userId}",
                                  userName:
                                      "${cont.listingModel?.user?.firstName} ${cont.listingModel?.user?.lastName}",
                                  isLast: true,
                                  remoteUid: "${cont.listingModel?.user?.id}",
                                  userImage: cont
                                              .listingModel?.businessStatus ==
                                          "0"
                                      ? "${cont.sellerDetailsModel?.data?.sellerAbout?.profileImage ?? cont.listingModel?.user?.profileImage}"
                                      : "${cont.sellerDetailsModel?.data?.sellerAbout?.businessLogo ?? cont.listingModel?.user?.businessLogo}",
                                  deviceToken:
                                      "${cont.listingModel?.user?.deviceToken}",
                                  listingImage:
                                      cont.listingModel!.gallery!.isNotEmpty
                                          ? cont.listingModel?.gallery?.first
                                          : null,
                                  listingName: cont.listingModel?.title,
                                  listingPrice: cont.listingModel?.price,
                                  listingLocation: cont.listingModel?.address,
                                  listingId: "${cont.listingModel?.id}",
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                                color: AppColors.k0xFF0254B8,
                                borderRadius: BorderRadius.circular(60)),
                            child: Center(
                              child: Text(
                                "Chat".tr,
                                style: TextStyle(
                                    fontSize: 17..sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20..h),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class FullScreenCarousel extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenCarousel({
    required this.images,
    required this.initialIndex,
  });

  @override
  _FullScreenCarouselState createState() => _FullScreenCarouselState();
}

class _FullScreenCarouselState extends State<FullScreenCarousel> {
  late PageController pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FullScreenGallery(
            images: widget.images,
            initialIndex: widget.initialIndex,
          ),
        ],
      ),
    );
  }
}

class FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  const FullScreenGallery(
      {required this.images, this.initialIndex = 0, super.key});

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  double offset = 0;
  late int currentIndex;
  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex; // Initialize with the passed index
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onVerticalDragUpdate: (details) {
            setState(() {
              offset += details.delta.dy;
            });
          },
          onVerticalDragEnd: (details) {
            if (offset > 120) {
              Navigator.pop(context);
            } else {
              setState(() => offset = 0);
            }
          },
          child: Transform.translate(
            offset: Offset(0, offset),
            child: PhotoViewGestureDetectorScope(
              axis: Axis.horizontal,
              child: CarouselSlider(
                options: CarouselOptions(
                  viewportFraction: 1,
                  initialPage: widget.initialIndex,
                  height: MediaQuery.of(context).size.height,
                  onPageChanged: (index, reason) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                ),
                items: widget.images.map((url) {
                  return PhotoView(
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 3,
                    imageProvider: CachedNetworkImageProvider(url),
                  );
                }).toList(),
              ),
            ),
          ),
        ),

        /// --- ✅ numbering (top center) ---
        Positioned(
          top: 40,
          left: 0,
          right: 0,
          child: Text(
            "${currentIndex + 1} / ${widget.images.length}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        /// --- ✅ dots (bottom center) ---
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.images.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: currentIndex == index ? 10 : 7,
                height: currentIndex == index ? 10 : 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentIndex == index ? Colors.white : Colors.white54,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
