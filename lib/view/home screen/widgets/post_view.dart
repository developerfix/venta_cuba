import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import 'package:venta_cuba/Controllers/homepage_controller.dart';
import 'package:venta_cuba/view/Navigation%20bar/post.dart';
import 'package:venta_cuba/view/auth/login.dart';
import 'package:venta_cuba/view/constants/Colors.dart';
import 'package:venta_cuba/view/constants/premium_animations.dart';
import 'package:venta_cuba/view/frame/frame.dart';
import 'package:flutter_svg/flutter_svg.dart';

final authCont = Get.find<AuthController>();

/// ListingView for HOMEPAGE ONLY - uses HomepageController
/// This is completely separate from Search and Category screens
class ListingView extends StatelessWidget {
  const ListingView({super.key});

  @override
  Widget build(BuildContext context) {
    // Use HomepageController for homepage listings - SEPARATE from search/category
    final homepageCont = Get.put(HomepageController());
    // HomeController is only used for navigation to detail screen
    final homeCont = Get.put(HomeController());

    return GetBuilder<HomepageController>(
      init: homepageCont,
      builder: (cont) {
        // Show loading indicator when:
        // 1. Actually loading AND list is empty, OR
        // 2. Initial load hasn't completed yet (prevents flash of empty state)
        if (cont.homepageListings.isEmpty &&
            (cont.isLoading.value || !cont.hasInitialLoadCompleted.value)) {
          return Container(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show empty state ONLY when:
        // 1. List is empty AND
        // 2. NOT loading AND
        // 3. Initial load has completed (we've actually tried to fetch data)
        if (cont.homepageListings.isEmpty &&
            !cont.isLoading.value &&
            cont.hasInitialLoadCompleted.value) {
          return Container(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No listings found'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try selecting a different location'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Use HomepageController's list - completely separate from search/category
        final listings = cont.homepageListings;

        return GridView.builder(
          itemCount: listings.length +
              (cont.hasMore.value && cont.isLoading.value ? 1 : 0),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.50,
            mainAxisSpacing: 15,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (BuildContext context, int index) {
            if (index == listings.length) {
              // Show loading indicator when loading more items
              return Container(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            // Safety check to prevent RangeError
            if (index >= listings.length) {
              return SizedBox.shrink();
            }
            final item = listings[index];
            return RepaintBoundary(
              child: GestureDetector(
                onTap: () async {
                  // Use HomeController for navigation (shared for detail view)
                  homeCont.isListing = 0;
                  homeCont.listingModel = item;

                  await Navigator.push(
                    context,
                    PremiumPageTransitions.slideFromRight(
                      const FrameScreen(),
                      settings: const RouteSettings(name: '/frame'),
                    ),
                  );
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
                            // Store original status for rollback
                            String originalFavoriteStatus =
                                item.isFavorite ?? "0";

                            // Toggle the favorite status LOCALLY first (optimistic update)
                            String newFavoriteStatus =
                                originalFavoriteStatus == "0" ? "1" : "0";

                            // Find the item in the list by index and update it
                            if (index < cont.homepageListings.length) {
                              cont.homepageListings[index].isFavorite =
                                  newFavoriteStatus;
                              cont.update();
                            }

                            // Set listingModel for API call
                            homeCont.listingModel = item;

                            // Make API call
                            bool isAddedF = await homeCont.favouriteItem();

                            if (!isAddedF) {
                              // Revert if API call failed
                              if (index < cont.homepageListings.length) {
                                cont.homepageListings[index].isFavorite =
                                    originalFavoriteStatus;
                                cont.update();
                              }
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
