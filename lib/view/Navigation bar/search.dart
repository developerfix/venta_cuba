import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import 'package:venta_cuba/Utils/funcations.dart';
import 'package:venta_cuba/view/constants/Colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Controllers/auth_controller.dart';
import '../../Models/ListingModel.dart';
import '../../Models/SelectedCategoryModel.dart';
import '../../cities_list/cites_list.dart';
import '../auth/login.dart';
import '../frame/frame.dart';

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
  void initState() {
    // TODO: implement initState
    super.initState();
    getAdd();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: GetBuilder<HomeController>(builder: (cont) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    height: 50..h,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                            onTap: () {
                              widget.isSearchFrom == 0
                                  ? {cont.selectedCategory = null}
                                  : null;
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
                            color: AppColors.k0xFFF0F1F1,
                            borderRadius: BorderRadius.circular(35..r),
                          ),
                          child: TextField(
                            controller: cont.searchController,
                            onSubmitted: (value) {
                              cont.currentSearchPage.value=1;
                                            cont.listingModelSearchList.clear();
                                            cont.update();
                              cont.getListingSearch();
                            },
                            textAlignVertical: TextAlignVertical.center,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.fromLTRB(0, 0, 0, 0),
                                focusedBorder: InputBorder.none,
                                prefixIcon: InkWell(
                                  onTap: () {
                                    cont.currentSearchPage.value=1;
                                            cont.listingModelSearchList.clear();
                                            cont.update();
                                    cont.getListingSearch();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(12),
                                    child: SvgPicture.asset(
                                        'assets/icons/search.svg',
                                        color: AppColors.k0xFFC4C4C4),
                                  ),
                                ),
                                hintText: 'What are you looking for?'.tr,
                                hintStyle: TextStyle(
                                    color: Color(0xFFA9ABAC),
                                    fontSize: 11..sp,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 26..h,
                  ),
                  SizedBox(
                    height: 40..h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showBottomSheet(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 17),
                            child: Container(
                              height: 40..h,
                              width: 98..w,
                              decoration: BoxDecoration(
                                  color:
                                      AppColors.k0xFF0254B8.withOpacity(.2),
                                  borderRadius: BorderRadius.circular(60)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    height: 27..h,
                                    width: 27..w,
                                    decoration: BoxDecoration(
                                        color: AppColors.k0xFF0254B8,
                                        shape: BoxShape.circle),
                                    child: Center(
                                      child: Text(
                                        '+1',
                                        style: TextStyle(
                                            fontSize: 13..sp,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.white),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 27..h,
                                    width: 27..w,
                                    decoration:
                                        BoxDecoration(shape: BoxShape.circle),
                                    child: Center(
                                      child: SvgPicture.asset(
                                          'assets/icons/list.svg'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            cont.isType = 0;
                            showDialogDropDown(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 17),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              height: 40..h,
                              // width: 98..w,
                              decoration: BoxDecoration(
                                  color:
                                      AppColors.k0xFFD9D9D9.withOpacity(.5),
                                  borderRadius: BorderRadius.circular(60)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Center(
                                    child: Text(
                                      homeCont.selectedCategory != null
                                          ? '${homeCont.selectedCategory?.name}'
                                          : 'Other'.tr,
                                      style: TextStyle(
                                          fontSize: 13..sp,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.black),
                                    ),
                                  ),
                                  Container(
                                    height: 27..h,
                                    width: 27..w,
                                    decoration:
                                        BoxDecoration(shape: BoxShape.circle),
                                    child: Center(
                                      child: SvgPicture.asset(
                                          'assets/icons/drop.svg'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.only(right: 17),
                        //   child: Container(
                        //     padding: EdgeInsets.symmetric(horizontal: 10),
                        //     height: 40..h,
                        //     width: 98..w,
                        //     decoration: BoxDecoration(
                        //         color: AppColors.k0xFFD9D9D9.withOpacity(.5),
                        //         borderRadius: BorderRadius.circular(60)),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //       children: [
                        //         Center(
                        //           child: Text(
                        //             'Canada',
                        //             style: TextStyle(
                        //                 fontSize: 13..sp,
                        //                 fontWeight: FontWeight.w500,
                        //                 color: AppColors.black),
                        //           ),
                        //         ),
                        //         Container(
                        //           height: 27..h,
                        //           width: 27..w,
                        //           decoration:
                        //               BoxDecoration(shape: BoxShape.circle),
                        //           child: Center(
                        //             child: SvgPicture.asset(
                        //                 'assets/icons/drop.svg'),
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 50..h,
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined),
                      SizedBox(
                        width: 215.w,
                        child: Text(
                          add != '' ? "$add " : '${cont.address}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppColors.black,
                              fontSize: 16..sp,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      Spacer(),
                      Row(
                        children: [
                          Text(
                            '${cont.listingModelSearchList.length} ',
                            style: TextStyle(
                              color: AppColors.k1xFF403C3C,
                              fontSize: 15..sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'results'.tr,
                            style: TextStyle(
                              color: AppColors.k1xFF403C3C,
                              fontSize: 15..sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 33..h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 49..h,
                        width: 134..w,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(60),
                            border: Border.all()),
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
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(60),
                                      topLeft: Radius.circular(60)),
                                  color: isListView
                                      ? Colors.transparent
                                      : AppColors.k0xFF0254B8,
                                ),
                                child: SvgPicture.asset(
                                  'assets/icons/category.svg',
                                  color: isListView
                                      ? AppColors.black
                                      : AppColors.white,
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
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(60),
                                      topRight: Radius.circular(60)),
                                  color: isListView
                                      ? AppColors.k0xFF0254B8
                                      : Colors.transparent,
                                ),
                                child: SvgPicture.asset(
                                  'assets/icons/list1.svg',
                                  color: isListView
                                      ? AppColors.white
                                      : AppColors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        height: 49..h,
                        decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(60)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              height: 24..h,
                              width: 24..w,
                              child:
                                  SvgPicture.asset('assets/icons/sort.svg'),
                            ),
                            Text(
                              'Sort'.tr,
                              style: TextStyle(
                                  fontSize: 16..sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.black),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 35..h,
                  ),
                  isListView
                      ? list(cont.listingModelSearchList)
                      : grid(cont.listingModelSearchList)
                ],
              ),
            ),
          );
        }),
      ),
    );
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
          childAspectRatio: 1.41 / 3,
          mainAxisSpacing: 26,
          crossAxisSpacing: 34,
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
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5), // Shadow color
                          offset: Offset(0, 3), // Shadow offset
                          blurRadius: 6, // Shadow blur radius
                          spreadRadius: 0, // Shadow spread radius
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          // height: 180..h,
                          width: MediaQuery.of(context).size.width,
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
                          // height: 65..h,
                          color: Colors.white,
                          child: Column(
                            children: [
                              Center(
                                child: Text(
                                  listingList[index].title ?? "",
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 17..sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black),
                                      
                                ),
                              ),
                              Text(
                                '${listingList[index].address ?? ""}',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 13..sp,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.k0xFF403C3C),
                              ),
                              SizedBox(
                                height: 2..h,
                              ),
                              Text(
                                listingList[index].price == "0"
                                    ? ""
                                    : '\$${listingList[index].price ?? ""}',
                                style: TextStyle(
                                    fontSize: 16..sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.k0xFF0254B8),
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
                            errorAlertToast("Successfully".tr);
                          } else {
                            homeCont.listingModel?.isFavorite == "0"
                                ? homeCont.listingModel?.isFavorite =
                                    "1"
                                : homeCont.listingModel?.isFavorite =
                                    "0";
                          }
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        height: 43..h,
                        width: 43..w,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(21.5..r)),
                        child: SvgPicture.asset(
                          'assets/icons/heart1.svg',
                          color: homeCont.listingModelSearchList.isNotEmpty &&
                              homeCont.listingModelSearchList[index].isFavorite == '0'
                                  ? Colors.grey
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
                        color: Colors.white,
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
                                  color: Colors.black),
                            ),
                            Text(
                              "${listingList[index].address}",
                              style: TextStyle(
                                  fontSize: 13..sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.k0xFF403C3C),
                            ),
                            Text(
                              listingList[index].price == "0"
                                  ? ""
                                  : "\$${listingList[index].price}",
                              style: TextStyle(
                                  fontSize: 16..sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.k0xFF0254B8),
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
                          errorAlertToast("Successfully".tr);
                        } else {
                          homeCont.listingModel?.isFavorite == "0"
                              ? homeCont.listingModel?.isFavorite =
                                  "1"
                              : homeCont.listingModel?.isFavorite =
                                  "0";
                        }
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      height: 43..h,
                      width: 43..w,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(21.5..r)),
                      child: SvgPicture.asset(
                        'assets/icons/heart1.svg',
                        color:  homeCont.listingModelSearchList.isNotEmpty &&
                            homeCont.listingModelSearchList[index].isFavorite == '0'
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
    // TODO: implement initState
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
              color: AppColors.white,
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
                  color: AppColors.k0xFFD9D9D9,
                ),
                SizedBox(
                  height: 17..h,
                ),
                Text(
                  'All Filters'.tr,
                  style: TextStyle(
                      fontSize: 17..sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black),
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
                          color: AppColors.black),
                    ),
                    InkWell(
                      onTap: () {
                        cont.minPriceController.clear();
                        cont.maxPriceController.clear();
                      },
                      child: Text(
                        'Clear'.tr,
                        style: TextStyle(
                            fontSize: 13..sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
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
                          color: AppColors.k0xFFD9D9D9.withOpacity(.28)),
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
                                  color: AppColors.black)),
                        ),
                      ),
                    ),
                    Container(
                      height: 50..h,
                      width: MediaQuery.of(context).size.width * .42,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: AppColors.k0xFFD9D9D9.withOpacity(.28)),
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
                                color: AppColors.black)),
                      )),
                    )
                  ],
                ),
                SizedBox(
                  height: 20..h,
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text(
                //       'Location'.tr,
                //       style: TextStyle(fontSize: 16..sp, fontWeight: FontWeight.w600, color: AppColors.black),
                //     ),
                //     Text(
                //       'Clear'.tr,
                //       style:
                //           TextStyle(fontSize: 13..sp, fontWeight: FontWeight.w600, color: Colors.transparent),
                //     ),
                //   ],
                // ),
                // SizedBox(
                //   height: 20..h,
                // ),
                // Center(
                //   child: Container(
                //     padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                //     child: Center(
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Column(
                //             children: [
                //               Container(
                //                 width: double.maxFinite,
                //                 height: 58..h,
                //                 // padding: EdgeInsets.only(left: 10),
                //                 alignment: Alignment.centerLeft,
                //                 decoration: BoxDecoration(
                //                     color: Colors.transparent,
                //                     borderRadius: BorderRadius.circular(5),
                //                     border:
                //                     Border.all(color: AppColors.k0xFFA9ABAC.withOpacity(.33))),
                //                 child: DropdownButtonHideUnderline(
                //                   child: DropdownButton2<CustomProvinceNameList>(
                //                     isExpanded: true,
                //                     hint: Text(
                //                       'Select province'.tr,
                //                       style: TextStyle(
                //                         fontSize: 14,
                //                         color: Theme.of(context).hintColor,
                //                       ),
                //                     ),
                //                     iconStyleData: IconStyleData(iconSize: 0),
                //                     items: provinceName
                //                         .map((item) => DropdownMenuItem(
                //                       value: item,
                //                       child: Text(
                //                         "${item.provinceName}",
                //                         style: const TextStyle(
                //                           fontSize: 14,
                //                         ),
                //                       ),
                //                     ))
                //                         .toList(),
                //                     value: province,
                //                     onChanged: (value) {
                //                       setState(() {
                //                         if (city != null) {
                //                           city = null;
                //                           province = value;
                //                         } else {
                //                           province = value;
                //                         }
                //                         // province?.provinceName = "${selectedValue!.provinceName}";
                //                         print(".............${province?.provinceName}");
                //                       });
                //                     },
                //
                //                     buttonStyleData: const ButtonStyleData(
                //                       padding: EdgeInsets.symmetric(horizontal: 10),
                //                       height: 40,
                //                     ),
                //                     dropdownStyleData: const DropdownStyleData(
                //                         maxHeight: 600, useRootNavigator: true),
                //                     menuItemStyleData: const MenuItemStyleData(
                //                       height: 40,
                //                     ),
                //                     dropdownSearchData: DropdownSearchData(
                //                       searchController: textEditingController,
                //                       searchInnerWidgetHeight: 50,
                //                       searchInnerWidget: Container(
                //                         height: 50,
                //                         padding: const EdgeInsets.only(
                //                           top: 8,
                //                           bottom: 4,
                //                           right: 8,
                //                           left: 8,
                //                         ),
                //                         child: TextFormField(
                //                           // expands: true,
                //                           // maxLines: null,
                //                           controller: textEditingController,
                //                           decoration: InputDecoration(
                //                             // isDense: true,
                //                             contentPadding: const EdgeInsets.symmetric(
                //                               horizontal: 10,
                //                               vertical: 8,
                //                             ),
                //                             hintText: 'Search your province'.tr,
                //                             hintStyle: const TextStyle(fontSize: 16),
                //                             border: OutlineInputBorder(
                //                               borderRadius: BorderRadius.circular(8),
                //                             ),
                //                           ),
                //                         ),
                //                       ),
                //                       searchMatchFn: (item, searchValue) {
                //                         return item.value.toString().contains(searchValue);
                //                       },
                //                     ),
                //                     //This to clear the search value when you close the menu
                //                     onMenuStateChange: (isOpen) {
                //                       if (!isOpen) {
                //                         textEditingController.clear();
                //                       }
                //                     },
                //                   ),
                //                 ),
                //               ),
                //               SizedBox(height: 10),
                //               Container(
                //                 width: double.maxFinite,
                //                 height: 58..h,
                //                 // padding: EdgeInsets.only(left: 10),
                //                 alignment: Alignment.centerLeft,
                //                 decoration: BoxDecoration(
                //                     color: Colors.transparent,
                //                     borderRadius: BorderRadius.circular(5),
                //                     border:
                //                     Border.all(color: AppColors.k0xFFA9ABAC.withOpacity(.33))),
                //                 child: DropdownButtonHideUnderline(
                //                   child: DropdownButton2<CustomCitiesList>(
                //                     isExpanded: true,
                //                     hint: Text(
                //                       'Select city'.tr,
                //                       style: TextStyle(
                //                         fontSize: 14,
                //                         color: Theme.of(context).hintColor,
                //                       ),
                //                     ),
                //                     iconStyleData: IconStyleData(iconSize: 0),
                //                     value: city,
                //                     items: citiesList
                //                         .where((element) => element.provinceName
                //                         .contains(province?.provinceName ?? ""))
                //                         .map((item) => DropdownMenuItem(
                //                       value: item,
                //                       child: Text(
                //                         "${item.cityName}",
                //                         style: const TextStyle(
                //                           fontSize: 14,
                //                         ),
                //                       ),
                //                     ))
                //                         .toList(),
                //
                //                     onChanged: (value) {
                //                       setState(() {
                //                         city = value;
                //                         cont.searchLatitude = city!.latitude;
                //                         cont.searchLongitude = city!.longitude;
                //                       });
                //                     },
                //
                //                     buttonStyleData: const ButtonStyleData(
                //                       padding: EdgeInsets.symmetric(horizontal: 10),
                //                       height: 40,
                //                     ),
                //                     dropdownStyleData: const DropdownStyleData(
                //                         maxHeight: 600, useRootNavigator: true),
                //                     menuItemStyleData: const MenuItemStyleData(
                //                       height: 40,
                //                     ),
                //                     dropdownSearchData: DropdownSearchData(
                //                       searchController: textEditingController,
                //                       searchInnerWidgetHeight: 50,
                //                       searchInnerWidget: Container(
                //                         height: 50,
                //                         padding: const EdgeInsets.only(
                //                           top: 8,
                //                           bottom: 4,
                //                           right: 8,
                //                           left: 8,
                //                         ),
                //                         child: TextFormField(
                //                           controller: textEditingController,
                //                           decoration: InputDecoration(
                //                             // isDense: true,
                //                             contentPadding: const EdgeInsets.symmetric(
                //                               horizontal: 10,
                //                               vertical: 8,
                //                             ),
                //                             hintText: 'Search your city'.tr,
                //                             hintStyle: const TextStyle(fontSize: 16),
                //                             border: OutlineInputBorder(
                //                               borderRadius: BorderRadius.circular(8),
                //                             ),
                //                           ),
                //                         ),
                //                       ),
                //                       searchMatchFn: (item, searchValue) {
                //                         return item.value.toString().contains(searchValue);
                //                       },
                //                     ),
                //                     //This to clear the search value when you close the menu
                //                     onMenuStateChange: (isOpen) {
                //                       if (!isOpen) {
                //                         textEditingController.clear();
                //                       }
                //                     },
                //                   ),
                //                 ),
                //               ),
                //
                //             ],
                //           ),
                //
                //           Container(
                //             height: height,
                //             margin: const EdgeInsets.only(left: 10, right: 10.0, bottom: 0),
                //             color: Colors.white.withOpacity(0.9),
                //             child: SingleChildScrollView(
                //               child: Column(
                //                 children: List.generate(
                //                   searchCity?.length ?? 0,
                //                   (index) => ListTile(
                //                     title: Column(
                //                       crossAxisAlignment: CrossAxisAlignment.start,
                //                       children: [
                //                         Text(
                //                           searchCity?.length == 0
                //                               ? ""
                //                               : "${searchCity![index].cityName},${searchCity![index].provinceName},${searchCity![index].countryName}",
                //                           style: TextStyle(
                //                             fontSize: 16.sp,
                //                             fontWeight: FontWeight.w600,
                //                           ),
                //                         ),
                //                         index == searchCity!.length - 1 ? SizedBox() : Divider(),
                //                       ],
                //                     ),
                //                     onTap: () async {
                //                       cont.addressCont.clear();
                //                       cont.searchLongitude = searchCity![index].longitude;
                //                       cont.searchLatitude = searchCity![index].latitude;
                //                       print(cont.searchLongitude);
                //                       print(cont.searchLatitude);
                //                       cont.addressCont.text =
                //                           "${searchCity![index].cityName}, ${searchCity![index].provinceName}, ${searchCity![index].countryName}";
                //                       FocusScope.of(context).unfocus();
                //                       cont.addressController.text = cont.addressCont.text;
                //                       setState(() {});
                //                       searchCity?.length = 0;
                //                       height = 0;
                //                     },
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           ),
                //         ],
                //       ),
                //
                //     ),
                //   ),
                // ),
                // SizedBox(
                //   height: 20..h,
                // ),
                InkWell(
                  onTap: () {
                    if (cont.minPriceController.text.isEmpty ||
                        cont.minPriceController.text.isEmpty) {
                      Get.back();
                      cont.currentSearchPage.value=1;
                                            cont.listingModelSearchList.clear();
                                            cont.update();
                      cont.getListingSearch();
                    } else if (double.parse(
                            cont.minPriceController.text.toString()) >
                        double.parse(cont.maxPriceController.text)) {
                      errorAlertToast(
                          "Maximum price always should be greater then minimum price."
                              .tr);
                    } else {
                      Get.back();
                      cont.currentSearchPage.value=1;
                                            cont.listingModelSearchList.clear();
                                            cont.update();
                      cont.getListingSearch();
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
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
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
              color: AppColors.white,
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
                          color: AppColors.black),
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
                            color: AppColors.black),
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
                            color: AppColors.white,
                            border:
                                Border.all(color: AppColors.black, width: 2),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selectAllCategory
                                    ? AppColors.black // Selected color
                                    : AppColors.white),
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
                            color: AppColors.black),
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
                            color: AppColors.white,
                            border:
                                Border.all(color: AppColors.black, width: 2),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: buyAndSell
                                    ? AppColors.black // Selected color
                                    : AppColors.white),
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
                            color: AppColors.black),
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
                            color: AppColors.white,
                            border:
                                Border.all(color: AppColors.black, width: 2),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: audioSelected
                                    ? AppColors.black // Selected color
                                    : AppColors.white),
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
                            color: AppColors.white,
                            border:
                                Border.all(color: AppColors.black, width: 2),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: audioItems1
                                    ? AppColors.black // Selected color
                                    : AppColors.white),
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
                            color: AppColors.white,
                            border:
                                Border.all(color: AppColors.black, width: 2),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: audioItems2
                                    ? AppColors.black // Selected color
                                    : AppColors.white),
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
                            color: AppColors.white,
                            border:
                                Border.all(color: AppColors.black, width: 2),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: audioItems3
                                    ? AppColors.black // Selected color
                                    : AppColors.white),
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
                            color: AppColors.white,
                            border:
                                Border.all(color: AppColors.black, width: 2),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: audioItems4
                                    ? AppColors.black // Selected color
                                    : AppColors.white),
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
                            color: AppColors.white,
                            border:
                                Border.all(color: AppColors.black, width: 2),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: audioItems5
                                    ? AppColors.black // Selected color
                                    : AppColors.white),
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

showDialogDropDown(BuildContext context) {
  showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (context) {
        return GetBuilder(
            init: HomeController(),
            builder: (cont) {
              return Dialog(
                child: Container(
                  height: 300.h,
                  width: 200.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: 10.h, bottom: 5.h, left: 10.w, right: 20.w),
                        child: InkWell(
                            onTap: () {
                              if (cont.isType == 0) {
                                cont.selectedCategoryModel = null;
                                cont.selectedCategory = null;
                                cont.selectedSubSubCategory = null;
                                cont.update();
                                Get.back();
                              } else {
                                cont.isType = cont.isType - 1;
                                cont.update();
                              }
                            },
                            child: Icon(Icons.arrow_circle_left_outlined)),
                      ),
                      Expanded(
                        child: Padding(
                            padding: EdgeInsets.only(left: 20.w, right: 20.w),
                            child: cont.loadingCategory.value
                                ? Center(
                                    child: SizedBox(
                                        height: 30.h,
                                        width: 30.h,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        )),
                                  )
                                : ListView.separated(
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          if (cont.isType == 0) {
                                            cont.selectedCategory = cont
                                                .categoriesModel?.data?[index];
                                            cont.selectedCategoryModel =
                                                SelectedCategoryModel(
                                                    id: cont.categoriesModel
                                                        ?.data?[index].id,
                                                    name: cont.categoriesModel
                                                        ?.data?[index].name,
                                                    icon: cont.categoriesModel
                                                        ?.data?[index].icon,
                                                    type: 0);
                                            cont.isNavigate = false;
                                            cont.selectedSubCategory = null;
                                            cont.selectedSubSubCategory = null;
                                            cont.isSearchScreen = true;
                                            cont.currentSearchPage.value=1;
                                            cont.listingModelSearchList.clear();
                                            cont.update();
                                            cont.getSubCategories();
                                            cont.getListingSearch();
                                          } else if (cont.isType == 1) {
                                            cont.selectedSubCategory = cont
                                                .subCategoriesModel
                                                ?.data?[index];
                                            cont.selectedCategoryModel =
                                                SelectedCategoryModel(
                                                    id: cont.subCategoriesModel
                                                        ?.data?[index].id,
                                                    name: cont
                                                        .subCategoriesModel
                                                        ?.data?[index]
                                                        .name,
                                                    icon: "",
                                                    type: 1);
                                            cont.isNavigate = false;
                                            cont.isSearchScreen = true;
                                            cont.getSubSubCategories();
                                            
                                            // cont.update();
                                            // cont.getListingSearch();
                                          } else {
                                            cont.selectedSubSubCategory = cont
                                                .subSubCategoriesModel
                                                ?.data?[index];
                                            cont.selectedCategoryModel =
                                                SelectedCategoryModel(
                                                    id: cont
                                                        .subSubCategoriesModel
                                                        ?.data?[index]
                                                        .id,
                                                    name: cont
                                                        .subSubCategoriesModel
                                                        ?.data?[index]
                                                        .name,
                                                    icon: "",
                                                    type: 2);
                                                    cont.currentSearchPage.value=1;
                                            cont.listingModelSearchList.clear();
                                           
                                            cont.update();
                                            Get.back();
                                            cont.getListingSearch();
                                          }
                                        },
                                        child: Text(
                                          cont.isType == 0
                                              ? "${cont.categoriesModel?.data?[index].name}"
                                              : cont.isType == 1
                                                  ? "${cont.subCategoriesModel?.data?[index].name}"
                                                  : "${cont.subSubCategoriesModel?.data?[index].name}",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      );
                                    },
                                    separatorBuilder: (context, index) {
                                      return SizedBox(
                                        height: 10.h,
                                      );
                                    },
                                    itemCount: cont.isType == 0
                                        ? cont.categoriesModel?.data?.length ??
                                            0
                                        : cont.isType == 1
                                            ? cont.subCategoriesModel?.data
                                                    ?.length ??
                                                0
                                            : cont.subSubCategoriesModel?.data
                                                    ?.length ??
                                                0)),
                      ),
                    ],
                  ),
                ),
              );
            });
      });
}
