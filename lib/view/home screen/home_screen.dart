import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import 'package:venta_cuba/Utils/funcations.dart';
import 'package:venta_cuba/util/categories.dart';
import 'package:venta_cuba/view/Chat/custom_text.dart';
import 'package:venta_cuba/view/Navigation%20bar/search.dart';
import 'package:venta_cuba/view/category/select_category.dart';
import 'package:venta_cuba/view/constants/Colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:venta_cuba/view/frame/frame.dart';
import 'package:venta_cuba/view/home%20screen/widgets/post_view.dart';

import '../../Controllers/auth_controller.dart';
import '../../Share Preferences/Share Preferences.dart';
import '../Search_Places_Screen/searchAndCurrentLocationPage.dart';
import '../auth/login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final homeCont = Get.put(HomeController());
  final authCont = Get.put(AuthController());
 
  Future<void> getAdd() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      homeCont.address = sharedPreferences.getString("saveAddress") ?? "";
      homeCont.radius =
          double.parse(sharedPreferences.getString("saveRadius") ?? "50.0");
    });
    print(homeCont.address);
  }

  UserPreferences userPreferences = UserPreferences();
  getSaveHistory() async {
    beforeData = await userPreferences.getSaveHistory();
  }

  @override
  void initState() {
    if (Get.previousRoute != "/SearchAndCurrentLocationPage") {
      homeCont.fetchAccountType();
      getAdd();
      getSaveHistory();
      homeCont.selectedCategory = null;
      homeCont.selectedSubCategory = null;
      homeCont.selectedSubSubCategory = null;
      homeCont.homeData();
    }else{
      Get.log('noooooo');
    }

    // TODO: implement initState
    super.initState();
  }

  bool isListView = false;

  void toggleView(bool listView) {
    setState(() {
      isListView = listView;
    });
  }

  bool isLoading = false;
  int? selectedIndex;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: GetBuilder(
          init: HomeController(),
          builder: (cont) {
            return cont.loadingHome.value
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      homeCont.selectedCategory = null;
                      homeCont.selectedSubCategory = null;
                      homeCont.selectedSubSubCategory = null;
                      homeCont.homeData();
                      await Future.delayed(Duration(seconds: 1));
                    },
                    child: SingleChildScrollView(
                      controller: cont.scrollsController,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 40,
                                  ),
                                  Container(
                                    height: 40,
                                    width: 80,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            homeCont.getFavouriteItems();
                                            toggleView(false);
                                          },
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              // color: isListView ? Colors.transparent : AppColors.k0xFF0254B8,
                                            ),
                                            child: Center(
                                                child: SvgPicture.asset(
                                                    'assets/icons/heartadd.svg',
                                                    color: Colors.black)),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            toggleView(true);
                                            homeCont.getAllNotifications();
                                          },
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              // color: isListView ? AppColors.k0xFF0254B8
                                            ),
                                            child: Center(
                                                child: SvgPicture.asset(
                                              'assets/icons/notification.svg',
                                              color: Colors.black,
                                            )),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 30..h,
                              ),
                              Text(
                                'Welcome Back'.tr,
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 20..h,
                              ),
                              Container(
                                height: 54..h,
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: InkWell(
                                        onTap: () {
                                          cont.listingModelSearchList =
                                              cont.listingModelList;
                                          homeCont.selectedCategory = null;
                                          homeCont.selectedSubCategory = null;
                                          homeCont.selectedSubSubCategory =
                                              null;
                      
                                          Get.to(const Search())?.then((value) {
                                            getAdd();
                                            cont.currentPage.value = 1;
                                      cont.hasMore.value = true;
                                      cont.listingModelList.clear();
                                            cont.getListing();
                                          });
                                        },
                                        child: Container(
                                          height: 54..h,
                                          decoration: BoxDecoration(
                                            color: AppColors.k0xFFF0F1F1,
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          child: Row(
                                            children: [
                                              SizedBox(width: 8),
                                              Icon(Icons.search_rounded,
                                                  color: Color(0xFFA9ABAC)),
                                              SizedBox(width: 8),
                                              CustomText(
                                                text:
                                                    'What are you looking for?'
                                                        .tr,
                                                fontColor: Color(0xFFA9ABAC),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20..h,
                              ),
                              InkWell(
                                onTap: () {
                                  Get.to(SearchAndCurrentLocationPage())
                                      ?.then((_) {
                                    setState(() {
                                      if (Get.previousRoute == "login") {
                                        cont.currentPage.value = 1;
                                      cont.hasMore.value = true;
                                      cont.listingModelList.clear();
                                        cont.getListing();
                                      }
                                      //
                                      getAdd();
                                    });
                                  });
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                        'assets/icons/location.svg'),
                                    SizedBox(
                                      width: 5..w,
                                    ),
                                    SizedBox(
                                      width: 290.w,
                                      // height: 20.h,
                                      child: Text(
                                        homeCont.address != ''
                                            ? "${homeCont.address} ${"within the".tr} ${cont.radius.toInt()} km"
                                            : '${cont.address}',
                      
                                        // overflow: TextOverflow.clip,
                                        style: TextStyle(
                                            fontSize: 17..sp,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.k0xFF403C3C),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: 25..h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SelectionArea(
                                    child: Text(
                                      'Category'.tr,
                                      style: TextStyle(
                                          fontSize: 16..sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.black),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      homeCont.selectedCategory = null;
                                      homeCont.selectedSubCategory = null;
                                      homeCont.selectedSubSubCategory = null;
                                      Get.to(const SelectCategories())
                                          ?.then((value) {
                                            cont.currentPage.value = 1;
                                      cont.hasMore.value = true;
                                      cont.listingModelList.clear();
                                        cont.getListing();
                                      });
                                    },
                                    child: Text(
                                      'View all'.tr,
                                      style: TextStyle(
                                          fontSize: 15..sp,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.black),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20..h,
                              ),
                              Container(
                                height: 62..h,
                                width: MediaQuery.of(context).size.width,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      cont.categoriesModel?.data?.length ?? 0,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 15),
                                      child: InkWell(
                                        onTap: () {
                                          cont.selectedCategory = cont
                                              .categoriesModel?.data?[index];
                                          cont.isNavigate = true;
                                          cont.getSubCategories();
                                        },
                                        child: Categories(
                                            imagePath: cont.categoriesModel
                                                    ?.data?[index].icon ??
                                                "",
                                            text:
                                                "${cont.categoriesModel?.data?[index].name}"),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 35..h,
                              ),
                              // cont.isPostLoading.value ? 
                              // CircularProgressIndicator() :
                              ListingView()
                              // GridView.builder(
                              //   itemCount: cont.listingModelList.length,
                              //   physics: NeverScrollableScrollPhysics(),
                              //   shrinkWrap: true,
                              //   gridDelegate:
                              //       SliverGridDelegateWithFixedCrossAxisCount(
                              //     crossAxisCount: 2,
                              //     childAspectRatio: 0.55.r,
                              //     mainAxisSpacing: 25,
                              //     crossAxisSpacing: 25,
                              //   ),
                              //   itemBuilder: (BuildContext context, int index) {
                              //     Get.log('total post list count ${cont.listingModelList.length}');
                              //     return GestureDetector(
                              //         onTap: () {
                              //           cont.isListing = 0;
                              //           cont.listingModel =
                              //               cont.listingModelList[index];
                              //           Navigator.push(
                              //               context,
                              //               MaterialPageRoute(
                              //                 builder: (context) =>
                              //                     const FrameScreen(),
                              //               ));
                              //         },
                              //         child: Stack(
                              //           children: [
                              //             Container(
                              //               // height: 280..h,
                              //               decoration: BoxDecoration(
                              //                 borderRadius:
                              //                     BorderRadius.circular(10..r),
                              //                 color: Colors.white,
                              //                 boxShadow: [
                              //                   BoxShadow(
                              //                     color: Colors.grey
                              //                         .withOpacity(0.5),
                              //                     // Shadow color
                              //                     offset: Offset(0, 3),
                              //                     // Shadow offset
                              //                     blurRadius: 6,
                              //                     // Shadow blur radius
                              //                     spreadRadius:
                              //                         0, // Shadow spread radius
                              //                   ),
                              //                 ],
                              //               ),
                              //               child: Column(
                              //                 mainAxisAlignment:
                              //                     MainAxisAlignment
                              //                         .spaceBetween,
                              //                 children: [
                              //                   Container(
                              //                     height: 173..h,
                              //                     width: MediaQuery.of(context)
                              //                         .size
                              //                         .width,
                              //                     child: ClipRRect(
                              //                       borderRadius: BorderRadius
                              //                           .only(
                              //                               topLeft:
                              //                                   Radius.circular(
                              //                                       10.r),
                              //                               topRight:
                              //                                   Radius.circular(
                              //                                       10.r)),
                              //                       child: CachedNetworkImage(
                              //                         height: 180..h,
                              //                         width:
                              //                             MediaQuery.of(context)
                              //                                 .size
                              //                                 .width,
                              //                         imageUrl: cont
                              //                                         .listingModelList[
                              //                                             index]
                              //                                         .gallery !=
                              //                                     null &&
                              //                                 cont
                              //                                     .listingModelList[
                              //                                         index]
                              //                                     .gallery!
                              //                                     .isNotEmpty
                              //                             ? "${cont.listingModelList[index].gallery?.first}"
                              //                             : "",
                              //                         imageBuilder: (context,
                              //                                 imageProvider) =>
                              //                             Container(
                              //                           height: 180..h,
                              //                           width: MediaQuery.of(
                              //                                   context)
                              //                               .size
                              //                               .width,
                              //                           decoration:
                              //                               BoxDecoration(
                              //                             image:
                              //                                 DecorationImage(
                              //                               image:
                              //                                   imageProvider,
                              //                               fit: BoxFit.cover,
                              //                             ),
                              //                           ),
                              //                         ),
                              //                         placeholder: (context,
                              //                                 url) =>
                              //                             SizedBox(
                              //                                 height: 180..h,
                              //                                 width:
                              //                                     MediaQuery.of(
                              //                                             context)
                              //                                         .size
                              //                                         .width,
                              //                                 child: Center(
                              //                                     child:
                              //                                         CircularProgressIndicator(
                              //                                   strokeWidth: 2,
                              //                                 ))),
                              //                         errorWidget: (context,
                              //                                 url, error) =>
                              //                             Center(
                              //                                 child: SelectionArea(
                              //                                     child: Text(
                              //                                         "No Image"
                              //                                             .tr))),
                              //                       ),
                              //                     ),
                              //                   ),
                              //                   Column(
                              //                     children: [
                              //                       SizedBox(
                              //                         width: 140.w,
                              //                         child: Text(
                              //                           cont
                              //                                   .listingModelList[
                              //                                       index]
                              //                                   .title ??
                              //                               "",
                              //                           maxLines: 2,
                              //                           textAlign:
                              //                               TextAlign.center,
                              //                           overflow: TextOverflow
                              //                               .ellipsis,
                              //                           style: TextStyle(
                              //                               fontSize: 17..sp,
                              //                               fontWeight:
                              //                                   FontWeight.w600,
                              //                               color:
                              //                                   Colors.black),
                              //                         ),
                              //                       ),
                              //                       Padding(
                              //                         padding: const EdgeInsets
                              //                             .symmetric(
                              //                             horizontal: 8.0),
                              //                         child: SizedBox(
                              //                           height: 15.h,
                              //                           child: SelectionArea(
                              //                             child: Text(
                              //                               '${cont.listingModelList[index].address ?? ""}',
                              //                               overflow:
                              //                                   TextOverflow
                              //                                       .ellipsis,
                              //                               style: TextStyle(
                              //                                   fontSize: 13
                              //                                     ..sp,
                              //                                   fontWeight:
                              //                                       FontWeight
                              //                                           .w400,
                              //                                   color: AppColors
                              //                                       .k0xFF403C3C),
                              //                             ),
                              //                           ),
                              //                         ),
                              //                       ),
                              //                       SizedBox(
                              //                         height: 2..h,
                              //                       ),
                              //                       SelectionArea(
                              //                         child: Text(
                              //                           cont.listingModelList[index]
                              //                                       .price ==
                              //                                   "0"
                              //                               ? " "
                              //                               : '\$${cont.listingModelList[index].price}',
                              //                           style: TextStyle(
                              //                               fontSize: 16..sp,
                              //                               fontWeight:
                              //                                   FontWeight.w600,
                              //                               color: AppColors
                              //                                   .k0xFF0254B8),
                              //                         ),
                              //                       ),
                              //                       SizedBox(
                              //                         height: 5.h,
                              //                       )
                              //                     ],
                              //                   )
                              //                 ],
                              //               ),
                              //             ),
                              //             Positioned(
                              //               top: 10..h,
                              //               right: 10..w,
                              //               child: InkWell(
                              //                 onTap: () async {
                              //                   if (authCont.user?.email ==
                              //                       "") {
                              //                     Get.to(Login());
                              //                   } else {
                              //                     cont.listingModel = cont
                              //                         .listingModelList[index];
                              //                     cont.listingModelList[index]
                              //                                 .isFavorite ==
                              //                             "0"
                              //                         ? cont
                              //                             .listingModelList[
                              //                                 index]
                              //                             .isFavorite = "1"
                              //                         : cont
                              //                             .listingModelList[
                              //                                 index]
                              //                             .isFavorite = "0";
                              //                     cont.update();
                              //                     selectedIndex = index;
                              //                     isLoading = true;
                              //                     setState(() {});
                              //                     bool isAddedF = await cont
                              //                         .favouriteItem();
                              //                     isLoading = false;
                              //                     setState(() {});
                              //                     if (isAddedF) {
                              //                       errorAlertToast(
                              //                           "Successfully".tr);
                              //                     } else {
                              //                       cont.listingModelList[index]
                              //                                   .isFavorite ==
                              //                               "0"
                              //                           ? cont
                              //                               .listingModelList[
                              //                                   index]
                              //                               .isFavorite = "1"
                              //                           : cont
                              //                               .listingModelList[
                              //                                   index]
                              //                               .isFavorite = "0";
                              //                     }
                              //                   }
                              //                 },
                              //                 child: Container(
                              //                   padding: EdgeInsets.all(10),
                              //                   height: 43..h,
                              //                   width: 43..w,
                              //                   decoration: BoxDecoration(
                              //                       color: Colors.white,
                              //                       borderRadius:
                              //                           BorderRadius.circular(
                              //                               21.5..r)),
                              //                   child: isLoading == true &&
                              //                           selectedIndex == index
                              //                       ? Lottie.asset(
                              //                           'assets/images/h.json')
                              //                       : SvgPicture.asset(
                              //                           'assets/icons/heart1.svg',
                              //                           color: cont
                              //                                       .listingModelList[
                              //                                           index]
                              //                                       .isFavorite ==
                              //                                   '0'
                              //                               ? Colors.grey
                              //                               : Colors.red,
                              //                         ),
                              //                 ),
                              //               ),
                              //             )
                              //           ],
                              //         ));
                              //   },
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ));
          },
        ));
  }
}
