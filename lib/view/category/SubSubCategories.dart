import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import 'package:venta_cuba/util/profile_list.dart';
import 'package:venta_cuba/view/Navigation%20bar/post.dart';
import 'package:venta_cuba/view/widgets/scroll_to_top_button.dart';

import '../../Controllers/auth_controller.dart';
import '../../Utils/funcations.dart';
import '../auth/login.dart';
import '../constants/Colors.dart';
import 'package:flutter_svg/svg.dart';

import '../frame/frame.dart';
import 'ShowAllListingSub.dart';
import 'package:venta_cuba/view/constants/premium_animations.dart';

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GetBuilder<HomeController>(
        builder: (cont) {
          return Stack(
            children: [
              SelectionArea(
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
                              color: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.color),
                        ),
                        SizedBox(
                          height: 45..h,
                        ),
                        Expanded(
                          child: (cont.loadingSubSubCategory.value ||
                                  cont.loadingCategory
                                      .value) // ✅ Step A: Check loading first
                              ? Center(child: CircularProgressIndicator())
                              : cont.subSubCategoriesModel?.data?.isEmpty ??
                                      true
                                  ? cont.listingModelSearchList.isEmpty &&
                                          cont.isSearchLoading.value
                                      ? Center(
                                          child: CircularProgressIndicator())
                                      : GridView.builder(
                                          itemCount: cont.listingModelSearchList
                                              .length, // ✅ Changed from listingModelList
                                          controller: cont
                                              .searchScrollController, // ✅ Changed from scrollsController
                                          shrinkWrap: true,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            childAspectRatio: 0.50.r,
                                            mainAxisSpacing: 15,
                                            crossAxisSpacing: 10,
                                          ),
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return GestureDetector(
                                                onTap: () {
                                                  cont.isListing = 0;
                                                  cont.listingModel =
                                                      cont.listingModelSearchList[
                                                          index]; // ✅ Changed
                                                  Navigator.push(
                                                      context,
                                                      PremiumPageTransitions
                                                          .slideFromRight(
                                                        const FrameScreen(),
                                                      ));
                                                },
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    10..r),
                                                        color: Theme.of(context)
                                                            .cardColor,
                                                        border: Theme.of(
                                                                        context)
                                                                    .brightness ==
                                                                Brightness.dark
                                                            ? Border.all(
                                                                color: Colors
                                                                    .white
                                                                    .withValues(
                                                                        alpha:
                                                                            0.2),
                                                                width: 1,
                                                              )
                                                            : null,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Theme.of(context)
                                                                        .brightness ==
                                                                    Brightness
                                                                        .dark
                                                                ? Colors.white
                                                                    .withValues(
                                                                        alpha:
                                                                            0.1)
                                                                : Theme.of(
                                                                        context)
                                                                    .shadowColor
                                                                    .withValues(
                                                                        alpha:
                                                                            0.1),
                                                            offset:
                                                                Offset(0, 3),
                                                            blurRadius: 6,
                                                            spreadRadius: 0,
                                                          ),
                                                        ],
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          10.r),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10.r)),
                                                              child:
                                                                  CachedNetworkImage(
                                                                height: 180..h,
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                imageUrl: cont
                                                                                .listingModelSearchList[index] // ✅ Changed
                                                                                .gallery !=
                                                                            null &&
                                                                        cont
                                                                            .listingModelSearchList[index] // ✅ Changed
                                                                            .gallery!
                                                                            .isNotEmpty
                                                                    ? "${cont.listingModelSearchList[index].gallery?.first}" // ✅ Changed
                                                                    : "",
                                                                imageBuilder:
                                                                    (context,
                                                                            imageProvider) =>
                                                                        Container(
                                                                  height: 180
                                                                    ..h,
                                                                  width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
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
                                                                placeholder: (context,
                                                                        url) =>
                                                                    SizedBox(
                                                                        height:
                                                                            180
                                                                              ..h,
                                                                        width: MediaQuery.of(context)
                                                                            .size
                                                                            .width,
                                                                        child: Center(
                                                                            child: CircularProgressIndicator(
                                                                          strokeWidth:
                                                                              2,
                                                                        ))),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Icon(Icons
                                                                        .error),
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Theme.of(
                                                                      context)
                                                                  .cardColor,
                                                              borderRadius: BorderRadius.only(
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          10.r),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          10.r)),
                                                            ),
                                                            child: Column(
                                                              children: [
                                                                SizedBox(
                                                                  height: 20.h,
                                                                  child: Text(
                                                                    cont
                                                                            .listingModelSearchList[index] // ✅ Changed
                                                                            .title ??
                                                                        "",
                                                                    maxLines: 2,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: TextStyle(
                                                                        fontSize: 17
                                                                          ..sp,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        color: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyLarge
                                                                            ?.color),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 16.h,
                                                                  child: Text(
                                                                    '${cont.listingModelSearchList[index].address ?? ""}', // ✅ Changed
                                                                    style: TextStyle(
                                                                        fontSize: 13
                                                                          ..sp,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        color: AppColors
                                                                            .k0xFF403C3C),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 2..h,
                                                                ),
                                                                SizedBox(
                                                                  height: 16.h,
                                                                  child:
                                                                      SelectionArea(
                                                                    child: Text(
                                                                      cont
                                                                                  .listingModelSearchList[index] // ✅ Changed
                                                                                  .price ==
                                                                              "0"
                                                                          ? " "
                                                                          : "${PriceFormatter().formatNumber(int.parse(cont.listingModelSearchList[index].price ?? '0'))}\$ ${PriceFormatter().getCurrency(cont.listingModelSearchList[index].currency)}", // ✅ Changed
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: TextStyle(
                                                                          fontSize: 14
                                                                            ..sp,
                                                                          fontWeight: FontWeight
                                                                              .w600,
                                                                          color:
                                                                              AppColors.k0xFF0254B8),
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
                                                            if (authCont.user
                                                                    ?.email ==
                                                                "") {
                                                              Navigator.push(
                                                                  context,
                                                                  PremiumPageTransitions
                                                                      .slideFromBottom(
                                                                          Login()));
                                                            } else {
                                                              cont.listingModel =
                                                                  cont.listingModelSearchList[
                                                                      index]; // ✅ Changed
                                                              cont
                                                                          .listingModelSearchList[
                                                                              index] // ✅ Changed
                                                                          .isFavorite ==
                                                                      "0"
                                                                  ? cont
                                                                      .listingModelSearchList[
                                                                          index] // ✅ Changed
                                                                      .isFavorite = "1"
                                                                  : cont
                                                                      .listingModelSearchList[index] // ✅ Changed
                                                                      .isFavorite = "0";
                                                              cont.update();
                                                              bool isAddedF =
                                                                  await cont
                                                                      .favouriteItem();
                                                              if (isAddedF) {
                                                                errorAlertToast(
                                                                    "Successfully"
                                                                        .tr);
                                                              } else {
                                                                cont
                                                                            .listingModelSearchList[
                                                                                index] // ✅ Changed
                                                                            .isFavorite ==
                                                                        "0"
                                                                    ? cont
                                                                        .listingModelSearchList[
                                                                            index] // ✅ Changed
                                                                        .isFavorite = "1"
                                                                    : cont
                                                                        .listingModelSearchList[index] // ✅ Changed
                                                                        .isFavorite = "0";
                                                              }
                                                            }
                                                          },
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    10),
                                                            height: 43..h,
                                                            width: 43..w,
                                                            decoration: BoxDecoration(
                                                                color: Theme.of(
                                                                        context)
                                                                    .cardColor,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(21.5
                                                                          ..r)),
                                                            child: SvgPicture
                                                                .asset(
                                                              'assets/icons/heart1.svg',
                                                              colorFilter: ColorFilter.mode(
                                                                  cont
                                                                              .listingModelSearchList[index] // ✅ Changed
                                                                              .isFavorite ==
                                                                          '0'
                                                                      ? AppColors.k0xFF9F9F9F
                                                                      : AppColors.k0xFFFB0808,
                                                                  BlendMode.srcIn),
                                                            ),
                                                          ),
                                                        ))
                                                  ],
                                                ));
                                          },
                                        )
                                  : ListView.separated(
                                      itemCount: cont.subSubCategoriesModel
                                              ?.data?.length ??
                                          0,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                            onTap: () {
                                              cont.selectedSubSubCategory = cont
                                                  .subSubCategoriesModel
                                                  ?.data?[index];
                                              cont.currentSearchPage.value = 1;
                                              cont.hasMoreSearch.value = true;
                                              cont.listingModelSearchList
                                                  .clear();
                                              cont.getListingSearch();
                                              Navigator.push(
                                                  context,
                                                  PremiumPageTransitions
                                                      .slideFromRight(
                                                          ShowAllListingSub()));
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
              ),
              ScrollToTopButton(
                scrollController: cont.searchScrollController,
              ),
            ],
          );
        },
      ),
    );
  }
}
