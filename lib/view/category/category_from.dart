import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import 'package:venta_cuba/util/profile_list.dart';
import 'package:venta_cuba/view/Navigation%20bar/post.dart';

import '../../Utils/funcations.dart';
import '../Chat/custom_text.dart';
import '../Navigation bar/search.dart';
import '../auth/login.dart';
import '../constants/Colors.dart';
import 'package:flutter_svg/svg.dart';

import '../frame/frame.dart';
import 'package:venta_cuba/view/constants/premium_animations.dart';

class CategoryFrom extends StatefulWidget {
  const CategoryFrom({super.key});

  @override
  State<CategoryFrom> createState() => _CategoryFromState();
}

class _CategoryFromState extends State<CategoryFrom> {
  final authCont = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: GetBuilder<HomeController>(
          builder: (cont) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      ],
                    ),
                    SizedBox(
                      height: 20..h,
                    ),
                    Text(
                      '${"Category of".tr} ${cont.selectedCategory?.name}',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color:
                              Theme.of(context).textTheme.headlineSmall?.color),
                    ),
                    SizedBox(height: 20..h),
                    GestureDetector(
                      onTap: () {
                        cont.selectedSubCategory = null;
                        cont.selectedSubSubCategory = null;
                        cont.listingModelList.clear();
                        cont.isSearchLoading.value = false;
                        cont.listingModelSearchList.clear();
                        cont.update();
                        cont.getListingSearch(isLoadMore: false);
                        Get.off(Search(isSearchFrom: 1));
                      },
                      child: CustomText(
                        text: "View all".tr,
                        fontSize: 16.sp,
                        fontColor: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 20..h),
                    Expanded(
                      child: cont.subCategoriesModel!.data!.isEmpty
                          ? GridView.builder(
                              itemCount: cont.listingModelSearchList.length,
                              // physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.50.r,
                                mainAxisSpacing: 15,
                                crossAxisSpacing: 20,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                    onTap: () {
                                      cont.isListing = 0;
                                      cont.listingModel =
                                          cont.listingModelList[index];
                                      Navigator.push(
                                          context,
                                          PremiumPageTransitions.slideFromRight(
                                                const FrameScreen(),
                                          ));
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          //  height: 280..h,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10..r),
                                            color: Theme.of(context).cardColor,
                                            border: Theme.of(context)
                                                        .brightness ==
                                                    Brightness.dark
                                                ? Border.all(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.2),
                                                    width: 1,
                                                  )
                                                : null,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                        .withValues(alpha: 0.1)
                                                    : Theme.of(context)
                                                        .shadowColor
                                                        .withValues(alpha: 0.1),
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
                                              Expanded(
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
                                                //height: 65..h,
                                                color:
                                                    Theme.of(context).cardColor,
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
                                                            color: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyLarge
                                                                ?.color),
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
                                                              : "${PriceFormatter().formatNumber(int.parse(cont.listingModelList[index].price ?? '0'))}\$ ${PriceFormatter().getCurrency(cont.listingModelList[index].currency)}}",
                                                          textAlign:
                                                              TextAlign.center,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 14..sp,
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
                                                  // Sync with other lists
                                                  String itemId = cont
                                                          .listingModelList[
                                                              index]
                                                          .itemId ??
                                                      "";
                                                  String newFavoriteStatus =
                                                      cont
                                                              .listingModelList[
                                                                  index]
                                                              .isFavorite ??
                                                          "0";

                                                  // Update search results
                                                  for (int i = 0;
                                                      i <
                                                          cont.listingModelSearchList
                                                              .length;
                                                      i++) {
                                                    if (cont
                                                            .listingModelSearchList[
                                                                i]
                                                            .itemId ==
                                                        itemId) {
                                                      cont
                                                              .listingModelSearchList[
                                                                  i]
                                                              .isFavorite =
                                                          newFavoriteStatus;
                                                      break;
                                                    }
                                                  }

                                                  // Update favorites list
                                                  if (newFavoriteStatus ==
                                                      "0") {
                                                    cont.userFavouriteListingModelList
                                                        .removeWhere(
                                                            (favItem) =>
                                                                favItem
                                                                    .itemId ==
                                                                itemId);
                                                  }

                                                  cont.update();
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
                                                  color: Theme.of(context)
                                                      .cardColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          21.5..r)),
                                              child: SvgPicture.asset(
                                                'assets/icons/heart1.svg',
                                                colorFilter: ColorFilter.mode(
                                                    cont.listingModelList[index]
                                                                .isFavorite ==
                                                            '0'
                                                        ? AppColors.k0xFF9F9F9F
                                                        : AppColors.k0xFFFB0808,
                                                    BlendMode.srcIn),
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
                                  cont.subCategoriesModel?.data?.length ?? 0,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                    onTap: () {
                                      cont.selectedSubCategory =
                                          cont.subCategoriesModel?.data?[index];
                                      cont.isNavigate = true;
                                      cont.getSubSubCategories();
                                    },
                                    child: ProfileList(
                                        text: cont.subCategoriesModel
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
            );
          },
        ),
      ),
    );
  }
}
