import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import 'package:venta_cuba/util/my_button.dart';
import 'package:venta_cuba/view/Chat/custom_text.dart';
import 'package:venta_cuba/view/Navigation%20bar/post.dart';
import 'package:venta_cuba/view/Navigation%20bar/selecct_category_post.dart';
import 'package:venta_cuba/view/auth/vendor_screen.dart';
import 'package:venta_cuba/view/constants/Colors.dart';
import 'package:flutter_svg/svg.dart';
import 'package:venta_cuba/view/profile/become_vendor.dart';

import '../../Controllers/auth_controller.dart';
import '../frame/frame.dart';
import '../notification/notification.dart';

class Listings extends StatefulWidget {
  const Listings({super.key});

  @override
  State<Listings> createState() => _ListingsState();
}

class _ListingsState extends State<Listings> {
  final homeCont = Get.put(HomeController());
  final authCont = Get.put(AuthController());

  @override
  void initState() {
    homeCont.getSellerListingByStatus();
    homeCont.listingLoading = true;
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    homeCont.listingLoading = true;
    homeCont.status = "active";
    homeCont.soldStatus = null;
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        homeCont.getFavouriteItems();
                      },
                      child: SvgPicture.asset(
                        'assets/icons/heartSimple.svg',
                      ),
                    ),
                    SizedBox(
                      width: 20..w,
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationScreen(),
                              ));
                        },
                        child: SvgPicture.asset(
                            'assets/icons/notificationSimple.svg')),
                  ],
                ),
                SizedBox(
                  height: 20..h,
                ),
                Text(
                  'Listings'.tr,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black),
                ),
                SizedBox(
                  height: 50..h,
                ),
                TabBar(
                  tabAlignment: TabAlignment.center,
                  isScrollable: true,
                  onTap: (value) {
                    homeCont.listingLoading = true;
                    homeCont.update();
                    if (value == 0) {
                      homeCont.status = "active";
                      homeCont.soldStatus = null;
                      homeCont.getSellerListingByStatus();
                    } else if (value == 1) {
                      homeCont.status = "inactive";
                      homeCont.soldStatus = null;
                      homeCont.getSellerListingByStatus();
                    } else {
                      homeCont.status = null;
                      homeCont.soldStatus = "1";
                      homeCont.getSellerListingByStatus();
                    }
                  },
                  labelColor: AppColors.k0xFF0254B8,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18..sp,
                  ),
                  unselectedLabelColor: AppColors.k0xFFA9ABAC,
                  tabs: [
                    Tab(
                      text: 'Active'.tr,
                    ),
                    Tab(
                      text: 'In Active'.tr,
                    ),
                    Tab(
                      text: 'Sold'.tr,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10..h,
                ),
                GetBuilder<HomeController>(builder: (cont) {
                  return cont.listingLoading
                      ? Expanded(
                          child: Center(child: CircularProgressIndicator()))
                      : Expanded(
                          child: TabBarView(
                          dragStartBehavior: DragStartBehavior.down,
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            authCont.isBusinessAccount &&
                                        cont.bussinessPostCount.value == 0 ||
                                    !authCont.isBusinessAccount &&
                                        cont.personalAcountPost.value == 0
                                ? Container(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/icons/list_icon.webp',
                                          height: 150,
                                          width: 150,
                                        ),
                                        SizedBox(
                                          height: 30..h,
                                        ),
                                        Text(
                                          'Your listings will live here'.tr,
                                          style: TextStyle(
                                              fontSize: 21,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.black),
                                        ),
                                        SizedBox(
                                          height: 20..h,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            authCont.currentIndexBottomAppBar =
                                                2;
                                            authCont.update();
                                          },
                                          child: MyButton(text: 'List Now'.tr),
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      authCont.isBusinessAccount
                                          ? CustomText(
                                              text: cont.bussinessPostCount
                                                          .value ==
                                                      0
                                                  ? "0 Listing".tr
                                                  : "${cont.bussinessPostCount.value} ${"Listings".tr}",
                                              fontSize: 16.sp,
                                            )
                                          : CustomText(
                                              text: cont.personalAcountPost
                                                          .value ==
                                                      0
                                                  ? "0 Listing".tr
                                                  : "${cont.personalAcountPost.value} ${"Listings".tr}",
                                              fontSize: 16.sp,
                                            ),
                                      SizedBox(height: 4),
                                      Expanded(
                                        child: ListView.separated(
                                          separatorBuilder:
                                              (BuildContext context,
                                                  int index) {
                                            int isBusiness =
                                                cont.isBusinessAccount ? 1 : 0;
                                            if (cont.userListingModelList[index]
                                                    .businessStatus ==
                                                "${isBusiness}") {
                                              return Column(
                                                children: [
                                                  SizedBox(
                                                    height: 10.h,
                                                  ),
                                                  Divider(),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                ],
                                              );
                                            } else if (cont
                                                    .userListingModelList[index]
                                                    .businessStatus ==
                                                "${isBusiness}") {
                                              return Column(
                                                children: [
                                                  SizedBox(
                                                    height: 10.h,
                                                  ),
                                                  Divider(),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                ],
                                              );
                                            } else {
                                              return SizedBox();
                                            }
                                          },
                                          itemBuilder: (context, index) {
                                            int isBusiness =
                                                cont.isBusinessAccount ? 1 : 0;
                                            if (cont.userListingModelList[index]
                                                    .businessStatus ==
                                                "${isBusiness}") {
                                              return Container(
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      height: 190..h,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
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
                                                                            .userListingModelList[
                                                                                index]
                                                                            .gallery !=
                                                                        null &&
                                                                    cont
                                                                        .userListingModelList[
                                                                            index]
                                                                        .gallery!
                                                                        .isNotEmpty
                                                                ? "${cont.userListingModelList[index].gallery?.first}"
                                                                : "",
                                                            imageBuilder: (context,
                                                                    imageProvider) =>
                                                                ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              child: Container(
                                                                height: 170..h,
                                                                width: 170..w,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  image:
                                                                      DecorationImage(
                                                                    image:
                                                                        imageProvider,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            placeholder: (context,
                                                                    url) =>
                                                                SizedBox(
                                                                    height: 170
                                                                      ..h,
                                                                    width: 170
                                                                      ..w,
                                                                    child: Center(
                                                                        child: CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2,
                                                                    ))),
                                                            errorWidget: (context,
                                                                    url,
                                                                    error) =>
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
                                                                // height: 85..h,
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
                                                                      child:
                                                                          Text(
                                                                        '${cont.userListingModelList[index].title}',
                                                                        maxLines:
                                                                            2,
                                                                        style: TextStyle(
                                                                            fontSize: 17
                                                                              ..sp,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color: Colors.black),
                                                                      ),
                                                                    ),
                                                                    SelectionArea(
                                                                      child:
                                                                          Text(
                                                                        "${cont.userListingModelList[index].address}",
                                                                        maxLines:
                                                                            2,
                                                                        style: TextStyle(
                                                                            fontSize: 12
                                                                              ..sp,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            color: AppColors.k0xFF403C3C),
                                                                      ),
                                                                    ),
                                                                    SelectionArea(
                                                                      child:
                                                                          Text(
                                                                        cont.userListingModelList[index].subSubCategory !=
                                                                                null
                                                                            ? "${cont.userListingModelList[index].subSubCategory?.name}"
                                                                            : cont.userListingModelList[index].subCategory != null
                                                                                ? "${cont.userListingModelList[index].subCategory?.name}"
                                                                                : "${cont.userListingModelList[index].category?.name}",
                                                                        maxLines:
                                                                            2,
                                                                        style: TextStyle(
                                                                            fontSize: 12
                                                                              ..sp,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            color: AppColors.k0xFF403C3C),
                                                                      ),
                                                                    ),
                                                                    SelectionArea(
                                                                      child:
                                                                          Text(
                                                                        cont.userListingModelList[index].price == "0" ||
                                                                                cont.userListingModelList[index].price == null
                                                                            ? ""
                                                                            : "${PriceFormatter().formatNumber(int.parse(cont.userListingModelList[index].price.toString()))} ${cont.userListingModelList[index].currency == "null" ? 'USD' : cont.userListingModelList[index].currency}",
                                                                        maxLines:
                                                                            1,
                                                                        style: TextStyle(
                                                                            fontSize: 16
                                                                              ..sp,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color: AppColors.k0xFF0254B8),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    .37,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Container(
                                                                      height: 35
                                                                        ..h,
                                                                      width:
                                                                          60.w,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        border: Border.all(
                                                                            color:
                                                                                AppColors.k0xFF0254B8),
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                      ),
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          cont.listingModel =
                                                                              cont.userListingModelList[index];
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                builder: (context) => Post(
                                                                                  isUpdate: true,
                                                                                ),
                                                                              ));
                                                                        },
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            'Edit'.tr,
                                                                            style: TextStyle(
                                                                                fontSize: 16..sp,
                                                                                fontWeight: FontWeight.w600,
                                                                                color: AppColors.k0xFF0254B8),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      height: 35
                                                                        ..h,
                                                                      width:
                                                                          60.w,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.red),
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                      ),
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          cont.listingModel =
                                                                              cont.userListingModelList[index];
                                                                          showDialog(
                                                                              context: context,
                                                                              builder: (context) {
                                                                                return deleteListing(index);
                                                                              });
                                                                        },
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            'Delete'.tr,
                                                                            style: TextStyle(
                                                                                fontSize: 16..sp,
                                                                                fontWeight: FontWeight.w600,
                                                                                color: Colors.red),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                const BecomeVendor(),
                                                                      ));
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 35..h,
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
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      cont.isListing =
                                                                          1;
                                                                      cont.listingModel =
                                                                          cont.userListingModelList[
                                                                              index];
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                const FrameScreen(),
                                                                          ));
                                                                    },
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        'View Details'
                                                                            .tr,
                                                                        style: TextStyle(
                                                                            fontSize: 16
                                                                              ..sp,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color: AppColors.k0xFF0254B8),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else {
                                              return SizedBox();
                                            }
                                          },
                                          itemCount:
                                              cont.userListingModelList.length,
                                        ),
                                      ),
                                    ],
                                  ),
                            cont.userListingModelList.isEmpty
                                ? Container(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/icons/list_icon.webp',
                                          height: 150,
                                          width: 150,
                                        ),
                                        SizedBox(
                                          height: 30..h,
                                        ),
                                        Text(
                                          'Your listings will live here'.tr,
                                          style: TextStyle(
                                              fontSize: 21,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.black),
                                        ),
                                        SizedBox(
                                          height: 20..h,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            authCont.currentIndexBottomAppBar =
                                                2;
                                            authCont.update();
                                          },
                                          child: MyButton(text: 'List Now'.tr),
                                        )
                                      ],
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        text: cont.userListingModelList
                                                    .length ==
                                                0
                                            ? "0 Listing".tr
                                            : "${cont.userListingModelList.length} ${"Listings".tr}",
                                        fontSize: 16.sp,
                                      ),
                                      SizedBox(height: 4),
                                      Expanded(
                                        child: ListView.separated(
                                          itemBuilder: (context, index) {
                                            int isBusiness =
                                                cont.isBusinessAccount ? 1 : 0;
                                            if (cont.userListingModelList[index]
                                                    .businessStatus ==
                                                "${isBusiness}") {
                                              return Container(
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      height: 170..h,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
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
                                                                            .userListingModelList[
                                                                                index]
                                                                            .gallery !=
                                                                        null &&
                                                                    cont
                                                                        .userListingModelList[
                                                                            index]
                                                                        .gallery!
                                                                        .isNotEmpty
                                                                ? "${cont.userListingModelList[index].gallery?.first}"
                                                                : "",
                                                            imageBuilder: (context,
                                                                    imageProvider) =>
                                                                ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              child: Container(
                                                                height: 170..h,
                                                                width: 170..w,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  image:
                                                                      DecorationImage(
                                                                    image:
                                                                        imageProvider,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            placeholder: (context,
                                                                    url) =>
                                                                SizedBox(
                                                                    height: 170
                                                                      ..h,
                                                                    width: 170
                                                                      ..w,
                                                                    child: Center(
                                                                        child: CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2,
                                                                    ))),
                                                            errorWidget: (context,
                                                                    url,
                                                                    error) =>
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
                                                                height: 85..h,
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
                                                                      child:
                                                                          Text(
                                                                        '${cont.userListingModelList[index].title}',
                                                                        maxLines:
                                                                            2,
                                                                        style: TextStyle(
                                                                            fontSize: 17
                                                                              ..sp,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color: Colors.black),
                                                                      ),
                                                                    ),
                                                                    SelectionArea(
                                                                      child:
                                                                          Text(
                                                                        "${cont.userListingModelList[index].address}",
                                                                        maxLines:
                                                                            1,
                                                                        style: TextStyle(
                                                                            fontSize: 13
                                                                              ..sp,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            color: AppColors.k0xFF403C3C),
                                                                      ),
                                                                    ),
                                                                    SelectionArea(
                                                                      child:
                                                                          Text(
                                                                        cont.userListingModelList[index].subSubCategory !=
                                                                                null
                                                                            ? "${cont.userListingModelList[index].subSubCategory?.name}"
                                                                            : cont.userListingModelList[index].subCategory != null
                                                                                ? "${cont.userListingModelList[index].subCategory?.name}"
                                                                                : "${cont.userListingModelList[index].category?.name}",
                                                                        maxLines:
                                                                            1,
                                                                        style: TextStyle(
                                                                            fontSize: 15
                                                                              ..sp,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            color: AppColors.k0xFF403C3C),
                                                                      ),
                                                                    ),
                                                                    SelectionArea(
                                                                      child:
                                                                          Text(
                                                                        cont.userListingModelList[index].price == "0" ||
                                                                                cont.userListingModelList[index].price == null
                                                                            ? ""
                                                                            : "${PriceFormatter().formatNumber(int.parse(cont.userListingModelList[index].price.toString()))} ${cont.userListingModelList[index].currency ?? 'USD'}",
                                                                        maxLines:
                                                                            1,
                                                                        style: TextStyle(
                                                                            fontSize: 16
                                                                              ..sp,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color: AppColors.k0xFF0254B8),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                const BecomeVendor(),
                                                                      ));
                                                                },
                                                                child:
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
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      cont.isListing =
                                                                          11;
                                                                      cont.listingModel =
                                                                          cont.userListingModelList[
                                                                              index];
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                const FrameScreen(),
                                                                          ));
                                                                    },
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        'View Details'
                                                                            .tr,
                                                                        style: TextStyle(
                                                                            fontSize: 16
                                                                              ..sp,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color: AppColors.k0xFF0254B8),
                                                                      ),
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
                                            } else {
                                              return SizedBox();
                                            }
                                          },
                                          separatorBuilder:
                                              (BuildContext context,
                                                  int index) {
                                            int isBusiness =
                                                cont.isBusinessAccount ? 1 : 0;
                                            if (cont.userListingModelList[index]
                                                    .businessStatus ==
                                                "${isBusiness}") {
                                              return Column(
                                                children: [
                                                  SizedBox(
                                                    height: 10.h,
                                                  ),
                                                  Divider(),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                ],
                                              );
                                            } else if (cont
                                                    .userListingModelList[index]
                                                    .businessStatus ==
                                                "${isBusiness}") {
                                              return Column(
                                                children: [
                                                  SizedBox(
                                                    height: 10.h,
                                                  ),
                                                  Divider(),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                ],
                                              );
                                            } else {
                                              return SizedBox();
                                            }
                                          },
                                          itemCount:
                                              cont.userListingModelList.length,
                                        ),
                                      ),
                                    ],
                                  ),
                            cont.userListingModelList.isEmpty
                                ? Container(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/icons/no_list_icon.webp',
                                          height: 150,
                                          width: 150,
                                        ),
                                        SizedBox(
                                          height: 30..h,
                                        ),
                                        Text(
                                          'Sold Listings'.tr,
                                          style: TextStyle(
                                              fontSize: 21,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.black),
                                        ),
                                        SizedBox(
                                          height: 20..h,
                                        ),
                                        Text(
                                          'Keep track of all your sold listings in one place'
                                              .tr,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.k0xFFA9ABAC),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        text: cont.userListingModelList
                                                    .length ==
                                                0
                                            ? "0 Listing".tr
                                            : "${cont.userListingModelList.length} ${"Listings".tr}",
                                        fontSize: 16.sp,
                                      ),
                                      SizedBox(height: 4),
                                      Expanded(
                                        child: ListView.separated(
                                          itemBuilder: (context, index) {
                                            int isBusiness =
                                                cont.isBusinessAccount ? 1 : 0;
                                            if (cont.userListingModelList[index]
                                                    .businessStatus ==
                                                "${isBusiness}") {
                                              return Container(
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      height: 170..h,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
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
                                                                            .userListingModelList[
                                                                                index]
                                                                            .gallery !=
                                                                        null &&
                                                                    cont
                                                                        .userListingModelList[
                                                                            index]
                                                                        .gallery!
                                                                        .isNotEmpty
                                                                ? "${cont.userListingModelList[index].gallery?.first}"
                                                                : "",
                                                            imageBuilder: (context,
                                                                    imageProvider) =>
                                                                ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              child: Container(
                                                                height: 170..h,
                                                                width: 170..w,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  image:
                                                                      DecorationImage(
                                                                    image:
                                                                        imageProvider,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            placeholder: (context,
                                                                    url) =>
                                                                SizedBox(
                                                                    height: 170
                                                                      ..h,
                                                                    width: 170
                                                                      ..w,
                                                                    child: Center(
                                                                        child: CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2,
                                                                    ))),
                                                            errorWidget: (context,
                                                                    url,
                                                                    error) =>
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
                                                                height: 85..h,
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
                                                                      child:
                                                                          Text(
                                                                        '${cont.userListingModelList[index].title}',
                                                                        maxLines:
                                                                            2,
                                                                        style: TextStyle(
                                                                            fontSize: 17
                                                                              ..sp,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color: Colors.black),
                                                                      ),
                                                                    ),
                                                                    SelectionArea(
                                                                      child:
                                                                          Text(
                                                                        "${cont.userListingModelList[index].address}",
                                                                        maxLines:
                                                                            1,
                                                                        style: TextStyle(
                                                                            fontSize: 13
                                                                              ..sp,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            color: AppColors.k0xFF403C3C),
                                                                      ),
                                                                    ),
                                                                    SelectionArea(
                                                                      child:
                                                                          Text(
                                                                        cont.userListingModelList[index].subSubCategory !=
                                                                                null
                                                                            ? "${cont.userListingModelList[index].subSubCategory?.name}"
                                                                            : cont.userListingModelList[index].subCategory != null
                                                                                ? "${cont.userListingModelList[index].subCategory?.name}"
                                                                                : "${cont.userListingModelList[index].category?.name}",
                                                                        maxLines:
                                                                            1,
                                                                        style: TextStyle(
                                                                            fontSize: 15
                                                                              ..sp,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            color: AppColors.k0xFF403C3C),
                                                                      ),
                                                                    ),
                                                                    SelectionArea(
                                                                      child:
                                                                          Text(
                                                                        cont.userListingModelList[index].price ==
                                                                                "0"
                                                                            ? ""
                                                                            : "\$${cont.userListingModelList[index].price}",
                                                                        maxLines:
                                                                            1,
                                                                        style: TextStyle(
                                                                            fontSize: 16
                                                                              ..sp,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color: AppColors.k0xFF0254B8),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                const BecomeVendor(),
                                                                      ));
                                                                },
                                                                child:
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
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      cont.isListing =
                                                                          11;
                                                                      cont.listingModel =
                                                                          cont.userListingModelList[
                                                                              index];
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                const FrameScreen(),
                                                                          ));
                                                                    },
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        'View Details'
                                                                            .tr,
                                                                        style: TextStyle(
                                                                            fontSize: 16
                                                                              ..sp,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color: AppColors.k0xFF0254B8),
                                                                      ),
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
                                            } else {
                                              return SizedBox();
                                            }
                                          },
                                          itemCount:
                                              cont.userListingModelList.length,
                                          separatorBuilder:
                                              (BuildContext context,
                                                  int index) {
                                            int isBusiness =
                                                cont.isBusinessAccount ? 1 : 0;
                                            if (cont.userListingModelList[index]
                                                    .businessStatus ==
                                                "${isBusiness}") {
                                              return Column(
                                                children: [
                                                  SizedBox(
                                                    height: 10.h,
                                                  ),
                                                  Divider(),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                ],
                                              );
                                            } else if (cont
                                                    .userListingModelList[index]
                                                    .businessStatus ==
                                                "${isBusiness}") {
                                              return Column(
                                                children: [
                                                  SizedBox(
                                                    height: 10.h,
                                                  ),
                                                  Divider(),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                ],
                                              );
                                            } else {
                                              return SizedBox();
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ));
                })
              ],
            ),
          ),
        ),
      ),
    );
  }

  deleteListing(int index) {
    return AlertDialog(
      title: Text('Delete'.tr),
      content: Text('Are you sure you want to delete this item?'.tr),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Cancel'.tr),
        ),
        TextButton(
          onPressed: () async {
            bool isDeleted = await homeCont.deleteListing();
            Navigator.of(context).pop();
            isDeleted ? homeCont.userListingModelList.removeAt(index) : null;
            homeCont.update();
          },
          child: Text('Delete'.tr),
        ),
      ],
    );
  }
}
