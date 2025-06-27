import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import 'package:venta_cuba/Utils/funcations.dart';
import 'package:venta_cuba/util/favourite_seller_grid.dart';
import 'package:flutter_svg/svg.dart';

import 'package:venta_cuba/view/auth/login.dart';
import 'package:venta_cuba/view/constants/Colors.dart';

import '../Chat/custom_text.dart';

class FavouriteSeller extends StatefulWidget {
  const FavouriteSeller({super.key});

  @override
  State<FavouriteSeller> createState() => _FavouriteSellerState();
}

class _FavouriteSellerState extends State<FavouriteSeller> {
  final authCont = Get.put(AuthController());

  void _showRemoveAllSellersDialog(BuildContext context, HomeController cont) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove All Sellers'.tr),
          content:
              Text('Are you sure you want to remove all favourite sellers?'.tr),
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
                            color: Colors.white,
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
                  bool isRemoved = await cont.removeAllFavouriteSellers();

                  Get.back();

                  if (isRemoved) {
                    // Reload home screen data to refresh favorite status
                    cont.getListing();

                    errorAlertToast(
                        'All favourite sellers removed successfully'.tr);
                  } else {
                    errorAlertToast(
                        'Failed to remove some sellers. Please try again.'.tr);
                  }
                } catch (e) {
                  Get.back();
                  errorAlertToast(
                      'Failed to remove sellers. Please try again.'.tr);
                  print('Error in removeAllFavouriteSellers: $e');
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
    return Scaffold(
      backgroundColor: AppColors.white,
      body: GetBuilder<HomeController>(
        builder: (cont) {
          return Padding(
            padding: EdgeInsets.all(20.r),
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
                          size: 18,
                        ),
                      ),
                      Text(
                        'Favorite Sellers'.tr,
                        style: TextStyle(
                            fontSize: 20..sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      GestureDetector(
                        onTap:
                            cont.favouriteSellerModel.data?.isNotEmpty == true
                                ? () {
                                    _showRemoveAllSellersDialog(context, cont);
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
                    child: cont.favouriteSellerModel.data!.isEmpty
                        ? Center(child: CustomText(text: "No Data Found".tr))
                        : GridView.builder(
                            itemCount: cont.favouriteSellerModel.data?.length,
                            // physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.71 / 3,
                              mainAxisSpacing: 26,
                              crossAxisSpacing: 34,
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                  onTap: () {
                                    cont.sellerId = cont.favouriteSellerModel
                                        .data?[index].sellerId
                                        .toString();
                                    cont.getSellerDetails(
                                        cont.isBusinessAccount ? "1" : "0",
                                        0,
                                        true);
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 280..h,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10..r),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
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
                                              height: 180..h,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: CachedNetworkImage(
                                                height: 180..h,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                imageUrl: cont
                                                            .favouriteSellerModel
                                                            .data![index]
                                                            .type ==
                                                        "Personal"
                                                    ? "${cont.favouriteSellerModel.data![index].profileImage}"
                                                    : "${cont.favouriteSellerModel.data![index].businessLogo}",
                                                imageBuilder:
                                                    (context, imageProvider) =>
                                                        Container(
                                                  height: 180..h,
                                                  width: MediaQuery.of(context)
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
                                                        width: MediaQuery.of(
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
                                            Container(
                                              height: 55..h,
                                              color: Colors.white,
                                              child: Column(
                                                children: [
                                                  Visibility(
                                                    visible: cont
                                                            .favouriteSellerModel
                                                            .data![index]
                                                            .type !=
                                                        "Personal",
                                                    child: SelectionArea(
                                                      child: Text(
                                                        cont
                                                                .favouriteSellerModel
                                                                .data![index]
                                                                .businessName ??
                                                            "",
                                                        style: TextStyle(
                                                            fontSize: 17..sp,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                  ),
                                                  SelectionArea(
                                                    child: Text(
                                                      '${cont.favouriteSellerModel.data![index].firstName} ${cont.favouriteSellerModel.data![index].lastName}',
                                                      style: TextStyle(
                                                          fontSize: 13..sp,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: AppColors
                                                              .k0xFF403C3C),
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
                                              cont.sellerId = cont
                                                  .favouriteSellerModel
                                                  .data?[index]
                                                  .sellerId
                                                  .toString();
                                              bool isAddedF =
                                                  await cont.favouriteSeller();
                                              if (isAddedF) {
                                                String removedSellerId = cont
                                                        .favouriteSellerModel
                                                        .data?[index]
                                                        .sellerId ??
                                                    "";

                                                // Remove from favorites list
                                                cont.favouriteSellerModel.data
                                                    ?.removeAt(index);

                                                // DIRECTLY update the home screen data - this is the key fix
                                                for (var item
                                                    in cont.listingModelList) {
                                                  if (item.user?.id
                                                          .toString() ==
                                                      removedSellerId) {
                                                    item.isSellerFavorite = "0";
                                                  }
                                                }

                                                for (var item in cont
                                                    .listingModelSearchList) {
                                                  if (item.user?.id
                                                          .toString() ==
                                                      removedSellerId) {
                                                    item.isSellerFavorite = "0";
                                                  }
                                                }

                                                // Force UI update
                                                cont.update();

                                                errorAlertToast(
                                                    "Successfully".tr);
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
                                              colorFilter: ColorFilter.mode(
                                                  Colors.red, BlendMode.srcIn),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ));
                            },
                          ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
