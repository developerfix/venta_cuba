import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import 'package:venta_cuba/util/profile_list.dart';
import 'package:venta_cuba/view/Navigation%20bar/post.dart';
import 'package:venta_cuba/view/category/SubSubCategories.dart';

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
                            // Just go back - don't touch homepage list
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
                        // DON'T clear listingModelList - that's the homepage list!
                        // Only clear search list
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
                          ? directItemsList(cont)
                          : nestedCategoriesList(cont),
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

  ListView nestedCategoriesList(HomeController cont) {
    return ListView.separated(
      itemCount: cont.subCategoriesModel?.data?.length ?? 0,
      itemBuilder: (context, index) {
        return InkWell(
            onTap: () {
              // 1. Selection set karein
              cont.selectedSubCategory = cont.subCategoriesModel?.data?[index];
              cont.isNavigate = true;

              // 2. Pichla data clear karein taake naye screen pe purana data flash na ho
              cont.subSubCategoriesModel = null;
              cont.listingModelSearchList.clear();
              cont.loadingSubSubCategory.value =
                  true; // Loader trigger karne ke liye

              // 3. INSTANT Navigation (Bina wait kiye)
              Navigator.push(
                context,
                PremiumPageTransitions.slideFromRight(
                    SubSubCategories()), // Ya jo bhi aapki route class hai
              );

              // 4. API Call background mein start karein (await nahi lagana yahan navigation block karne ke liye)
              cont.getSubSubCategories();
            },
            child: ProfileList(
                text: cont.subCategoriesModel?.data?[index].name ?? ""));
      },
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(
          height: 20..h,
        );
      },
    );
  }

  Widget directItemsList(HomeController cont) {
    return GridView.builder(
      itemCount: cont.listingModelSearchList.length,
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // Scroll parent handle karega
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio:
            0.62.r, // Isay adjust kiya gaya hai taake content pura nazar aaye
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
      ),
      itemBuilder: (BuildContext context, int index) {
        // Direct SearchList se item uthayen
        var item = cont.listingModelSearchList[index];

        return GestureDetector(
          onTap: () {
            cont.isListing = 0;
            cont.listingModel = item; // Poora item object assign karein
            Navigator.push(
              context,
              PremiumPageTransitions.slideFromRight(
                const FrameScreen(),
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
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Theme.of(context)
                              .shadowColor
                              .withValues(alpha: 0.1),
                      offset: const Offset(0, 3),
                      blurRadius: 6,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Image Section
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.r),
                            topRight: Radius.circular(10.r)),
                        child: CachedNetworkImage(
                          width: double.infinity,
                          imageUrl:
                              (item.gallery != null && item.gallery!.isNotEmpty)
                                  ? "${item.gallery?.first}"
                                  : "",
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2)),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),

                    // Text Details Section
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 5.w, vertical: 8.h),
                      child: Column(
                        children: [
                          Text(
                            item.title ?? "",
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            item.address ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            item.price == "0"
                                ? "Negotiable".tr
                                : "${PriceFormatter().formatNumber(int.parse(item.price ?? '0'))}\$ ${PriceFormatter().getCurrency(item.currency)}",
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.k0xFF0254B8),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              // Favorite Button
              Positioned(
                top: 8.h,
                right: 8.w,
                child: InkWell(
                  onTap: () async {
                    if (authCont.user?.email == "") {
                      Get.to(const Login());
                    } else {
                      cont.listingModel = item;
                      // Toggle favorite locally
                      item.isFavorite = (item.isFavorite == "0") ? "1" : "0";
                      cont.update();

                      bool success = await cont.favouriteItem();
                      if (success) {
                        if (item.isFavorite == "0") {
                          cont.userFavouriteListingModelList
                              .removeWhere((fav) => fav.itemId == item.itemId);
                        }
                        errorAlertToast("Successfully".tr);
                      } else {
                        // Revert if API fails
                        item.isFavorite = (item.isFavorite == "0") ? "1" : "0";
                      }
                      cont.update();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4)
                        ]),
                    child: SvgPicture.asset(
                      'assets/icons/heart1.svg',
                      height: 20.h,
                      width: 20.w,
                      colorFilter: ColorFilter.mode(
                          item.isFavorite == '0'
                              ? AppColors.k0xFF9F9F9F
                              : AppColors.k0xFFFB0808,
                          BlendMode.srcIn),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
