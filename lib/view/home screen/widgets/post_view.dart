import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import 'package:venta_cuba/view/Navigation%20bar/post.dart';
import 'package:venta_cuba/view/auth/login.dart';
import 'package:venta_cuba/view/constants/Colors.dart';
import 'package:venta_cuba/view/frame/frame.dart';
import 'package:flutter_svg/flutter_svg.dart';

final authCont = Get.find<AuthController>();

class ListingView extends StatelessWidget {
  const ListingView({super.key});

  @override
  Widget build(BuildContext context) {
    final homeCont =
        Get.find<HomeController>(); // Use existing controller instance
    return GetBuilder<HomeController>(
      init: homeCont,
      builder: (cont) {
        // Use the already shuffled list from controller
        final shuffledList = cont.listingModelList;

        return GridView.builder(
          itemCount: shuffledList.length + 1,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.50,
            mainAxisSpacing: 15,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (BuildContext context, int index) {
            if (index == shuffledList.length) {
              return cont.hasMore.value
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox.shrink();
            }
            final item = shuffledList[index];
            return RepaintBoundary(
              // Isolate repaints for better performance
              child: GestureDetector(
                onTap: () {
                  cont.isListing = 0;
                  cont.listingModel = item; // Use shuffled item
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FrameScreen()));
                },
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: Theme.of(context).cardColor,
                        border: Theme.of(context).brightness == Brightness.dark
                            ? Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Theme.of(context)
                                        .shadowColor
                                        .withValues(alpha: 0.5),
                            offset: Offset(0, 3),
                            blurRadius: 6,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.r),
                                topRight: Radius.circular(10.r),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: item.gallery != null &&
                                        item.gallery!.isNotEmpty
                                    ? "${item.gallery?.first}"
                                    : "",
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  height: 180.h,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)),
                                errorWidget: (context, url, error) =>
                                    Center(child: Text("No Image".tr)),
                              ),
                            ),
                          ),
                          Container(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 20.h,
                                  child: Text(
                                    item.title ?? "",
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: SizedBox(
                                    height: 16.h,
                                    child: Text(
                                      '${item.address ?? ""}',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.k0xFF403C3C),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                SizedBox(
                                  height: 16.h,
                                  child: Text(
                                    item.price == "0"
                                        ? " "
                                        : "${PriceFormatter().formatNumber(int.parse(item.price ?? '0'))}\$ ${PriceFormatter().getCurrency(item.currency)}",
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    // "${item.id}",
                                    style: TextStyle(
                                        fontSize: 14..sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.k0xFF0254B8),
                                  ),
                                ),
                                SizedBox(height: 5.h),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      top: 10.h,
                      right: 10.w,
                      child: InkWell(
                        onTap: () async {
                          if (authCont.user?.email == "") {
                            Get.to(Login());
                          } else {
                            cont.listingModel = item; // Use shuffled item
                            String originalFavoriteStatus =
                                item.isFavorite ?? "0";
                            item.isFavorite =
                                item.isFavorite == "0" ? "1" : "0";
                            cont.update();
                            bool isAddedF = await cont.favouriteItem();
                            if (isAddedF) {
                              // Sync with favorites list
                              cont.syncFavoriteStatusInFavoritesList(
                                  item.itemId ?? "", item.isFavorite ?? "0");

                              // Update search list to keep it in sync
                              for (int i = 0;
                                  i < cont.listingModelSearchList.length;
                                  i++) {
                                if (cont.listingModelSearchList[i].itemId ==
                                    item.itemId) {
                                  cont.listingModelSearchList[i].isFavorite =
                                      item.isFavorite;
                                  break;
                                }
                              }
                              cont.update();
                            } else {
                              // Revert the change if API call failed
                              item.isFavorite = originalFavoriteStatus;
                              cont.update();
                            }
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          height: 36.h,
                          width: 36.h,
                          decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(100)),
                          child: SvgPicture.asset(
                            'assets/icons/heart1.svg',
                            colorFilter: ColorFilter.mode(
                                item.isFavorite == '0'
                                    ? Theme.of(context).unselectedWidgetColor
                                    : Colors.red,
                                BlendMode.srcIn),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
