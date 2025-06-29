import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import 'package:venta_cuba/Utils/funcations.dart';
import 'package:venta_cuba/view/Navigation%20bar/post.dart';
import 'package:venta_cuba/view/constants/Colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Controllers/auth_controller.dart';
import '../../Models/ListingModel.dart';
import '../../Models/SelectedCategoryModel.dart';
import '../../cities_list/cites_list.dart';
import '../../util/category_list.dart';
import '../auth/login.dart';
import '../frame/frame.dart';
import '../widgets/scroll_to_top_button.dart';

class Search extends StatefulWidget {
  final int isSearchFrom;
  const Search({super.key, this.isSearchFrom = 0});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final homeCont = Get.put(HomeController());
  final authCont = Get.put(AuthController());

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child:
                SingleChildScrollView(child: PokeToDialBottomSheetContent()));
      },
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
              color: Theme.of(context).bottomSheetTheme.backgroundColor,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(40), topLeft: Radius.circular(40))),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4..h,
                  width: 160..w,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 17..h),
                Text(
                  'Sort by'.tr,
                  style: TextStyle(
                      fontSize: 17..sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleLarge?.color),
                ),
                SizedBox(height: 20..h),
                GetBuilder<HomeController>(builder: (cont) {
                  return Column(
                    children: [
                      ListTile(
                        onTap: () {
                          cont.selectedType = "Oldest First";
                          cont.applySortingToSearchList();
                          cont.update();
                          Navigator.pop(context);
                        },
                        title: Text('Oldest First'.tr),
                        leading: Radio(
                          value: "Oldest First",
                          groupValue: cont.selectedType,
                          onChanged: (value) {
                            cont.selectedType = value ?? "";
                            cont.applySortingToSearchList();
                            cont.update();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          cont.selectedType = "Newest First";
                          cont.applySortingToSearchList();
                          cont.update();
                          Navigator.pop(context);
                        },
                        title: Text('Newest First'.tr),
                        leading: Radio(
                          value: "Newest First",
                          groupValue: cont.selectedType,
                          onChanged: (value) {
                            cont.selectedType = value ?? "";
                            cont.applySortingToSearchList();
                            cont.update();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          cont.selectedType = "Highest Price";
                          cont.applySortingToSearchList();
                          cont.update();
                          Navigator.pop(context);
                        },
                        title: Text('Highest Price'.tr),
                        leading: Radio(
                          value: "Highest Price",
                          groupValue: cont.selectedType,
                          onChanged: (value) {
                            cont.selectedType = value ?? "";
                            cont.applySortingToSearchList();
                            cont.update();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          cont.selectedType = "Lowest Price";
                          cont.applySortingToSearchList();
                          cont.update();
                          Navigator.pop(context);
                        },
                        title: Text('Lowest Price'.tr),
                        leading: Radio(
                          value: "Lowest Price",
                          groupValue: cont.selectedType,
                          onChanged: (value) {
                            cont.selectedType = value ?? "";
                            cont.applySortingToSearchList();
                            cont.update();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  bool isListView = false;

  void toggleView(bool listView) {
    setState(() {
      isListView = listView;
    });
  }

  String? add;
  Future<void> getAdd() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      add = sharedPreferences.getString("saveAddress") ?? "";
    });
    print(add);
  }

  @override
  void dispose() {
    // Reset search screen flags when leaving the screen
    homeCont.isSearchScreen = false;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getAdd();

    // Set search screen flag to prevent navigation to other screens
    homeCont.isSearchScreen = true;
    homeCont.isNavigate = false;

    // Ensure scroll listener is attached for search pagination
    try {
      homeCont.searchScrollController.removeListener(homeCont.onScrollSearch);
    } catch (e) {
      // Listener wasn't attached, which is fine
    }
    homeCont.searchScrollController.addListener(homeCont.onScrollSearch);

    // Perform initial search when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (homeCont.listingModelSearchList.isEmpty) {
        homeCont.currentSearchPage.value = 1;
        homeCont.listingModelSearchList.clear();
        homeCont.getListingSearch();
      }
    });
  }

  String _getSelectedCategoryText(HomeController cont) {
    if (cont.selectedSubSubCategory != null) {
      return '${cont.selectedSubSubCategory?.name}';
    } else if (cont.selectedSubCategory != null) {
      return '${cont.selectedSubCategory?.name}';
    } else if (cont.selectedCategory != null) {
      return '${cont.selectedCategory?.name}';
    } else {
      return 'All Categories'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: GetBuilder<HomeController>(builder: (cont) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Fixed header section
                      Container(
                        height: 50..h,
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  // Only clear category when coming from home screen (isSearchFrom == 0)
                                  // Preserve category when coming from category screen (isSearchFrom == 1)
                                  if (widget.isSearchFrom == 0) {
                                    cont.selectedCategory = null;
                                  }
                                  cont.selectedSubCategory = null;
                                  cont.selectedSubSubCategory = null;
                                  cont.maxPriceController.clear();
                                  cont.searchController.clear();
                                  cont.minPriceController.clear();
                                  Navigator.of(context).pop();
                                },
                                child: Icon(Icons.arrow_back_ios)),
                            Container(
                              width: MediaQuery.of(context).size.width * .75,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                              ),
                              child: TextField(
                                controller: cont.searchController,
                                onChanged: (value) {
                                  // Reset price filter when search text changes
                                  cont.minPriceController.clear();
                                  cont.maxPriceController.clear();
                                  // Trigger rebuild to show/hide close icon
                                  cont.update();

                                  // Trigger search immediately when text changes
                                  cont.currentSearchPage.value = 1;
                                  cont.listingModelSearchList.clear();
                                  cont.getListingSearch();
                                },
                                onSubmitted: (value) {
                                  // Reset price filter when search is submitted
                                  cont.minPriceController.clear();
                                  cont.maxPriceController.clear();
                                  cont.currentSearchPage.value = 1;
                                  cont.listingModelSearchList.clear();
                                  cont.update();
                                  cont.getListingSearch();
                                },
                                textAlignVertical: TextAlignVertical.center,
                                cursorColor: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    focusedBorder: InputBorder.none,
                                    prefixIcon: InkWell(
                                      onTap: () {
                                        // Reset price filter when search icon is tapped
                                        cont.minPriceController.clear();
                                        cont.maxPriceController.clear();
                                        cont.currentSearchPage.value = 1;
                                        cont.listingModelSearchList.clear();
                                        cont.update();
                                        cont.getListingSearch();
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        child: SvgPicture.asset(
                                            'assets/icons/search.svg',
                                            color: Theme.of(context)
                                                .iconTheme
                                                .color),
                                      ),
                                    ),
                                    suffixIcon: cont
                                            .searchController.text.isNotEmpty
                                        ? InkWell(
                                            onTap: () {
                                              cont.searchController.clear();
                                              // Reset price filter when search is cleared
                                              cont.minPriceController.clear();
                                              cont.maxPriceController.clear();
                                              cont.currentSearchPage.value = 1;
                                              cont.listingModelSearchList
                                                  .clear();
                                              cont.update();
                                              cont.getListingSearch();
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(12),
                                              child: Icon(
                                                Icons.close,
                                                color: Theme.of(context)
                                                    .iconTheme
                                                    .color,
                                                size: 20,
                                              ),
                                            ),
                                          )
                                        : null,
                                    hintText: 'What are you looking for?'.tr,
                                    hintStyle: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color
                                            ?.withValues(alpha: 0.6),
                                        fontSize: 11..sp,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 8.h,
                      ),
                      SizedBox(
                        // height: 40..h,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showBottomSheet(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 17),
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color:
                                          AppColors.k0xFF0254B8.withOpacity(.2),
                                      borderRadius: BorderRadius.circular(60)),
                                  child: Center(
                                    child: SvgPicture.asset(
                                        'assets/icons/list.svg'),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  showDialogDropDown(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 17),
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    height: 40..h,
                                    // width: 98..w,
                                    decoration: BoxDecoration(
                                        color: AppColors.k0xFFD9D9D9
                                            .withOpacity(.5),
                                        borderRadius:
                                            BorderRadius.circular(60)),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              _getSelectedCategoryText(
                                                  homeCont),
                                              style: TextStyle(
                                                  fontSize: 13..sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.color),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 27..h,
                                          width: 27..w,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle),
                                          child: Center(
                                            child: SvgPicture.asset(
                                              'assets/icons/drop.svg',
                                              color: Theme.of(context)
                                                  .iconTheme
                                                  .color,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '${cont.listingModelSearchList.length} ',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withValues(alpha: 0.8),
                                    fontSize: 15..sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'results'.tr,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withValues(alpha: 0.8),
                                    fontSize: 15..sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 8.h,
                      ),
                      // Scrollable content section
                      Expanded(
                        child: CustomScrollView(
                          controller: homeCont.searchScrollController,
                          slivers: [
                            // Location row (non-sticky)
                            SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  SizedBox(height: 8..h),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on_outlined),
                                      Expanded(
                                        child: Text(
                                          add != ''
                                              ? "$add "
                                              : '${cont.address}',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color,
                                              fontSize: 16..sp,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                ],
                              ),
                            ),
                            // Sticky header with results count and sort buttons
                            SliverPersistentHeader(
                              pinned: true,
                              delegate: _StickyHeaderDelegate(
                                minHeight: 80..h,
                                maxHeight: 80..h,
                                child: Container(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  child: Column(
                                    children: [
                                      // Results count row

                                      SizedBox(height: 8.h),
                                      // Sort button row
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            height: 49..h,
                                            width: 134..w,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(60),
                                                border: Border.all(
                                                  color: Theme.of(context)
                                                      .dividerColor,
                                                  width: 1,
                                                )),
                                            child: Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    toggleView(false);
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(10),
                                                    height: 49..h,
                                                    width: 66..w,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              bottomLeft: Radius
                                                                  .circular(60),
                                                              topLeft: Radius
                                                                  .circular(
                                                                      60)),
                                                      color: isListView
                                                          ? Colors.transparent
                                                          : Theme.of(context)
                                                              .primaryColor,
                                                    ),
                                                    child: SvgPicture.asset(
                                                      'assets/icons/category.svg',
                                                      color: isListView
                                                          ? Theme.of(context)
                                                              .textTheme
                                                              .bodyLarge
                                                              ?.color
                                                          : Theme.of(context)
                                                              .colorScheme
                                                              .onPrimary,
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    toggleView(true);
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(10),
                                                    height: 49..h,
                                                    width: 66..w,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          60),
                                                              topRight: Radius
                                                                  .circular(
                                                                      60)),
                                                      color: isListView
                                                          ? Theme.of(context)
                                                              .primaryColor
                                                          : Colors.transparent,
                                                    ),
                                                    child: SvgPicture.asset(
                                                      'assets/icons/list1.svg',
                                                      color: isListView
                                                          ? Theme.of(context)
                                                              .colorScheme
                                                              .onPrimary
                                                          : Theme.of(context)
                                                              .textTheme
                                                              .bodyLarge
                                                              ?.color,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              _showSortBottomSheet(context);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(10),
                                              height: 49..h,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Theme.of(context)
                                                        .dividerColor,
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          60)),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Container(
                                                    height: 24..h,
                                                    width: 24..w,
                                                    child: SvgPicture.asset(
                                                        'assets/icons/sort.svg',
                                                        colorFilter: ColorFilter.mode(
                                                            Theme.of(context)
                                                                    .iconTheme
                                                                    .color ??
                                                                Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyLarge
                                                                    ?.color ??
                                                                Colors.black,
                                                            BlendMode.srcIn)),
                                                  ),
                                                  Text(
                                                    'Sort'.tr,
                                                    style: TextStyle(
                                                        fontSize: 16..sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium
                                                            ?.color),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 8..h),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Content
                            isListView
                                ? SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (BuildContext context, int index) {
                                        return Padding(
                                          padding:
                                              EdgeInsets.only(bottom: 20.h),
                                          child: listItem(
                                              cont.listingModelSearchList[
                                                  index],
                                              index),
                                        );
                                      },
                                      childCount:
                                          cont.listingModelSearchList.length,
                                    ),
                                  )
                                : SliverGrid(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.50.r,
                                      mainAxisSpacing: 15,
                                      crossAxisSpacing: 10,
                                    ),
                                    delegate: SliverChildBuilderDelegate(
                                      (BuildContext context, int index) {
                                        return gridItem(
                                            cont.listingModelSearchList[index],
                                            index);
                                      },
                                      childCount:
                                          cont.listingModelSearchList.length,
                                    ),
                                  ),
                            // Loading indicator for pagination
                            if (cont.isSearchLoading.value &&
                                cont.listingModelSearchList.isNotEmpty)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.all(20.h),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              // Scroll to top button
              ScrollToTopButton(
                scrollController: homeCont.searchScrollController,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget gridItem(ListingModel listing, int index) {
    return GestureDetector(
        onTap: () {
          homeCont.isListing = 0;
          homeCont.listingModel = listing;
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FrameScreen(),
              ));
        },
        child: Stack(
          children: [
            Container(
              // height: 280..h,
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
                        : Theme.of(context).shadowColor.withValues(alpha: 0.5),
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
                          topRight: Radius.circular(10.r)),
                      child: CachedNetworkImage(
                        height: 180..h,
                        width: MediaQuery.of(context).size.width,
                        imageUrl: listing.gallery != null &&
                                listing.gallery!.isNotEmpty
                            ? "${listing.gallery?.first}"
                            : "",
                        imageBuilder: (context, imageProvider) => Container(
                          height: 180..h,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) => SizedBox(
                            height: 180..h,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                                child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ))),
                        errorWidget: (context, url, error) =>
                            Center(child: Text("No Image".tr)),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10.r),
                            bottomRight: Radius.circular(10.r))),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20.h,
                          child: Center(
                            child: Text(
                              listing.title ?? "",
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 17..sp,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.color),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 16.h,
                          child: Text(
                            '${listing.address ?? ""}',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 13..sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.k0xFF403C3C),
                          ),
                        ),
                        SizedBox(
                          height: 2..h,
                        ),
                        SizedBox(
                          height: 16.h,
                          child: Text(
                            listing.price == "0"
                                ? ""
                                : "${PriceFormatter().formatNumber(int.parse(listing.price ?? '0'))}\$ ${PriceFormatter().getCurrency(listing.currency)}",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 14..sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.k0xFF0254B8),
                          ),
                        ),
                        SizedBox(
                          height: 5.h,
                        )
                      ],
                    ).paddingSymmetric(horizontal: 10),
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
                    homeCont.listingModel =
                        homeCont.listingModelSearchList[index];
                    homeCont.listingModel?.isFavorite == "0"
                        ? homeCont.listingModel?.isFavorite = "1"
                        : homeCont.listingModel?.isFavorite = "0";
                    homeCont.update();
                    bool isAddedF = await homeCont.favouriteItem();
                    if (isAddedF) {
                      String itemId =
                          homeCont.listingModelSearchList[index].itemId ?? "";
                      String newFavoriteStatus =
                          homeCont.listingModelSearchList[index].isFavorite ??
                              "0";

                      // Sync with home screen
                      homeCont.syncFavoriteStatusInHomeScreen(
                          itemId, newFavoriteStatus);

                      // Sync with favorites list
                      homeCont.syncFavoriteStatusInFavoritesList(
                          itemId, newFavoriteStatus);

                      errorAlertToast("Successfully".tr);
                    } else {
                      homeCont.listingModel?.isFavorite == "0"
                          ? homeCont.listingModel?.isFavorite = "1"
                          : homeCont.listingModel?.isFavorite = "0";
                    }
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  height: 43..h,
                  width: 43..w,
                  decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(21.5..r)),
                  child: SvgPicture.asset(
                    'assets/icons/heart1.svg',
                    color: homeCont.listingModelSearchList.isNotEmpty &&
                            homeCont.listingModelSearchList[index].isFavorite ==
                                '0'
                        ? Theme.of(context).unselectedWidgetColor
                        : Colors.red,
                  ),
                ),
              ),
            )
          ],
        ));
  }

  Widget grid(List<ListingModel> listingList) {
    return Expanded(
      child: GridView.builder(
        itemCount: listingList.length,
        controller: homeCont.searchScrollController,
        // physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.50.r,
          mainAxisSpacing: 15,
          crossAxisSpacing: 20,
        ),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
              onTap: () {
                homeCont.isListing = 0;
                homeCont.listingModel = listingList[index];
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FrameScreen(),
                    ));
              },
              child: Stack(
                children: [
                  Container(
                    // height: 280..h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10..r),
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
                                  .withValues(alpha: 0.5), // Shadow color
                          offset: Offset(0, 3), // Shadow offset
                          blurRadius: 6, // Shadow blur radius
                          spreadRadius: 0, // Shadow spread radius
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
                                topRight: Radius.circular(10.r)),
                            child: CachedNetworkImage(
                              height: 180..h,
                              width: MediaQuery.of(context).size.width,
                              imageUrl: listingList[index].gallery != null &&
                                      listingList[index].gallery!.isNotEmpty
                                  ? "${listingList[index].gallery?.first}"
                                  : "",
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                height: 180..h,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => SizedBox(
                                  height: 180..h,
                                  width: MediaQuery.of(context).size.width,
                                  child: Center(
                                      child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ))),
                              errorWidget: (context, url, error) =>
                                  Center(child: Text("No Image".tr)),
                            ),
                          ),
                        ),
                        Container(
                          // height: 65..h,
                          color: Theme.of(context).cardColor,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 20.h,
                                child: Center(
                                  child: Text(
                                    listingList[index].title ?? "",
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 17..sp,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.color),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 16.h,
                                child: Text(
                                  '${listingList[index].address ?? ""}',
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 13..sp,
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withValues(alpha: 0.7)),
                                ),
                              ),
                              SizedBox(
                                height: 2..h,
                              ),
                              SizedBox(
                                height: 16.h,
                                child: Text(
                                  listingList[index].price == "0"
                                      ? ""
                                      : "${PriceFormatter().formatNumber(int.parse(listingList[index].price ?? '0'))}\$ ${PriceFormatter().getCurrency(listingList[index].currency)}",
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 14..sp,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                              SizedBox(
                                height: 5.h,
                              )
                            ],
                          ).paddingSymmetric(horizontal: 10),
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
                          homeCont.listingModel =
                              homeCont.listingModelSearchList[index];
                          homeCont.listingModel?.isFavorite == "0"
                              ? homeCont.listingModel?.isFavorite = "1"
                              : homeCont.listingModel?.isFavorite = "0";
                          homeCont.update();
                          bool isAddedF = await homeCont.favouriteItem();
                          if (isAddedF) {
                            String itemId =
                                homeCont.listingModelSearchList[index].itemId ??
                                    "";
                            String newFavoriteStatus = homeCont
                                    .listingModelSearchList[index].isFavorite ??
                                "0";

                            // Sync with home screen
                            homeCont.syncFavoriteStatusInHomeScreen(
                                itemId, newFavoriteStatus);

                            // Sync with favorites list
                            homeCont.syncFavoriteStatusInFavoritesList(
                                itemId, newFavoriteStatus);

                            errorAlertToast("Successfully".tr);
                          } else {
                            homeCont.listingModel?.isFavorite == "0"
                                ? homeCont.listingModel?.isFavorite = "1"
                                : homeCont.listingModel?.isFavorite = "0";
                          }
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        height: 43..h,
                        width: 43..w,
                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(21.5..r)),
                        child: SvgPicture.asset(
                          'assets/icons/heart1.svg',
                          color: homeCont.listingModelSearchList.isNotEmpty &&
                                  homeCont.listingModelSearchList[index]
                                          .isFavorite ==
                                      '0'
                              ? Theme.of(context).unselectedWidgetColor
                              : Colors.red,
                        ),
                      ),
                    ),
                  )
                ],
              ));
        },
      ),
    );
  }

  Widget listItem(ListingModel listing, int index) {
    return InkWell(
      onTap: () {
        homeCont.isListing = 0;
        homeCont.listingModel = listing;
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FrameScreen(),
            ));
      },
      child: Stack(
        children: [
          Container(
            // height: 170..h,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10..r),
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
                      : Theme.of(context).shadowColor.withValues(alpha: 0.5),
                  offset: Offset(0, 3),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 170..h,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10)),
                      child: CachedNetworkImage(
                        height: 170..h,
                        width: 170..w,
                        imageUrl: listing.gallery != null &&
                                listing.gallery!.isNotEmpty
                            ? "${listing.gallery?.first}"
                            : "",
                        imageBuilder: (context, imageProvider) => Container(
                          height: 170..h,
                          width: 170..w,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) => SizedBox(
                            height: 170..h,
                            width: 170..w,
                            child: Center(
                                child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ))),
                        errorWidget: (context, url, error) =>
                            Center(child: Text("No Image".tr)),
                      ),
                    ),
                  ),
                ),
                Expanded(
                    child: Container(
                  height: 170..h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                  ),
                  width: MediaQuery.of(context).size.width * .37,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '${listing.title}',
                          maxLines: 2,
                          style: TextStyle(
                              fontSize: 17..sp,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.color),
                        ),
                        Text(
                          "${listing.address}",
                          style: TextStyle(
                              fontSize: 13..sp,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withValues(alpha: 0.7)),
                        ),
                        Text(
                          listing.price == "0"
                              ? ""
                              : "${PriceFormatter().formatNumber(int.parse(listing.price ?? '0'))}\$ ${PriceFormatter().getCurrency(listing.currency)}",
                          style: TextStyle(
                              fontSize: 14..sp,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor),
                        ),
                      ],
                    ),
                  ),
                ))
              ],
            ),
          ),
          Positioned(
            top: 10..h,
            left: 115..w,
            child: InkWell(
              onTap: () async {
                if (authCont.user?.email == "") {
                  Get.to(Login());
                } else {
                  homeCont.listingModel =
                      homeCont.listingModelSearchList[index];
                  homeCont.listingModel?.isFavorite == "0"
                      ? homeCont.listingModel?.isFavorite = "1"
                      : homeCont.listingModel?.isFavorite = "0";
                  homeCont.update();
                  bool isAddedF = await homeCont.favouriteItem();
                  if (isAddedF) {
                    String itemId =
                        homeCont.listingModelSearchList[index].itemId ?? "";
                    String newFavoriteStatus =
                        homeCont.listingModelSearchList[index].isFavorite ??
                            "0";

                    // Sync with home screen
                    homeCont.syncFavoriteStatusInHomeScreen(
                        itemId, newFavoriteStatus);

                    // Sync with favorites list
                    homeCont.syncFavoriteStatusInFavoritesList(
                        itemId, newFavoriteStatus);

                    errorAlertToast("Successfully".tr);
                  } else {
                    homeCont.listingModel?.isFavorite == "0"
                        ? homeCont.listingModel?.isFavorite = "1"
                        : homeCont.listingModel?.isFavorite = "0";
                  }
                }
              },
              child: Container(
                padding: EdgeInsets.all(10),
                height: 43..h,
                width: 43..w,
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(21.5..r)),
                child: SvgPicture.asset(
                  'assets/icons/heart1.svg',
                  color: homeCont.listingModelSearchList.isNotEmpty &&
                          homeCont.listingModelSearchList[index].isFavorite ==
                              '0'
                      ? Theme.of(context).unselectedWidgetColor
                      : Colors.red,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget list(List<ListingModel> listingList) {
    return Expanded(
      child: ListView.separated(
        itemCount: listingList.length,
        controller: homeCont.searchScrollController,
        shrinkWrap: true,
        // physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          Get.log("listing count list switch: ${listingList.length}");
          // return Text(listingList[indexN/A");
          return InkWell(
            onTap: () {
              homeCont.isListing = 0;
              homeCont.listingModel = listingList[index];
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FrameScreen(),
                  ));
            },
            child: Stack(
              children: [
                Container(
                  // height: 170..h,
                  width: MediaQuery.of(context).size.width,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10..r)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        // height: 170..h,
                        width: 170..w,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            height: 170..h,
                            width: 170..w,
                            imageUrl: listingList[index].gallery != null &&
                                    listingList[index].gallery!.isNotEmpty
                                ? "${listingList[index].gallery?.first}"
                                : "",
                            imageBuilder: (context, imageProvider) => Container(
                              height: 170..h,
                              width: 170..w,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            placeholder: (context, url) => SizedBox(
                                height: 170..h,
                                width: 170..w,
                                child: Center(
                                    child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ))),
                            errorWidget: (context, url, error) =>
                                Center(child: Text("No Image".tr)),
                          ),
                        ),
                      ),
                      Container(
                        // height: 79..h,
                        width: MediaQuery.of(context).size.width * .37,
                        color: Theme.of(context).cardColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${listingList[index].title}',
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 17..sp,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.color),
                            ),
                            Text(
                              "${listingList[index].address}",
                              style: TextStyle(
                                  fontSize: 13..sp,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withValues(alpha: 0.7)),
                            ),
                            Text(
                              listingList[index].price == "0"
                                  ? ""
                                  : "${PriceFormatter().formatNumber(int.parse(listingList[index].price ?? '0'))}\$ ${PriceFormatter().getCurrency(listingList[index].currency)}",
                              style: TextStyle(
                                  fontSize: 14..sp,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  top: 10..h,
                  left: 115..w,
                  child: InkWell(
                    onTap: () async {
                      if (authCont.user?.email == "") {
                        Get.to(Login());
                      } else {
                        homeCont.listingModel =
                            homeCont.listingModelSearchList[index];
                        homeCont.listingModel?.isFavorite == "0"
                            ? homeCont.listingModel?.isFavorite = "1"
                            : homeCont.listingModel?.isFavorite = "0";
                        homeCont.update();
                        bool isAddedF = await homeCont.favouriteItem();
                        if (isAddedF) {
                          String itemId =
                              homeCont.listingModelSearchList[index].itemId ??
                                  "";
                          String newFavoriteStatus = homeCont
                                  .listingModelSearchList[index].isFavorite ??
                              "0";

                          // Sync with home screen
                          homeCont.syncFavoriteStatusInHomeScreen(
                              itemId, newFavoriteStatus);

                          // Sync with favorites list
                          homeCont.syncFavoriteStatusInFavoritesList(
                              itemId, newFavoriteStatus);

                          errorAlertToast("Successfully".tr);
                        } else {
                          homeCont.listingModel?.isFavorite == "0"
                              ? homeCont.listingModel?.isFavorite = "1"
                              : homeCont.listingModel?.isFavorite = "0";
                        }
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      height: 43..h,
                      width: 43..w,
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(21.5..r)),
                      child: SvgPicture.asset(
                        'assets/icons/heart1.svg',
                        color: homeCont.listingModelSearchList.isNotEmpty &&
                                homeCont.listingModelSearchList[index]
                                        .isFavorite ==
                                    '0'
                            ? Theme.of(context).unselectedWidgetColor
                            : Colors.red,
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(
            height: 20.h,
          );
        },
      ),
    );
  }
}

class PokeToDialBottomSheetContent extends StatefulWidget {
  @override
  _PokeToDialBottomSheetContentState createState() =>
      _PokeToDialBottomSheetContentState();
}

class _PokeToDialBottomSheetContentState
    extends State<PokeToDialBottomSheetContent> {
  String currentText = '';
  double height = 0;
  List<CustomCitiesList>? searchCity = [];
  final authCont = Get.put(AuthController());
  CustomCitiesList? city;
  CustomProvinceNameList? province;
  final TextEditingController textEditingController = TextEditingController();
  bool isChecked = true;
  final homeCont = Get.put(HomeController());
  @override
  void initState() {
    citiesList.forEach((element) {
      if (element.cityName == authCont.user?.city) {
        homeCont.searchLatitude = element.latitude;
        homeCont.searchLongitude = element.longitude;
        city = element;
      }
    });
    provinceName.forEach((element) {
      if (element.provinceName == authCont.user?.province) {
        province = element;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (cont) {
      return InkWell(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(40), topLeft: Radius.circular(40))),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4..h,
                  width: 160..w,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(
                  height: 17..h,
                ),
                Text(
                  'All Filters'.tr,
                  style: TextStyle(
                      fontSize: 17..sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleLarge?.color),
                ),
                SizedBox(
                  height: 20..h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Price'.tr,
                      style: TextStyle(
                          fontSize: 16..sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.titleLarge?.color),
                    ),
                    InkWell(
                      onTap: () {
                        cont.minPriceController.clear();
                        cont.maxPriceController.clear();
                        // Refresh search results without price filter
                        cont.currentSearchPage.value = 1;
                        cont.listingModelSearchList.clear();
                        cont.update();
                        Get.log("Clearing price filters and refreshing search");
                        cont.getListingSearch();
                      },
                      child: Text(
                        'Clear'.tr,
                        style: TextStyle(
                            fontSize: 13..sp,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20..h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 50..h,
                      width: MediaQuery.of(context).size.width * .42,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Theme.of(context).cardColor,
                          border: Border.all(
                            color: Theme.of(context)
                                .dividerColor
                                .withValues(alpha: 0.3),
                            width: 1,
                          )),
                      child: Center(
                        child: TextField(
                          controller: cont.minPriceController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Minimum'.tr,
                              hintStyle: TextStyle(
                                  fontSize: 13..sp,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color)),
                        ),
                      ),
                    ),
                    Container(
                      height: 50..h,
                      width: MediaQuery.of(context).size.width * .42,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Theme.of(context).cardColor,
                          border: Border.all(
                            color: Theme.of(context)
                                .dividerColor
                                .withValues(alpha: 0.3),
                            width: 1,
                          )),
                      child: Center(
                          child: TextField(
                        controller: cont.maxPriceController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Maximum'.tr,
                            hintStyle: TextStyle(
                                fontSize: 13..sp,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color)),
                      )),
                    )
                  ],
                ),
                SizedBox(
                  height: 20..h,
                ),
                InkWell(
                  onTap: () {
                    Get.log(
                        "Apply button pressed - Min: '${cont.minPriceController.text}', Max: '${cont.maxPriceController.text}'");
                    // Check if both fields are empty - allow search without price filter
                    if (cont.minPriceController.text.isEmpty &&
                        cont.maxPriceController.text.isEmpty) {
                      Get.back();
                      cont.currentSearchPage.value = 1;
                      cont.listingModelSearchList.clear();
                      cont.update();
                      cont.getListingSearch();
                    }
                    // Check if only one field is filled - this is valid
                    else if (cont.minPriceController.text.isEmpty ||
                        cont.maxPriceController.text.isEmpty) {
                      Get.back();
                      cont.currentSearchPage.value = 1;
                      cont.listingModelSearchList.clear();
                      cont.update();
                      cont.getListingSearch();
                    }
                    // Both fields are filled - validate that max > min
                    else {
                      try {
                        double minPrice =
                            double.parse(cont.minPriceController.text.trim());
                        double maxPrice =
                            double.parse(cont.maxPriceController.text.trim());

                        if (minPrice > maxPrice) {
                          errorAlertToast(
                              "Maximum price should be greater than minimum price."
                                  .tr);
                        } else if (minPrice < 0 || maxPrice < 0) {
                          errorAlertToast("Price cannot be negative.".tr);
                        } else {
                          Get.back();
                          cont.currentSearchPage.value = 1;
                          cont.listingModelSearchList.clear();
                          cont.update();
                          cont.getListingSearch();
                        }
                      } catch (e) {
                        errorAlertToast("Please enter valid price values.".tr);
                      }
                    }
                  },
                  child: Container(
                    height: 60..h,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Color(0xFF0254B8),
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Text(
                        "Save Changes".tr,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}

// 2nd bottom sheet

class PokeToDialBottomSheetContent1 extends StatefulWidget {
  const PokeToDialBottomSheetContent1({super.key});

  @override
  State<PokeToDialBottomSheetContent1> createState() =>
      _PokeToDialBottomSheetContent1State();
}

class _PokeToDialBottomSheetContent1State
    extends State<PokeToDialBottomSheetContent1> {
  String selectCategories = 'All Category';

  bool selectAllCategory = false;
  bool buyAndSell = false;
  bool audioSelected = false;
  bool audioItems1 = false;
  bool audioItems2 = false;
  bool audioItems3 = false;
  bool audioItems4 = false;
  bool audioItems5 = false;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (cont) {
      return SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(40), topLeft: Radius.circular(40))),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: Container(
                      height: 4..h,
                      width: 160..w,
                      color: AppColors.k0xFFD9D9D9,
                    ),
                  ),
                ),
                SizedBox(
                  height: 17..h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.close,
                        color: AppColors.k0xFFA9ABAC,
                      ),
                    ),
                    Text(
                      'Category'.tr,
                      style: TextStyle(
                          fontSize: 19..sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.titleLarge?.color),
                    ),
                    Container(
                      width: 15..w,
                    )
                  ],
                ),
                SizedBox(
                  height: 30..h,
                ),
                Text(
                  'Categories'.tr,
                  style: TextStyle(
                      fontSize: 16..sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.k0xFF403C3C),
                ),
                // SizedBox(
                //   height: 10..h,
                // ),
                // Text(
                //   'Classified - Buy & Sell - Audios',
                //   style: TextStyle(
                //       fontSize: 16..sp,
                //       fontWeight: FontWeight.w500,
                //       color: AppColors.k0xFF403C3C),
                // ),
                SizedBox(
                  height: 20..h,
                ),
                Container(
                  height: 20..h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Categories'.tr,
                        style: TextStyle(
                            fontSize: 17..sp,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectAllCategory = !selectAllCategory;
                            // Update the state of other radio buttons accordingly
                            buyAndSell = selectAllCategory;
                            audioSelected = selectAllCategory;
                            audioItems1 = selectAllCategory;
                            audioItems2 = selectAllCategory;
                            audioItems3 = selectAllCategory;
                            audioItems4 = selectAllCategory;
                            audioItems5 = selectAllCategory;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(2),
                          width: 17..h,
                          // Adjust the width as needed
                          height: 17..w,
                          // Adjust the height as needed
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, // Default color,
                            color: Theme.of(context).cardColor,
                            border: Border.all(
                                color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color ??
                                    Theme.of(context).unselectedWidgetColor,
                                width: 2),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selectAllCategory
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color // Selected color
                                    : Theme.of(context).cardColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8..h),
                Container(
                  height: 20..h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Buy & Sell'.tr,
                        style: TextStyle(
                            fontSize: 14..sp,
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            // selectAllCategory = !selectAllCategory;
                            // Update the state of other radio buttons accordingly
                            buyAndSell = !buyAndSell;
                            // audioSelected = selectAllCategory;
                            // audioItems = audioItems;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(2),
                          width: 17..h,
                          // Adjust the width as needed
                          height: 17..w,
                          // Adjust the height as needed
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, // Default color,
                            color: Theme.of(context).cardColor,
                            border: Border.all(
                                color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color ??
                                    Theme.of(context).unselectedWidgetColor,
                                width: 2),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: buyAndSell
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color // Selected color
                                    : Theme.of(context).cardColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8..h),
                Container(
                  height: 20..h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Audios'.tr,
                        style: TextStyle(
                            fontSize: 14..sp,
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            // selectAllCategory = !selectAllCategory;
                            // Update the state of other radio buttons accordingly
                            // buyAndSell = selectAllCategory;
                            audioSelected = !audioSelected;
                            audioItems1 = audioSelected;
                            audioItems2 = audioSelected;
                            audioItems3 = audioSelected;
                            audioItems4 = audioSelected;
                            audioItems5 = audioSelected;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(2),
                          width: 17..h,
                          // Adjust the width as needed
                          height: 17..w,
                          // Adjust the height as needed
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, // Default color,
                            color: Theme.of(context).cardColor,
                            border: Border.all(
                                color: Theme.of(context).dividerColor,
                                width: 2),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: audioSelected
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color // Selected color
                                    : Theme.of(context).cardColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 8..h,
                ),
                Container(
                  height: 20..h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 25..w,
                          ),
                          Text(
                            'Ipods & Mp3'.tr,
                            style: TextStyle(
                                fontSize: 16..sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.k0xFF403C3C),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            // selectAllCategory = !selectAllCategory;
                            // Update the state of other radio buttons accordingly
                            // buyAndSell = selectAllCategory;
                            // audioSelected = selectAllCategory;
                            audioItems1 = !audioItems1;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(2),
                          width: 17..h,
                          // Adjust the width as needed
                          height: 17..w,
                          // Adjust the height as needed
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, // Default color,
                            color: Theme.of(context).cardColor,
                            border: Border.all(
                                color: Theme.of(context).dividerColor,
                                width: 2),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: audioItems1
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color // Selected color
                                    : Theme.of(context).cardColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 8..h,
                ),
                Container(
                  height: 20..h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 25..w,
                          ),
                          Text(
                            'Ipods & Mp3 Accessories'.tr,
                            style: TextStyle(
                                fontSize: 16..sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.k0xFF403C3C),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            // selectAllCategory = !selectAllCategory;
                            // Update the state of other radio buttons accordingly
                            // buyAndSell = selectAllCategory;
                            // audioSelected = selectAllCategory;
                            audioItems2 = !audioItems2;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(2),
                          width: 17..h,
                          // Adjust the width as needed
                          height: 17..w,
                          // Adjust the height as needed
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, // Default color,
                            color: Theme.of(context).cardColor,
                            border: Border.all(
                                color: Theme.of(context).dividerColor,
                                width: 2),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: audioItems2
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color // Selected color
                                    : Theme.of(context).cardColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 8..h,
                ),
                Container(
                  height: 20..h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 25..w,
                          ),
                          Text(
                            'Headphones'.tr,
                            style: TextStyle(
                                fontSize: 16..sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.k0xFF403C3C),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            // selectAllCategory = !selectAllCategory;
                            // Update the state of other radio buttons accordingly
                            // buyAndSell = selectAllCategory;
                            // audioSelected = selectAllCategory;
                            audioItems3 = !audioItems3;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(2),
                          width: 17..h,
                          // Adjust the width as needed
                          height: 17..w,
                          // Adjust the height as needed
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, // Default color,
                            color: Theme.of(context).cardColor,
                            border: Border.all(
                                color: Theme.of(context).dividerColor,
                                width: 2),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: audioItems3
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color // Selected color
                                    : Theme.of(context).cardColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 8..h,
                ),
                Container(
                  height: 20..h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 25..w,
                          ),
                          Text(
                            'Speakers'.tr,
                            style: TextStyle(
                                fontSize: 16..sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.k0xFF403C3C),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            // selectAllCategory = !selectAllCategory;
                            // Update the state of other radio buttons accordingly
                            // buyAndSell = selectAllCategory;
                            // audioSelected = selectAllCategory;
                            audioItems4 = !audioItems4;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(2),
                          width: 17..h,
                          // Adjust the width as needed
                          height: 17..w,
                          // Adjust the height as needed
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, // Default color,
                            color: Theme.of(context).cardColor,
                            border: Border.all(
                                color: Theme.of(context).dividerColor,
                                width: 2),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: audioItems4
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color // Selected color
                                    : Theme.of(context).cardColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 8..h,
                ),
                Container(
                  height: 20..h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 25..w,
                          ),
                          Text(
                            'Stereo System'.tr,
                            style: TextStyle(
                                fontSize: 16..sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.k0xFF403C3C),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            // selectAllCategory = !selectAllCategory;
                            // Update the state of other radio buttons accordingly
                            // buyAndSell = selectAllCategory;
                            // audioSelected = selectAllCategory;
                            audioItems5 = !audioItems5;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(2),
                          width: 17..h,
                          // Adjust the width as needed
                          height: 17..w,
                          // Adjust the height as needed
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, // Default color,
                            color: Theme.of(context).cardColor,
                            border: Border.all(
                                color: Theme.of(context).dividerColor,
                                width: 2),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: audioItems5
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color // Selected color
                                    : Theme.of(context).cardColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// Professional Category Selection Dialog
void showDialogDropDown(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => CategorySelectionDialog(),
  );
}

class CategorySelectionDialog extends StatefulWidget {
  @override
  _CategorySelectionDialogState createState() =>
      _CategorySelectionDialogState();
}

class _CategorySelectionDialogState extends State<CategorySelectionDialog> {
  final homeCont = Get.find<HomeController>();
  int currentLevel = 0; // 0: Categories, 1: SubCategories, 2: SubSubCategories

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (cont) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              minWidth: 280.w,
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with back button and title
                Row(
                  children: [
                    if (currentLevel > 0)
                      IconButton(
                        onPressed: () => _navigateBack(),
                        icon: Icon(Icons.arrow_back_ios, size: 20),
                      ),
                    Expanded(
                      child: Text(
                        _getDialogTitle(),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _clearSelection(),
                      icon: Icon(Icons.clear, size: 20),
                    ),
                  ],
                ),
                // Instructional text for main category level
                if (currentLevel == 0) ...[
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Click the title of the category if you want to see all publications within that category. Click on the arrow if you want to see publications from a specific subcategory.'
                          .tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  SizedBox(height: 12),
                ],
                // Content
                Flexible(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getDialogTitle() {
    switch (currentLevel) {
      case 0:
        return 'Select Category'.tr;
      case 1:
        return 'Select Subcategory'.tr;
      case 2:
        return 'Select Sub-subcategory'.tr;
      default:
        return 'Select Category'.tr;
    }
  }

  Widget _buildContent() {
    if (homeCont.loadingCategory.value || homeCont.loadingSubCategory.value) {
      return Center(child: CircularProgressIndicator());
    }

    List<dynamic> items = _getCurrentLevelItems();

    if (items.isEmpty) {
      return Center(
        child: Text(
          'No items available'.tr,
          style: TextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];

        // For categories (level 0), use CategoryList with separate click handlers
        if (currentLevel == 0) {
          return CategoryList(
            imagePath: item?.icon ?? '',
            text: _getItemName(item),
            onTitleTap: () => _selectCategoryTitle(item),
            onArrowTap: () => _selectCategoryArrow(item),
          );
        }

        // For subcategories and sub-subcategories, use themed container with ListTile
        return Container(
          margin: EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Theme.of(context).brightness == Brightness.dark
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  )
                : Border.all(
                    color: Colors.grey.withValues(alpha: 0.3),
                    width: 1,
                  ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
                blurRadius: 2,
              )
            ],
            color: Theme.of(context).cardColor,
          ),
          child: ListTile(
            title: Text(
              _getItemName(item),
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            onTap: () => _selectItem(item, index),
            trailing: currentLevel < 2
                ? Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).iconTheme.color,
                  )
                : null,
          ),
        );
      },
    );
  }

  List<dynamic> _getCurrentLevelItems() {
    switch (currentLevel) {
      case 0:
        return homeCont.categoriesModel?.data ?? [];
      case 1:
        return homeCont.subCategoriesModel?.data ?? [];
      case 2:
        return homeCont.subSubCategoriesModel?.data ?? [];
      default:
        return [];
    }
  }

  String _getItemName(dynamic item) {
    return item?.name?.toString() ?? 'Unknown';
  }

  void _selectItem(dynamic item, int index) async {
    switch (currentLevel) {
      case 0:
        await _selectCategory(item);
        break;
      case 1:
        await _selectSubCategory(item);
        break;
      case 2:
        await _selectSubSubCategory(item);
        break;
    }
  }

  Future<void> _selectCategory(dynamic category) async {
    homeCont.selectedCategory = category;
    homeCont.selectedSubCategory = null;
    homeCont.selectedSubSubCategory = null;
    homeCont.isNavigate = false;
    homeCont.isSearchScreen = true;

    // Load subcategories
    await homeCont.getSubCategories();

    // Check if subcategories exist
    if (homeCont.subCategoriesModel?.data?.isNotEmpty ?? false) {
      setState(() {
        currentLevel = 1;
      });
    } else {
      // No subcategories, apply filter and close dialog
      _applyFilterAndClose();
    }
  }

  // When clicking on category title - show all posts in that category
  Future<void> _selectCategoryTitle(dynamic category) async {
    homeCont.selectedCategory = category;
    homeCont.selectedSubCategory = null;
    homeCont.selectedSubSubCategory = null;
    homeCont.isNavigate = false;
    homeCont.isSearchScreen = true;

    // Apply filter immediately without navigating to subcategories
    _applyFilterAndClose();
  }

  // When clicking on category arrow - navigate to subcategories
  Future<void> _selectCategoryArrow(dynamic category) async {
    homeCont.selectedCategory = category;
    homeCont.selectedSubCategory = null;
    homeCont.selectedSubSubCategory = null;
    homeCont.isNavigate = false;
    homeCont.isSearchScreen = true;

    // Load subcategories
    await homeCont.getSubCategories();

    // Check if subcategories exist
    if (homeCont.subCategoriesModel?.data?.isNotEmpty ?? false) {
      setState(() {
        currentLevel = 1;
      });
    } else {
      // No subcategories, apply filter and close dialog
      _applyFilterAndClose();
    }
  }

  Future<void> _selectSubCategory(dynamic subCategory) async {
    homeCont.selectedSubCategory = subCategory;
    homeCont.selectedSubSubCategory = null;

    // Load sub-subcategories
    await homeCont.getSubSubCategories();

    // Check if sub-subcategories exist
    if (homeCont.subSubCategoriesModel?.data?.isNotEmpty ?? false) {
      setState(() {
        currentLevel = 2;
      });
    } else {
      // No sub-subcategories, apply filter and close dialog
      _applyFilterAndClose();
    }
  }

  Future<void> _selectSubSubCategory(dynamic subSubCategory) async {
    homeCont.selectedSubSubCategory = subSubCategory;
    _applyFilterAndClose();
  }

  void _navigateBack() {
    if (currentLevel > 0) {
      setState(() {
        currentLevel--;
      });

      // Clear the selection for the current level
      switch (currentLevel) {
        case 0:
          homeCont.selectedSubCategory = null;
          homeCont.selectedSubSubCategory = null;
          break;
        case 1:
          homeCont.selectedSubSubCategory = null;
          break;
      }
    }
  }

  void _clearSelection() {
    homeCont.selectedCategory = null;
    homeCont.selectedSubCategory = null;
    homeCont.selectedSubSubCategory = null;
    _applyFilterAndClose();
  }

  void _applyFilterAndClose() {
    Get.log("=== APPLYING FILTER AND CLOSING ===");
    Get.log("Selected Category: ${homeCont.selectedCategory?.name}");
    Get.log("Selected SubCategory: ${homeCont.selectedSubCategory?.name}");
    Get.log(
        "Selected SubSubCategory: ${homeCont.selectedSubSubCategory?.name}");

    // Reset price filter when category selection changes
    homeCont.minPriceController.clear();
    homeCont.maxPriceController.clear();

    // Ensure we stay in search screen
    homeCont.isSearchScreen = true;
    homeCont.isNavigate = false;

    // Reset search pagination and clear current results
    homeCont.currentSearchPage.value = 1;
    homeCont.listingModelSearchList.clear();
    homeCont.hasMoreSearch.value = true;

    // Update UI
    homeCont.update();

    // Close dialog
    Get.back();

    // Trigger search with new filters
    Get.log("Triggering search with category filter...");
    homeCont.getListingSearch();
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
