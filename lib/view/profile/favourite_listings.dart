import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import 'package:venta_cuba/view/Chat/custom_text.dart';
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: GetBuilder<HomeController>(
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
                              color: AppColors.black),
                        ),
                        Container(
                          height: 24..h,
                          width: 24..w,
                          color: Colors.transparent,
                        )
                      ],
                    ),
                    SizedBox(height: 60..h),
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
                                childAspectRatio: 0.55.r,
                                mainAxisSpacing: 25,
                                crossAxisSpacing: 25,
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
                                              BorderRadius.circular(10..r),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
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
                                            Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: CachedNetworkImage(
                                                height: 180..h,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                imageUrl: data.gallery !=
                                                            null &&
                                                        data.gallery!.isNotEmpty
                                                    ? "${data.gallery?.first}"
                                                    : "",
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
                                                  width: MediaQuery.of(context)
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
                                            Container(
                                              color: Colors.white,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      width: 140.w,
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
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                    SelectionArea(
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
                                                    SizedBox(
                                                      height: 2..h,
                                                    ),
                                                    SelectionArea(
                                                      child: Text(
                                                        data.price == "0"
                                                            ? " "
                                                            : '\$${data.price}', // Use data instead of cont.listingModelList
                                                        style: TextStyle(
                                                          fontSize: 16..sp,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: AppColors
                                                              .k0xFF0254B8,
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
                                                errorAlertToast(
                                                    "Successfully".tr);
                                              } else {
                                                data.isFavorite == "0"
                                                    ? data.isFavorite = "1"
                                                    : data.isFavorite = "0";
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
                                                      21.5..r),
                                            ),
                                            child: SvgPicture.asset(
                                              'assets/icons/heart1.svg',
                                              color: data.isFavorite == '0'
                                                  ? Colors.grey
                                                  : Colors.red,
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
