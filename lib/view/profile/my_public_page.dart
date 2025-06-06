import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import 'package:venta_cuba/view/Chat/custom_text.dart';
import 'package:venta_cuba/view/Navigation%20bar/post.dart' show PriceFormatter;
import 'package:venta_cuba/view/constants/Colors.dart';
import '../../Models/ListingModel.dart';
import '../frame/frame.dart';
import 'become_vendor.dart';

class MyPublicPage extends StatefulWidget {
  String businessType;
  int onScreen;

  MyPublicPage({super.key, this.businessType = "0", required this.onScreen});

  @override
  State<MyPublicPage> createState() => _MyPublicPageState();
}

class _MyPublicPageState extends State<MyPublicPage> {
  bool loading12 = false;

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

  List<Widget> _buildStarRating1(double rating) {
    List<Widget> stars = [];
    for (int i = 0; i < 5; i++) {
      stars.add(
        Icon(Icons.star,
            color: i < rating ? AppColors.k0xFFF9E005 : AppColors.k1xFFF9E005),
      );
    }
    return stars;
  }

  Future<void> _launchUrl(String uri) async {
    final Uri _url = Uri.parse(uri);
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  final homeCont = Get.put(HomeController());
  int selectedIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    print(
        ".............?????/${homeCont.sellerDetailsModel?.data?.sellerRatingsCount?.threeStarRatings}");
    print(
        ".............?????/${homeCont.sellerDetailsModel?.data?.sellerRatingsCount?.fourStarRatings}");
    print(
        ".............?????/${homeCont.sellerDetailsModel?.data?.sellerRatingsCount?.fiveStarRatings}");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: widget.onScreen,
      child: GetBuilder<HomeController>(
        builder: (cont) {
          return Scaffold(
            backgroundColor: AppColors.white,
            body: Padding(
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
                          'Public Page'.tr,
                          style: TextStyle(
                              fontSize: 21..sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.black),
                        ),
                        Icon(Icons.ios_share, size: 0)
                      ],
                    ),
                    SizedBox(
                      height: 40..h,
                    ),
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
                                    ? "${cont.sellerDetailsModel?.data?.sellerAbout?.businessLogo}"
                                    : "${cont.sellerDetailsModel?.data?.sellerAbout?.profileImage}",
                                imageBuilder: (context, imageProvider) =>
                                    ClipRRect(
                                  child: Container(
                                    height: 85..h,
                                    width: 85..w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) => SizedBox(
                                    height: 85..h,
                                    width: 85..w,
                                    child: Center(
                                        child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ))),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                              SizedBox(
                                width: 20..w,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 10..h,
                                  ),
                                  SizedBox(height: 3..h),
                                  SelectionArea(
                                    child: Text(
                                      widget.businessType == "0"
                                          ? '${cont.sellerDetailsModel?.data?.sellerAbout?.firstName} ${cont.sellerDetailsModel?.data?.sellerAbout?.lastName}'
                                          : "${cont.sellerDetailsModel?.data?.sellerAbout?.businessName}",
                                      style: TextStyle(
                                          fontSize: 16..sp,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.k1xFF403C3C),
                                    ),
                                  ),
                                  // SizedBox(height: 7..h),
                                  Row(
                                    children: [
                                      CustomText(text: "Owner".tr),
                                      SizedBox(width: 7),
                                      Container(
                                        height: 20,
                                        width: 1,
                                        color: Colors.black45,
                                      ),
                                      SizedBox(width: 7),
                                      CustomTextMonthDays(
                                          text: cont.sellerDetailsModel?.data
                                              ?.sellerAbout?.accountDuration),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Row(
                                        children: _buildStarRating(double.parse(
                                            cont.sellerDetailsModel?.data
                                                    ?.sellerAbout?.averageRating
                                                    .toString() ??
                                                "0")),
                                      ),
                                      SizedBox(
                                        width: 8..w,
                                      ),
                                      SelectionArea(
                                        child: Text(
                                            '${cont.sellerDetailsModel?.data?.sellerAbout?.averageRating.toString()}'),
                                      ),
                                      SizedBox(width: 3),
                                      SelectionArea(
                                        child: Text(
                                            '(${cont.sellerDetailsModel?.data?.sellerRatings!.length})'),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50..h,
                    ),
                    FittedBox(
                      child: SizedBox(
                        height: 50.h,
                        width: 360.w,
                        child: TabBar(
                          indicatorSize: TabBarIndicatorSize.label,
                          // Use label size for the indicator
                          indicatorWeight: 4.0,
                          // Set the indicator weight (width)
                          labelPadding: EdgeInsets.symmetric(horizontal: 0),
                          padding: EdgeInsets.zero,
                          labelColor: AppColors.k0xFF0254B8,
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 17..sp,
                          ),
                          unselectedLabelColor: AppColors.k0xFFA9ABAC,
                          tabs: [
                            CustomText(
                              text: 'Listings'.tr,
                            ),
                            SizedBox(
                                width: 110.w,
                                child: Center(
                                    child: CustomText(
                                  text: 'Ratings'.tr,
                                ))),
                            CustomText(
                              text: 'About'.tr,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30..h,
                    ),
                    Expanded(
                        child: TabBarView(
                      children: [
                        cont.sellerDetailsModel!.data!.sellerListings!.data!
                                .isEmpty
                            ? Container(
                                height: MediaQuery.of(context).size.height,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/images/searchList.png'),
                                    SizedBox(
                                      height: 10..h,
                                    ),
                                    SelectionArea(
                                      child: Text(
                                        'No Listings'.tr,
                                        style: TextStyle(
                                            fontSize: 21..sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.black),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10..h,
                                    ),
                                    SelectionArea(
                                      child: Text(
                                        'Seller doesn’t have any listings at the moment'
                                            .tr,
                                        style: TextStyle(
                                            fontSize: 18..sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.black),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        text: cont
                                                    .sellerDetailsModel!
                                                    .data!
                                                    .sellerListings!
                                                    .data!
                                                    .length ==
                                                0
                                            ? "0 Listing".tr
                                            : "${cont.sellerDetailsModel!.data!.sellerListings!.data!.length} ${"Listings".tr}",
                                        fontSize: 16.sp,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return buildBottomSheet(context);
                                            },
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          decoration: BoxDecoration(
                                              color: Colors.blue.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              border: Border.all(
                                                  color: Colors.blue)),
                                          child: Row(
                                            children: [
                                              Icon(Icons.compare_arrows),
                                              CustomText(text: "Sort".tr)
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Expanded(
                                    child: ListView.separated(
                                      separatorBuilder: (context, index) {
                                        return SizedBox(
                                          height: 20.h,
                                        );
                                      },
                                      itemBuilder: (context, index) {
                                        print(
                                            "$index....${cont.sellerDetailsModel?.data?.sellerListings?.data?[index].title}");
                                        return Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 20),
                                              Container(
                                                height: 170..h,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10..r)),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    CachedNetworkImage(
                                                      height: 170..h,
                                                      width: 170..w,
                                                      imageUrl: cont
                                                                      .sellerDetailsModel
                                                                      ?.data
                                                                      ?.sellerListings
                                                                      ?.data?[
                                                                          index]
                                                                      .gallery !=
                                                                  null &&
                                                              cont
                                                                  .sellerDetailsModel!
                                                                  .data!
                                                                  .sellerListings!
                                                                  .data![index]
                                                                  .gallery!
                                                                  .isNotEmpty
                                                          ? "${cont.sellerDetailsModel?.data?.sellerListings?.data?[index].gallery?.first}"
                                                          : "",
                                                      imageBuilder: (context,
                                                              imageProvider) =>
                                                          ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        child: Container(
                                                          height: 170..h,
                                                          width: 170..w,
                                                          decoration:
                                                              BoxDecoration(
                                                            image:
                                                                DecorationImage(
                                                              image:
                                                                  imageProvider,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      placeholder: (context,
                                                              url) =>
                                                          SizedBox(
                                                              height: 170..h,
                                                              width: 170..w,
                                                              child: Center(
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                              ))),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Center(
                                                              child: Text(
                                                                  "No Image"
                                                                      .tr)),
                                                    ),
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Container(
                                                          // height: 90..h,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .37,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              SelectionArea(
                                                                child: Text(
                                                                  '${cont.sellerDetailsModel?.data?.sellerListings?.data?[index].title}',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          17
                                                                            ..sp,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                              ),
                                                              SelectionArea(
                                                                child: Text(
                                                                  "${cont.sellerDetailsModel?.data?.sellerListings?.data?[index].address}",
                                                                  // overflow: TextOverflow.ellipsis,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          13
                                                                            ..sp,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: AppColors
                                                                          .k0xFF403C3C),
                                                                ),
                                                              ),
                                                              SelectionArea(
                                                                child: Text(
                                                                  cont.sellerDetailsModel?.data?.sellerListings?.data?[index].price ==
                                                                              "0" ||
                                                                          cont.sellerDetailsModel?.data?.sellerListings?.data?[index].price ==
                                                                              null
                                                                      ? ""
                                                                      : "${PriceFormatter().formatNumber(int.parse(cont.sellerDetailsModel?.data?.sellerListings?.data?[index].price?.toString() ?? "0"))} ${cont.sellerDetailsModel?.data?.sellerListings?.data?[index].currency ?? 'USD'}",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16
                                                                            ..sp,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: AppColors
                                                                          .k0xFF0254B8),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          height: 40..h,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .37,
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                color: AppColors
                                                                    .k0xFF0254B8),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          child: InkWell(
                                                            onTap: () {
                                                              print(
                                                                  ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>KKKKKKKKKKKKKKKKKK");
                                                              cont.isListing =
                                                                  11;
                                                              cont.listingModel = cont
                                                                  .sellerDetailsModel
                                                                  ?.data
                                                                  ?.sellerListings
                                                                  ?.data?[index];
                                                              cont.listingModel
                                                                      ?.user =
                                                                  cont
                                                                      .sellerDetailsModel
                                                                      ?.data
                                                                      ?.sellerAbout;
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            const FrameScreen(),
                                                                  ));
                                                            },
                                                            child: Center(
                                                              child: Text(
                                                                'View Details'
                                                                    .tr,
                                                                style: TextStyle(
                                                                    fontSize: 16
                                                                      ..sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: AppColors
                                                                        .k0xFF0254B8),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                      itemCount: cont.sellerDetailsModel!.data!
                                          .sellerListings!.data!.length,
                                    ),
                                  ),
                                ],
                              ),
                        SingleChildScrollView(
                          child: Container(
                            height: MediaQuery.of(context).size.height,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SelectionArea(
                                  child: Text(
                                    'Feedback Summary'.tr,
                                    style: TextStyle(
                                        fontSize: 19..sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.black),
                                  ),
                                ),
                                SizedBox(
                                  height: 5..h,
                                ),
                                SelectionArea(
                                  child: Text(
                                    selectedIndex == 0
                                        ? 'Top feedbacks received from all'.tr
                                        : selectedIndex == 1
                                            ? 'Top feedbacks received from buyers'
                                                .tr
                                            : 'Top feedbacks received from seller'
                                                .tr,
                                    style: TextStyle(
                                        fontSize: 15..sp,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.k0xFF9F9F9F),
                                  ),
                                ),
                                RatingSummary(
                                  counter: 5,
                                  labelCounterFiveStars: cont
                                          .sellerDetailsModel
                                          ?.data
                                          ?.sellerRatingsCount
                                          ?.fiveStarRatings
                                          .toString() ??
                                      "0",
                                  labelCounterFourStars: cont
                                          .sellerDetailsModel
                                          ?.data
                                          ?.sellerRatingsCount
                                          ?.fourStarRatings
                                          .toString() ??
                                      "0",
                                  labelCounterThreeStars: cont
                                          .sellerDetailsModel
                                          ?.data
                                          ?.sellerRatingsCount
                                          ?.threeStarRatings
                                          .toString() ??
                                      "0",
                                  labelCounterTwoStars: cont
                                          .sellerDetailsModel
                                          ?.data
                                          ?.sellerRatingsCount
                                          ?.twoStarRatings
                                          .toString() ??
                                      "0",
                                  labelCounterOneStars: cont
                                          .sellerDetailsModel
                                          ?.data
                                          ?.sellerRatingsCount
                                          ?.oneStarRatings
                                          .toString() ??
                                      "0",
                                  average: double.parse(cont.sellerDetailsModel
                                          ?.data?.sellerAbout!.averageRating ??
                                      ""),
                                  showAverage: true,
                                  counterFiveStars: cont
                                          .sellerDetailsModel
                                          ?.data
                                          ?.sellerRatingsCount
                                          ?.fiveStarRatings ??
                                      0,
                                  counterFourStars: cont
                                          .sellerDetailsModel
                                          ?.data
                                          ?.sellerRatingsCount
                                          ?.fourStarRatings ??
                                      0,
                                  counterThreeStars: cont
                                          .sellerDetailsModel
                                          ?.data
                                          ?.sellerRatingsCount
                                          ?.threeStarRatings ??
                                      0,
                                  counterTwoStars: cont
                                          .sellerDetailsModel
                                          ?.data
                                          ?.sellerRatingsCount
                                          ?.twoStarRatings ??
                                      0,
                                  counterOneStars: cont
                                          .sellerDetailsModel
                                          ?.data
                                          ?.sellerRatingsCount
                                          ?.oneStarRatings ??
                                      0,
                                ),
                                SizedBox(height: 20..h),
                                SizedBox(
                                  height: 35.h,
                                  child: ListView.builder(
                                      itemCount: 3,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) => InkWell(
                                            onTap: () async {
                                              selectedIndex = index;
                                              loading12 = true;
                                              setState(() {});
                                              await cont.getSellerDetails1(
                                                  selectedIndex == 0
                                                      ? "all"
                                                      : selectedIndex == 1
                                                          ? "customer"
                                                          : "vendor");
                                              loading12 = false;
                                              setState(() {});
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 5),
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              decoration: BoxDecoration(
                                                  color: selectedIndex == index
                                                      ? Colors.blue.shade300
                                                      : Colors.grey.shade300,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  border: Border.all(
                                                      color: selectedIndex ==
                                                              index
                                                          ? Colors.blue
                                                              .withOpacity(0.9)
                                                          : Colors.grey
                                                              .withOpacity(
                                                                  0.9))),
                                              child: Center(
                                                child: CustomText(
                                                  text: index == 0
                                                      ? "All".tr
                                                      : index == 1
                                                          ? "From buyer".tr
                                                          : "From seller".tr,
                                                ),
                                              ),
                                            ),
                                          )),
                                ),
                                SizedBox(height: 10.h),
                                Row(
                                  children: [
                                    CustomText(
                                      text: "Ratings".tr,
                                      fontSize: 20..sp,
                                    ),
                                    CustomText(
                                      text:
                                          "(${cont.sellerDetailsModel?.data?.sellerRatings!.length})",
                                      fontSize: 20..sp,
                                    ),
                                  ],
                                ),
                                loading12
                                    ? Center(child: CircularProgressIndicator())
                                    : Expanded(
                                        child: ListView.separated(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.only(top: 30),
                                          itemCount: cont
                                                  .sellerDetailsModel
                                                  ?.data
                                                  ?.sellerRatings!
                                                  .length ??
                                              0,
                                          separatorBuilder: (context, index) =>
                                              SizedBox(height: 15),
                                          itemBuilder: (context, index) =>
                                              Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Icon(Icons.person),
                                                  SizedBox(width: 10),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CustomText(
                                                          text:
                                                              "${cont.sellerDetailsModel?.data?.sellerRatings![index].users?[0].firstName} ${cont.sellerDetailsModel?.data?.sellerRatings![index].users?[0].lastName}"),
                                                      CustomText(
                                                          text: cont
                                                              .sellerDetailsModel
                                                              ?.data
                                                              ?.sellerRatings![
                                                                  index]
                                                              .comment),
                                                      SizedBox(height: 10),
                                                      Row(
                                                        children: _buildStarRating1(
                                                            double.parse(cont
                                                                    .sellerDetailsModel
                                                                    ?.data
                                                                    ?.sellerRatings![
                                                                        index]
                                                                    .responseTimeRating
                                                                    .toString() ??
                                                                "0")),
                                                      ),
                                                    ],
                                                  ),
                                                  Spacer(),
                                                  CustomText(
                                                      text: cont
                                                          .sellerDetailsModel
                                                          ?.data
                                                          ?.sellerRatings![
                                                              index]
                                                          .createdTimeAgo),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                SizedBox(
                                  height: 9..h,
                                ),
                              ],
                            ),
                          ),
                        ),
                        cont.sellerDetailsModel?.data?.sellerAbout
                                        ?.facebookLink ==
                                    null &&
                                cont.sellerDetailsModel?.data?.sellerAbout
                                        ?.youtubeLink ==
                                    null &&
                                cont.sellerDetailsModel?.data?.sellerAbout?.tiktokLink ==
                                    null &&
                                cont.sellerDetailsModel?.data?.sellerAbout
                                        ?.pinterestLink ==
                                    null &&
                                cont.sellerDetailsModel?.data?.sellerAbout
                                        ?.twitterLink ==
                                    null &&
                                cont.sellerDetailsModel?.data?.sellerAbout
                                        ?.linkedinLink ==
                                    null &&
                                cont.sellerDetailsModel?.data?.sellerAbout
                                        ?.instagramLink ==
                                    null
                            ? Container(
                                height: MediaQuery.of(context).size.height,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                        'assets/images/searchImage.png'),
                                    SizedBox(
                                      height: 10..h,
                                    ),
                                    Text(
                                      'No Social Links'.tr,
                                      style: TextStyle(
                                          fontSize: 21..sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.black),
                                    ),
                                  ],
                                ),
                              )
                            : SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SelectionArea(
                                      child: Text(
                                        'Facebook Link'.tr,
                                        style: TextStyle(
                                            fontSize: 18..sp,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.black),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10..h,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        _launchUrl(cont.isBusinessAccount
                                            ? "${cont.sellerDetailsModel?.data?.sellerAbout?.businessFacebookLink}"
                                            : "${cont.sellerDetailsModel?.data?.sellerAbout?.facebookLink}");
                                      },
                                      child: SelectionArea(
                                        child: Text(
                                          '${cont.isBusinessAccount ? cont.sellerDetailsModel?.data?.sellerAbout?.businessFacebookLink : cont.sellerDetailsModel?.data?.sellerAbout?.facebookLink}',
                                          style: TextStyle(
                                              fontSize: 15..sp,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.k0xFFA9ABAC),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20..h,
                                    ),
                                    Text(
                                      'Pinterest Link'.tr,
                                      style: TextStyle(
                                          fontSize: 18..sp,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.black),
                                    ),
                                    SizedBox(
                                      height: 10..h,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        _launchUrl(cont.isBusinessAccount
                                            ? "${cont.sellerDetailsModel?.data?.sellerAbout?.businessPinterestLink}"
                                            : "${cont.sellerDetailsModel?.data?.sellerAbout?.pinterestLink}");
                                      },
                                      child: SelectionArea(
                                        child: Text(
                                          cont.isBusinessAccount
                                              ? "${cont.sellerDetailsModel?.data?.sellerAbout?.businessPinterestLink}"
                                              : '${cont.sellerDetailsModel?.data?.sellerAbout?.pinterestLink}',
                                          style: TextStyle(
                                              fontSize: 15..sp,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.k0xFFA9ABAC),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20..h,
                                    ),
                                    Text(
                                      'Twitter Link'.tr,
                                      style: TextStyle(
                                          fontSize: 18..sp,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.black),
                                    ),
                                    SizedBox(
                                      height: 10..h,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        _launchUrl(cont.isBusinessAccount
                                            ? "${cont.sellerDetailsModel?.data?.sellerAbout?.businessTwitterLink}"
                                            : "${cont.sellerDetailsModel?.data?.sellerAbout?.twitterLink}");
                                      },
                                      child: SelectionArea(
                                        child: Text(
                                          cont.isBusinessAccount
                                              ? "${cont.sellerDetailsModel?.data?.sellerAbout?.businessTwitterLink}"
                                              : '${cont.sellerDetailsModel?.data?.sellerAbout?.twitterLink}',
                                          style: TextStyle(
                                              fontSize: 15..sp,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.k0xFFA9ABAC),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20..h,
                                    ),
                                    Text(
                                      'Linkedin Link'.tr,
                                      style: TextStyle(
                                          fontSize: 18..sp,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.black),
                                    ),
                                    SizedBox(
                                      height: 10..h,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        _launchUrl(cont.isBusinessAccount
                                            ? "${cont.sellerDetailsModel?.data?.sellerAbout?.businessLinkedinLink}"
                                            : "${cont.sellerDetailsModel?.data?.sellerAbout?.linkedinLink}");
                                      },
                                      child: SelectionArea(
                                        child: Text(
                                          cont.isBusinessAccount
                                              ? "${cont.sellerDetailsModel?.data?.sellerAbout?.businessLinkedinLink}"
                                              : '${cont.sellerDetailsModel?.data?.sellerAbout?.linkedinLink}',
                                          style: TextStyle(
                                              fontSize: 15..sp,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.k0xFFA9ABAC),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20..h,
                                    ),
                                    Text(
                                      'Instagram Link'.tr,
                                      style: TextStyle(
                                          fontSize: 18..sp,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.black),
                                    ),
                                    SizedBox(
                                      height: 10..h,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        _launchUrl(cont.isBusinessAccount
                                            ? "${cont.sellerDetailsModel?.data?.sellerAbout?.businessInstagramLink}"
                                            : "${cont.sellerDetailsModel?.data?.sellerAbout?.instagramLink}");
                                      },
                                      child: SelectionArea(
                                        child: Text(
                                          cont.isBusinessAccount
                                              ? "${cont.sellerDetailsModel?.data?.sellerAbout?.businessInstagramLink}"
                                              : '${cont.sellerDetailsModel?.data?.sellerAbout?.instagramLink ?? ""}',
                                          style: TextStyle(
                                              fontSize: 15..sp,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.k0xFFA9ABAC),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20..h,
                                    ),
                                    Text(
                                      'Youtube Link'.tr,
                                      style: TextStyle(
                                          fontSize: 18..sp,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.black),
                                    ),
                                    SizedBox(
                                      height: 10..h,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        _launchUrl(cont.isBusinessAccount
                                            ? "${cont.sellerDetailsModel?.data?.sellerAbout?.businessYoutubeLink}"
                                            : "${cont.sellerDetailsModel?.data?.sellerAbout?.youtubeLink}");
                                      },
                                      child: SelectionArea(
                                        child: Text(
                                          cont.isBusinessAccount
                                              ? "${cont.sellerDetailsModel?.data?.sellerAbout?.businessYoutubeLink}"
                                              : '${cont.sellerDetailsModel?.data?.sellerAbout?.youtubeLink ?? ""}',
                                          style: TextStyle(
                                              fontSize: 15..sp,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.k0xFFA9ABAC),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20..h,
                                    ),
                                    Text(
                                      'Tiktok Link'.tr,
                                      style: TextStyle(
                                          fontSize: 18..sp,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.black),
                                    ),
                                    SizedBox(
                                      height: 10..h,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        _launchUrl(cont.isBusinessAccount
                                            ? "${cont.sellerDetailsModel?.data?.sellerAbout?.businessTiktokLink}"
                                            : "${cont.sellerDetailsModel?.data?.sellerAbout?.tiktokLink}");
                                      },
                                      child: SelectionArea(
                                        child: Text(
                                          cont.isBusinessAccount
                                              ? "${cont.sellerDetailsModel?.data?.sellerAbout?.businessTiktokLink}"
                                              : '${cont.sellerDetailsModel?.data?.sellerAbout?.tiktokLink ?? ""}',
                                          style: TextStyle(
                                              fontSize: 15..sp,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.k0xFFA9ABAC),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ))
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildBottomSheet(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return GetBuilder<HomeController>(builder: (cont) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  cont.selectedType = "Oldest First";
                  cont.update();
                },
                title: Text('Oldest First'.tr),
                leading: Radio(
                  value: "Oldest First",
                  groupValue: cont.selectedType,
                  onChanged: (value) {
                    cont.selectedType = value ?? "";
                    cont.update();
                  },
                ),
              ),
              ListTile(
                onTap: () {
                  cont.selectedType = "Newest First";
                  cont.update();
                },
                title: Text('Newest First'.tr),
                leading: Radio(
                  value: "Newest First",
                  groupValue: cont.selectedType,
                  onChanged: (value) {
                    cont.selectedType = value ?? "";
                    cont.update();
                  },
                ),
              ),
              ListTile(
                onTap: () {
                  cont.selectedType = "Highest Price";
                  cont.update();
                },
                title: Text('Highest Price'.tr),
                leading: Radio(
                  value: "Highest Price",
                  groupValue: cont.selectedType,
                  onChanged: (value) {
                    cont.selectedType = value ?? "";
                    cont.update();
                  },
                ),
              ),
              ListTile(
                onTap: () {
                  cont.selectedType = "Lowest Price";
                  cont.update();
                },
                title: Text('Lowest Price'.tr),
                leading: Radio(
                  value: "Lowest Price",
                  groupValue: cont.selectedType,
                  onChanged: (value) {
                    cont.selectedType = value ?? "";
                    cont.update();
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await cont.getSellerDetails(
                      cont.isBusinessAccount ? "1" : "0", 0, false);
                  cont.update();
                  Navigator.pop(context);
                },
                child: Text('Apply'.tr),
              ),
            ],
          ),
        );
      });
    });
  }

  // void sortList(SortingOption _sortingOption) {
  //   print(_sortingOption);
  //
  //   if (homeCont.sellerDetailsModel?.data?.sellerListings?.data != null) {
  //     List<ListingModel>? originalList =
  //         homeCont.sellerDetailsModel?.data?.sellerListings?.data;
  //     print(jsonEncode(originalList));
  //     setState(() {
  //       print("object;;;;;;;;;;;;");
  //       switch (_sortingOption) {
  //         case SortingOption.newestFirst:
  //           // Reverse the list for "Newest First"
  //           homeCont.sellerDetailsModel?.data?.sellerListings?.data = homeCont
  //               .sellerDetailsModel?.data?.sellerListings?.data?.reversed
  //               .toList();
  //           break;
  //         case SortingOption.oldestFirst:
  //           homeCont.sellerDetailsModel?.data?.sellerListings?.data = homeCont
  //               .sellerDetailsModel?.data?.sellerListings?.data?.reversed
  //               .toList();
  //           // homeCont.sellerDetailsModel?.data?.sellerListings?.data =
  //           //     List<ListingModel>.from(originalList ?? []);
  //           break;
  //         case SortingOption.highestPrice:
  //           homeCont.sellerDetailsModel?.data?.sellerListings?.data
  //               ?.sort((a, b) => b.price!.compareTo(a.price!));
  //           break;
  //         case SortingOption.lowestPrice:
  //           homeCont.sellerDetailsModel?.data?.sellerListings?.data
  //               ?.sort((a, b) => a.price!.compareTo(b.price!));
  //           break;
  //       }
  //       print("object;;;;;;;;;.......................;;;");
  //     });
  //   }
  // }
}

class RatingSummary extends StatelessWidget {
  const RatingSummary({
    Key? key,
    required this.counter,
    this.average = 0.0,
    this.showAverage = true,
    this.averageStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
    this.counterFiveStars = 0,
    this.counterFourStars = 0,
    this.counterThreeStars = 0,
    this.counterTwoStars = 0,
    this.counterOneStars = 0,
    this.labelCounterFiveStars = '5',
    this.labelCounterFourStars = '4',
    this.labelCounterThreeStars = '3',
    this.labelCounterTwoStars = '2',
    this.labelCounterOneStars = '1',
    this.labelCounterFiveStarsStyle =
        const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    this.labelCounterFourStarsStyle =
        const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    this.labelCounterThreeStarsStyle =
        const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    this.labelCounterTwoStarsStyle =
        const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    this.labelCounterOneStarsStyle =
        const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    this.label = 'Ratings',
    this.labelStyle = const TextStyle(fontWeight: FontWeight.w600),
    this.color = Colors.amber,
    this.backgroundColor = const Color(0xFFEEEEEE),
  }) : super(key: key);
  final int counter;

  final double average;
  final bool showAverage;
  final TextStyle averageStyle;
  final int counterFiveStars;
  final int counterFourStars;
  final int counterThreeStars;
  final int counterTwoStars;
  final int counterOneStars;
  final String labelCounterFiveStars;
  final String labelCounterFourStars;
  final String labelCounterThreeStars;
  final String labelCounterTwoStars;
  final String labelCounterOneStars;
  final TextStyle labelCounterFiveStarsStyle;
  final TextStyle labelCounterFourStarsStyle;
  final TextStyle labelCounterThreeStarsStyle;
  final TextStyle labelCounterTwoStarsStyle;
  final TextStyle labelCounterOneStarsStyle;
  final String label;
  final TextStyle labelStyle;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showAverage) ...[
                const SizedBox(width: 30),
                Row(
                  children: [
                    RatingBarIndicator(
                      rating: average,
                      itemSize: 20,
                      unratedColor: backgroundColor,
                      itemBuilder: (context, index) {
                        return Icon(Icons.star, color: color);
                      },
                    ),
                    const SizedBox(width: 10),
                    Text(average.toStringAsFixed(1), style: averageStyle),
                    Text(
                      " out of ".tr,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.fade,
                    ),
                    Text(
                      "$counter",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.fade,
                    ),
                  ],
                ),
              ],
              _ReviewBar(
                label: labelCounterFiveStars,
                label1: "5 ${"Stars".tr}",
                labelStyle: labelCounterFiveStarsStyle,
                value: counterFiveStars / counter,
                color: color,
                backgroundColor: backgroundColor,
              ),
              _ReviewBar(
                label1: "4 ${"Stars".tr}",
                label: labelCounterFourStars,
                labelStyle: labelCounterFourStarsStyle,
                value: counterFourStars / counter,
                color: color,
                backgroundColor: backgroundColor,
              ),
              _ReviewBar(
                label1: "3 ${"Stars".tr}",
                label: labelCounterThreeStars,
                labelStyle: labelCounterThreeStarsStyle,
                value: counterThreeStars / counter,
                color: color,
                backgroundColor: backgroundColor,
              ),
              _ReviewBar(
                label1: "2 ${"Stars".tr}",
                label: labelCounterTwoStars,
                labelStyle: labelCounterTwoStarsStyle,
                value: counterTwoStars / counter,
                color: color,
                backgroundColor: backgroundColor,
              ),
              _ReviewBar(
                label1: "1 ${"Stars".tr}",
                label: labelCounterOneStars,
                labelStyle: labelCounterOneStarsStyle,
                value: counterOneStars / counter,
                color: color,
                backgroundColor: backgroundColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewBar extends StatelessWidget {
  const _ReviewBar({
    Key? key,
    required this.label,
    required this.value,
    this.color = Colors.amber,
    this.backgroundColor = const Color(0xFFEEEEEE),
    this.labelStyle =
        const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    required this.label1,
  }) : super(key: key);
  final String label;
  final String label1;
  final TextStyle labelStyle;
  final double value;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label1,
            style: labelStyle,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 10,
                child: LinearProgressIndicator(
                  value: value,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  backgroundColor: backgroundColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Text(
            label,
            style: labelStyle,
          ),
        ],
      ),
    );
  }
}
