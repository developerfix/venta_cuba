import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import 'package:venta_cuba/util/my_button.dart';
import 'package:venta_cuba/view/Chat/custom_text.dart';
import 'package:venta_cuba/view/Navigation%20bar/post.dart';
import 'package:venta_cuba/view/constants/Colors.dart';
import 'package:flutter_svg/svg.dart';

import '../../Controllers/auth_controller.dart';
import '../../Utils/funcations.dart';
import '../frame/frame.dart';

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
    print('🔥 Listings initState() called');
    homeCont.listingLoading = true;

    // Ensure we start with active tab
    homeCont.status = "active";
    homeCont.soldStatus = null;

    homeCont.getSellerListingByStatus();
    super.initState();
  }

  @override
  void dispose() {
    homeCont.listingLoading = true;
    homeCont.status = "active";
    homeCont.soldStatus = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).iconTheme.color ?? Colors.grey,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    // Notification icon removed
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
                    print('🔥 Tab switched to index: $value');
                    homeCont.listingLoading = true;
                    homeCont.update();
                    if (value == 0) {
                      print('🔥 Switching to Active tab');
                      homeCont.status = "active";
                      homeCont.soldStatus = null;
                      homeCont.getSellerListingByStatus();
                    } else if (value == 1) {
                      print('🔥 Switching to Inactive tab');
                      homeCont.status = "inactive";
                      homeCont.soldStatus = null;
                      homeCont.getSellerListingByStatus();
                    } else {
                      print('🔥 Switching to Sold tab');
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
                                        cont.bussinessPostCount == 0 ||
                                    !authCont.isBusinessAccount &&
                                        cont.personalAcountPost == 0
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
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          authCont.isBusinessAccount
                                              ? CustomText(
                                                  text: cont.bussinessPostCount ==
                                                          0
                                                      ? "0 Listing".tr
                                                      : "${cont.bussinessPostCount} ${"Listings".tr}",
                                                  fontSize: 16.sp,
                                                )
                                              : CustomText(
                                                  text: cont.personalAcountPost ==
                                                          0
                                                      ? "0 Listing".tr
                                                      : "${cont.personalAcountPost} ${"Listings".tr}",
                                                  fontSize: 16.sp,
                                                ),
                                          if ((authCont.isBusinessAccount &&
                                                  cont.bussinessPostCount >
                                                      0) ||
                                              (!authCont.isBusinessAccount &&
                                                  cont.personalAcountPost > 0))
                                            InkWell(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      deleteAllListingsDialog(),
                                                );
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12.w,
                                                    vertical: 6.h),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.red),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'Delete All'.tr,
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
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
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                            fontSize: 17
                                                                              ..sp,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color: AppColors.textPrimary),
                                                                      ),
                                                                    ),
                                                                    SelectionArea(
                                                                      child:
                                                                          Text(
                                                                        "${cont.userListingModelList[index].address}",
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                            fontSize: 12
                                                                              ..sp,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            color: AppColors.textSecondary),
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
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                            fontSize: 12
                                                                              ..sp,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            color: AppColors.textSecondary),
                                                                      ),
                                                                    ),
                                                                    SelectionArea(
                                                                      child:
                                                                          Text(
                                                                        cont.userListingModelList[index].price == "0" ||
                                                                                cont.userListingModelList[index].price == null
                                                                            ? ""
                                                                            : "${PriceFormatter().formatNumber(int.parse(cont.userListingModelList[index].price.toString()))}\$ ${PriceFormatter().getCurrency(cont.userListingModelList[index].currency)}",
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                            fontSize: 12
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
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
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
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
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
                                                                                const FrameScreen(),
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
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
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
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          authCont.isBusinessAccount
                                              ? CustomText(
                                                  text: cont.bussinessPostCount ==
                                                          0
                                                      ? "0 Listing".tr
                                                      : "${cont.bussinessPostCount} ${"Listings".tr}",
                                                  fontSize: 16.sp,
                                                )
                                              : CustomText(
                                                  text: cont.personalAcountPost ==
                                                          0
                                                      ? "0 Listing".tr
                                                      : "${cont.personalAcountPost} ${"Listings".tr}",
                                                  fontSize: 16.sp,
                                                ),
                                          if ((authCont.isBusinessAccount &&
                                                  cont.bussinessPostCount >
                                                      0) ||
                                              (!authCont.isBusinessAccount &&
                                                  cont.personalAcountPost > 0))
                                            InkWell(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      deleteAllListingsDialog(),
                                                );
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12.w,
                                                    vertical: 6.h),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.red),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'Delete All'.tr,
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
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
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                            fontSize: 17
                                                                              ..sp,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color: AppColors.textPrimary),
                                                                      ),
                                                                    ),
                                                                    SelectionArea(
                                                                      child:
                                                                          Text(
                                                                        "${cont.userListingModelList[index].address}",
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        maxLines:
                                                                            1,
                                                                        style: TextStyle(
                                                                            fontSize: 12
                                                                              ..sp,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            color: AppColors.textSecondary),
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
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                            fontSize: 12
                                                                              ..sp,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            color: AppColors.textSecondary),
                                                                      ),
                                                                    ),
                                                                    SelectionArea(
                                                                      child:
                                                                          Text(
                                                                        cont.userListingModelList[index].price == "0" ||
                                                                                cont.userListingModelList[index].price == null
                                                                            ? ""
                                                                            : "${PriceFormatter().formatNumber(int.parse(cont.userListingModelList[index].price.toString()))}\$ ${PriceFormatter().getCurrency(cont.userListingModelList[index].currency)}",
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                            fontSize: 12
                                                                              ..sp,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color: AppColors.k0xFF0254B8),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Column(
                                                                children: [
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) =>
                                                                                deleteListing(index),
                                                                      );
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height: 35
                                                                        ..h,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          .37,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.red),
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                      ),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          'Delete'
                                                                              .tr,
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize: 14
                                                                              ..sp,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color:
                                                                                Colors.red,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          8.h),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                const FrameScreen(),
                                                                          ));
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height: 35
                                                                        ..h,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          .37,
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
                                                                          cont.isListing =
                                                                              11;
                                                                          cont.listingModel =
                                                                              cont.userListingModelList[index];
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                builder: (context) => const FrameScreen(),
                                                                              ));
                                                                        },
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            'View Details'.tr,
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style: TextStyle(
                                                                                fontSize: 14..sp,
                                                                                fontWeight: FontWeight.w600,
                                                                                color: AppColors.k0xFF0254B8),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
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
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          authCont.isBusinessAccount
                                              ? CustomText(
                                                  text: cont.bussinessPostCount ==
                                                          0
                                                      ? "0 Listing".tr
                                                      : "${cont.bussinessPostCount} ${"Listings".tr}",
                                                  fontSize: 16.sp,
                                                )
                                              : CustomText(
                                                  text: cont.personalAcountPost ==
                                                          0
                                                      ? "0 Listing".tr
                                                      : "${cont.personalAcountPost} ${"Listings".tr}",
                                                  fontSize: 16.sp,
                                                ),
                                          if ((authCont.isBusinessAccount &&
                                                  cont.bussinessPostCount >
                                                      0) ||
                                              (!authCont.isBusinessAccount &&
                                                  cont.personalAcountPost > 0))
                                            InkWell(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      deleteAllListingsDialog(),
                                                );
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12.w,
                                                    vertical: 6.h),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.red),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'Delete All'.tr,
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
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
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                            fontSize: 17
                                                                              ..sp,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color: AppColors.textPrimary),
                                                                      ),
                                                                    ),
                                                                    SelectionArea(
                                                                      child:
                                                                          Text(
                                                                        "${cont.userListingModelList[index].address}",
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                            fontSize: 12
                                                                              ..sp,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            color: AppColors.textSecondary),
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
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                            fontSize: 12
                                                                              ..sp,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            color: AppColors.textSecondary),
                                                                      ),
                                                                    ),
                                                                    SelectionArea(
                                                                      child:
                                                                          Text(
                                                                        cont.userListingModelList[index].price ==
                                                                                "0"
                                                                            ? ""
                                                                            : "${PriceFormatter().formatNumber(int.parse(cont.userListingModelList[index].price ?? '0'))}\$ ${PriceFormatter().getCurrency(cont.userListingModelList[index].currency)}",
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                            fontSize: 12
                                                                              ..sp,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color: AppColors.k0xFF0254B8),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Column(
                                                                children: [
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) =>
                                                                                deleteListing(index),
                                                                      );
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height: 35
                                                                        ..h,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          .37,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.red),
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                      ),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          'Delete'
                                                                              .tr,
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize: 14
                                                                              ..sp,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color:
                                                                                Colors.red,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          8.h),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                const FrameScreen(),
                                                                          ));
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height: 35
                                                                        ..h,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          .37,
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
                                                                          cont.isListing =
                                                                              11;
                                                                          cont.listingModel =
                                                                              cont.userListingModelList[index];
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                builder: (context) => const FrameScreen(),
                                                                              ));
                                                                        },
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            'View Details'.tr,
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style: TextStyle(
                                                                                fontSize: 14..sp,
                                                                                fontWeight: FontWeight.w600,
                                                                                color: AppColors.k0xFF0254B8),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
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
            // Prevent multiple taps
            if (homeCont.isLoading) return;

            try {
              // Validate prerequisites
              if (homeCont.listingModel?.id == null) {
                Navigator.of(context).pop();
                errorAlertToast('Error: Invalid listing data. Please refresh and try again.'.tr);
                return;
              }

              // Check if context is still mounted before proceeding
              if (!mounted) return;

              // Store listing info before any async operations
              final listingIdToDelete = homeCont.listingModel!.id;
              final listingIndex = index;

              // Set loading state
              homeCont.isLoading = true;

              // Close dialog first to prevent UI issues
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }

              // Ensure context is still valid after async operation
              if (!mounted) {
                homeCont.isLoading = false;
                return;
              }

              // Show loading dialog with timeout protection
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => WillPopScope(
                  onWillPop: () async => false,
                  child: Dialog(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 20),
                          Text('Deleting...'.tr),
                        ],
                      ),
                    ),
                  ),
                ),
              );

              // Add timeout to prevent indefinite loading
              bool isDeleted = await homeCont.deleteListing().timeout(
                Duration(seconds: 30),
                onTimeout: () {
                  print('Delete operation timed out');
                  return false;
                },
              );

              // Ensure context is still valid before UI operations
              if (!mounted) {
                homeCont.isLoading = false;
                return;
              }

              // Close loading dialog safely
              try {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              } catch (e) {
                print('Error closing loading dialog: $e');
              }

              if (isDeleted) {
                // Double-check list validity and bounds
                if (homeCont.userListingModelList.isNotEmpty &&
                    listingIndex >= 0 &&
                    listingIndex < homeCont.userListingModelList.length) {

                  // Remove by ID for safety, with additional validation
                  final initialCount = homeCont.userListingModelList.length;
                  homeCont.userListingModelList
                      .removeWhere((listing) => listing.id == listingIdToDelete);

                  // Verify removal actually happened
                  final finalCount = homeCont.userListingModelList.length;
                  if (finalCount < initialCount) {
                    // Update the counters based on account type
                    if (homeCont.isBusinessAccount) {
                      homeCont.bussinessPostCount = homeCont.userListingModelList
                          .where((listing) => listing.businessStatus == "1")
                          .length;
                    } else {
                      homeCont.personalAcountPost = homeCont.userListingModelList
                          .where((listing) => listing.businessStatus == "0")
                          .length;
                    }

                    // Schedule UI update for next frame to prevent conflicts
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        homeCont.update();
                      }
                    });

                    if (mounted) {
                      errorAlertToast('Listing deleted successfully'.tr);
                    }
                  } else {
                    if (mounted) {
                      errorAlertToast('Item may have been already deleted'.tr);
                    }
                  }
                } else {
                  print('Warning: List bounds invalid during delete operation');
                  // Refresh the entire list to sync state
                  await homeCont.getSellerListingByStatus();
                  if (mounted) {
                    errorAlertToast('Listing deleted - list refreshed'.tr);
                  }
                }
              } else {
                if (mounted) {
                  errorAlertToast('Failed to delete listing. Please try again.'.tr);
                }
              }
            } catch (e) {
              print('Delete operation error: $e');

              // Close any open dialogs safely
              try {
                while (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              } catch (dialogError) {
                print('Error closing dialogs: $dialogError');
              }

              if (mounted) {
                errorAlertToast('An error occurred while deleting. Please try again.'.tr);
              }
            } finally {
              // Always reset loading state
              homeCont.isLoading = false;
            }
          },
          child: Text('Delete'.tr),
        ),
      ],
    );
  }

  Widget deleteAllListingsDialog() {
    return AlertDialog(
      title: Text('Delete All'.tr),
      content: Text('Are you sure you want to delete all listings?'.tr),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Cancel'.tr),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop(); // Close the dialog first

            // Show loading dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                content: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text(
                      'Deleting all listings...'.tr,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12..h,
                      ),
                    ),
                  ],
                ),
              ),
            );

            bool isDeleted = await homeCont.deleteAllListings();
            Navigator.of(context).pop(); // Close loading dialog

            if (isDeleted) {
              errorAlertToast('All listings deleted successfully'.tr);
            } else {
              errorAlertToast(
                  'Failed to delete some listings. Please try again.'.tr);
            }
          },
          child: Text('Delete'.tr, style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
