import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import 'package:venta_cuba/Controllers/homepage_controller.dart';
import 'package:venta_cuba/view/Chat/custom_text.dart';
import 'package:venta_cuba/view/Navigation%20bar/post.dart';
import 'package:venta_cuba/view/constants/Colors.dart';
import 'package:flutter_svg/svg.dart';
import '../../Utils/funcations.dart';
import '../auth/login.dart';
import '../frame/frame.dart';

class FavouriteListings extends StatefulWidget {
  const FavouriteListings({super.key});

  @override
  State<FavouriteListings> createState() => _FavouriteListingsState();
}

class _FavouriteListingsState extends State<FavouriteListings> {
  final authCont = Get.put(AuthController());
  final homePageCont = Get.find<HomepageController>();
  final homeCont =
      Get.find<HomeController>(); // Use existing controller instance

  void _showRemoveAllListingsDialog(BuildContext context, HomeController cont) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove All Listings'.tr),
          content: Text(
              'Are you sure you want to remove all favourite listings?'.tr),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('Cancel'.tr),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext dialogContext) {
                    return PopScope(
                      canPop: false,
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).dialogTheme.backgroundColor ??
                                    Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );

                try {
                  bool isRemoved = await cont.removeAllFavouriteListings();
                  Get.back();

                  if (isRemoved) {
                    // Reload home screen data to refresh favorite status
                    cont.getListing();
                    homePageCont.forceRefresh();

                    errorAlertToast(
                        'All favourite listings removed successfully'.tr);
                  } else {
                    errorAlertToast(
                        'Failed to remove some listings. Please try again.'.tr);
                  }
                } catch (e) {
                  Get.back();
                  errorAlertToast(
                      'Failed to remove listings. Please try again.'.tr);
                }
              },
              child: Text(
                'Remove All'.tr,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: GetBuilder<HomeController>(
          init: homeCont,
          builder: (cont) {
            return Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
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
                          'Favorite listings'.tr,
                          style: TextStyle(
                              fontSize: 21..sp,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color ??
                                  Colors.black),
                        ),
                        GestureDetector(
                          onTap: cont.userFavouriteListingModelList
                                      .isNotEmpty ==
                                  true
                              ? () {
                                  _showRemoveAllListingsDialog(context, cont);
                                }
                              : null,
                          child: Icon(
                            Icons.delete,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20..h),
                    Expanded(
                      child: cont.userFavouriteListingModelList.isEmpty
                          ? Center(child: CustomText(text: "No Data Found".tr))
                          : GridView.builder(
                              itemCount:
                                  cont.userFavouriteListingModelList.length,
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.50.r,
                                mainAxisSpacing: 15,
                                crossAxisSpacing: 10,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                final data =
                                    cont.userFavouriteListingModelList[index];
                                return GestureDetector(
                                  onTap: () {
                                    cont.isListing = 0;
                                    cont.listingModel = data;
                                    cont.sellerId = data.userId;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const FrameScreen(),
                                      ),
                                    );
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.r),
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
                                                  : Colors.grey
                                                      .withValues(alpha: 0.5),
                                              offset: Offset(0, 3),
                                              blurRadius: 6,
                                              spreadRadius: 0,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10.r),
                                                    topRight:
                                                        Radius.circular(10.r)),
                                                child: CachedNetworkImage(
                                                  height: 180..h,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  imageUrl: data.gallery !=
                                                              null &&
                                                          data.gallery!
                                                              .isNotEmpty
                                                      ? "${data.gallery?.first}"
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
                                                  placeholder: (context, url) =>
                                                      SizedBox(
                                                    height: 180..h,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                    ),
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Icon(Icons.error),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color:
                                                    Theme.of(context).cardColor,
                                                borderRadius: BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(10.r),
                                                    bottomRight:
                                                        Radius.circular(10.r)),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      height: 20.h,
                                                      child: Text(
                                                        data.title ??
                                                            "", // Use data instead of cont.listingModelList
                                                        textAlign:
                                                            TextAlign.center,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 17..sp,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              Theme.of(context)
                                                                      .textTheme
                                                                      .bodyLarge
                                                                      ?.color ??
                                                                  Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 16.h,
                                                      child: SelectionArea(
                                                        child: Text(
                                                          '${data.address ?? ""}',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 13..sp,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: AppColors
                                                                .k0xFF403C3C,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 2..h,
                                                    ),
                                                    SizedBox(
                                                      height: 16.h,
                                                      child: SelectionArea(
                                                        child: Text(
                                                          data.price == "0"
                                                              ? " "
                                                              : "${PriceFormatter().formatNumber(int.parse(data.price ?? '0'))}\$ ${PriceFormatter().getCurrency(data.currency)}",
                                                          textAlign:
                                                              TextAlign.center,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          // Use data instead of cont.listingModelList
                                                          style: TextStyle(
                                                            fontSize: 14..sp,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: AppColors
                                                                .k0xFF0254B8,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 5.h,
                                                    )
                                                  ],
                                                ),
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
                                              cont.listingModel = data;
                                              String originalFavoriteStatus =
                                                  data.isFavorite ?? "0";

                                              // Optimistic update
                                              data.isFavorite == "0"
                                                  ? data.isFavorite = "1"
                                                  : data.isFavorite = "0";

                                              cont.favouriteId =
                                                  data.itemId ?? "";
                                              cont.isFavouriteScreen = true;
                                              cont.update();

                                              bool isAddedF =
                                                  await cont.favouriteItem();

                                              if (isAddedF) {
                                                String itemIdToSync =
                                                    data.itemId ?? "";

                                                // FIX: Use remove(data) instead of removeAt(index)
                                                // This prevents removing the wrong item if the list order changes
                                                cont.userFavouriteListingModelList
                                                    .remove(data);

                                                // Update ALL lists that might contain this item
                                                // Main listing list
                                                for (var item
                                                    in cont.listingModelList) {
                                                  if (item.itemId ==
                                                      itemIdToSync) {
                                                    item.isFavorite = "0";
                                                    break;
                                                  }
                                                }

                                                // Search listing list
                                                for (var item in cont
                                                    .listingModelSearchList) {
                                                  if (item.itemId ==
                                                      itemIdToSync) {
                                                    item.isFavorite = "0";
                                                    break;
                                                  }
                                                }

                                                // User listing list (my listings)
                                                for (var item in cont
                                                    .userListingModelList) {
                                                  if (item.itemId ==
                                                      itemIdToSync) {
                                                    item.isFavorite = "0";
                                                    break;
                                                  }
                                                }

                                                // Force UI update
                                                cont.update();

                                                // Reload home screen data to refresh favorite status
                                                // You might consider removing this if it causes too much loading
                                                cont.getListing();
                                                homePageCont.forceRefresh();

                                                homeCont.showToast(
                                                    "Removed successfully".tr);
                                              } else {
                                                // Revert the change if API call failed
                                                data.isFavorite =
                                                    originalFavoriteStatus;
                                                cont.update();
                                              }
                                            }
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            height: 43..h,
                                            width: 43..w,
                                            decoration: BoxDecoration(
                                              color:
                                                  Theme.of(context).cardColor,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      21.5..r),
                                            ),
                                            child: SvgPicture.asset(
                                              'assets/icons/heart1.svg',
                                              colorFilter: ColorFilter.mode(
                                                  data.isFavorite == '0'
                                                      ? Colors.grey
                                                      : Colors.red,
                                                  BlendMode.srcIn),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                    )
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
