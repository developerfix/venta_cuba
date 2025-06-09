import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import 'package:venta_cuba/util/profile_list.dart';
import 'package:venta_cuba/view/Navigation%20bar/post.dart';

import '../../Controllers/auth_controller.dart';
import '../../Utils/funcations.dart';
import '../auth/login.dart';
import '../constants/Colors.dart';
import 'package:flutter_svg/svg.dart';

import '../frame/frame.dart';
import 'ShowAllListingSub.dart';

class SubSubCategories extends StatefulWidget {
  const SubSubCategories({super.key});

  @override
  State<SubSubCategories> createState() => _SubSubCategoriesState();
}

class _SubSubCategoriesState extends State<SubSubCategories> {
  final homeCont = Get.put(HomeController());
  final authCont = Get.put(AuthController());
  @override
  void dispose() {
    homeCont.selectedSubSubCategory = null;
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: GetBuilder<HomeController>(
        builder: (cont) {
          return SelectionArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
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
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.end,
                        //   children: [
                        //     SvgPicture.asset(
                        //       'assets/icons/heartSimple.svg',
                        //     ),
                        //     SizedBox(
                        //       width: 20..w,
                        //     ),
                        //     SvgPicture.asset(
                        //         'assets/icons/notificationSimple.svg'),
                        //   ],
                        // ),
                      ],
                    ),
                    SizedBox(
                      height: 20..h,
                    ),
                    Text(
                      '${"Category of".tr} ${cont.selectedSubCategory?.name}',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black),
                    ),
                    SizedBox(
                      height: 45..h,
                    ),
                    Expanded(
                      child: cont.subSubCategoriesModel?.data?.isEmpty ?? true
                          ? GridView.builder(
                              itemCount: cont.listingModelList.length,
                              controller: cont.searchScrollController,
                              // physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.50.r,
                                mainAxisSpacing: 25,
                                crossAxisSpacing: 25,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                    onTap: () {
                                      cont.isListing = 0;
                                      cont.listingModel =
                                          cont.listingModelList[index];
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const FrameScreen(),
                                          ));
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          // height: 280..h,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10..r),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                // Shadow color
                                                offset: Offset(0, 3),
                                                // Shadow offset
                                                blurRadius: 6,
                                                // Shadow blur radius
                                                spreadRadius:
                                                    0, // Shadow spread radius
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                height: 180.h,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10.r),
                                                          topRight:
                                                              Radius.circular(
                                                                  10.r)),
                                                  child: CachedNetworkImage(
                                                    height: 180..h,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    imageUrl: cont
                                                                    .listingModelList[
                                                                        index]
                                                                    .gallery !=
                                                                null &&
                                                            cont
                                                                .listingModelList[
                                                                    index]
                                                                .gallery!
                                                                .isNotEmpty
                                                        ? "${cont.listingModelList[index].gallery?.first}"
                                                        : "",
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      height: 180..h,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    placeholder: (context,
                                                            url) =>
                                                        SizedBox(
                                                            height: 180..h,
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            child: Center(
                                                                child:
                                                                    CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                            ))),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                // height: 65..h,
                                                color: Colors.white,
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      height: 20.h,
                                                      child: Text(
                                                        cont
                                                                .listingModelList[
                                                                    index]
                                                                .title ??
                                                            "",
                                                        maxLines: 2,
                                                        textAlign:
                                                            TextAlign.center,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 17..sp,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 16.h,
                                                      child: Text(
                                                        '${cont.listingModelList[index].address ?? ""}',
                                                        style: TextStyle(
                                                            fontSize: 13..sp,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: AppColors
                                                                .k0xFF403C3C),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 2..h,
                                                    ),
                                                    SizedBox(
                                                      height: 16.h,
                                                      child: SelectionArea(
                                                        child: Text(
                                                          cont.listingModelList[index]
                                                                      .price ==
                                                                  "0"
                                                              ? " "
                                                              : "${PriceFormatter().formatNumber(int.parse(cont.listingModelList[index].price ?? '0'))}\$ ${PriceFormatter().getCurrency(cont.listingModelList[index].currency)}",
                                                          textAlign:
                                                              TextAlign.center,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 16..sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: AppColors
                                                                  .k0xFF0254B8),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 5.h,
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: 10..h,
                                          right: 10..w,
                                          child: InkWell(
                                            onTap: () async {
                                              if (authCont.user?.email == "") {
                                                Get.to(Login());
                                              } else {
                                                cont.listingModel = cont
                                                    .listingModelList[index];
                                                cont.listingModelList[index]
                                                            .isFavorite ==
                                                        "0"
                                                    ? cont
                                                        .listingModelList[index]
                                                        .isFavorite = "1"
                                                    : cont
                                                        .listingModelList[index]
                                                        .isFavorite = "0";
                                                cont.update();
                                                bool isAddedF =
                                                    await cont.favouriteItem();
                                                if (isAddedF) {
                                                  errorAlertToast(
                                                      "Successfully".tr);
                                                } else {
                                                  cont.listingModelList[index]
                                                              .isFavorite ==
                                                          "0"
                                                      ? cont
                                                          .listingModelList[
                                                              index]
                                                          .isFavorite = "1"
                                                      : cont
                                                          .listingModelList[
                                                              index]
                                                          .isFavorite = "0";
                                                }
                                              }
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(10),
                                              height: 43..h,
                                              width: 43..w,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          21.5..r)),
                                              child: SvgPicture.asset(
                                                'assets/icons/heart1.svg',
                                                color:
                                                    cont.listingModelList[index]
                                                                .isFavorite ==
                                                            '0'
                                                        ? Colors.grey
                                                        : Colors.red,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ));
                              },
                            )
                          : ListView.separated(
                              itemCount:
                                  cont.subSubCategoriesModel?.data?.length ?? 0,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                    onTap: () {
                                      cont.selectedSubSubCategory = cont
                                          .subSubCategoriesModel?.data?[index];
                                      cont.currentPage.value = 1;
                                      cont.hasMore.value = true;
                                      // cont.getListing();
                                      cont.getListingSearch();
                                      cont.listingModelList.clear();
                                      Get.to(ShowAllListingSub());
                                    },
                                    child: ProfileList(
                                        text: cont.subSubCategoriesModel
                                                ?.data?[index].name ??
                                            ""));
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return SizedBox(
                                  height: 20..h,
                                );
                              },
                            ),
                    ),
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
