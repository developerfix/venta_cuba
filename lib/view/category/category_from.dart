import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import 'package:venta_cuba/util/profile_list.dart';

import '../../Utils/funcations.dart';
import '../Chat/custom_text.dart';
import '../Navigation bar/search.dart';
import '../auth/login.dart';
import '../constants/Colors.dart';
import 'package:flutter_svg/svg.dart';

import '../frame/frame.dart';

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
        backgroundColor: AppColors.white,
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
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.black),
                    ),
                    SizedBox(height: 20..h),
                    GestureDetector(
                      onTap: () {
                        cont.selectedSubCategory=null;
                        cont.selectedSubSubCategory=null;
                        cont.listingModelList.clear();
                        cont.isSearchLoading.value = false;
                        cont.listingModelSearchList.clear();
                        cont.update();
                        cont.getListingSearch(isLoadMore: false);
                        Get.to(Search(isSearchFrom:1));
                      },
                      child: CustomText(
                        text: "View all".tr,
                        fontSize: 16.sp,
                        fontColor: Colors.green,
                      ),
                    ),
                    SizedBox(height: 20..h),
                    Expanded(
                      child: cont.subCategoriesModel!.data!.isEmpty
                          ? 
                          GridView.builder(
                              itemCount: cont.listingModelSearchList.length,
                              // physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.55.r,
                                mainAxisSpacing: 25,
                                crossAxisSpacing: 25,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                
                               
                                return GestureDetector(
                                    onTap: () {
                                      cont.isListing = 0;
                                      cont.listingModel = cont.listingModelList[index];
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const FrameScreen(),
                                          ));
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                        //  height: 280..h,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10..r),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.5),
                                                // Shadow color
                                                offset: Offset(0, 3),
                                                // Shadow offset
                                                blurRadius: 6,
                                                // Shadow blur radius
                                                spreadRadius: 0, // Shadow spread radius
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                height: 180..h,
                                                width: MediaQuery.of(context).size.width,
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(10.r),
                                                      topRight: Radius.circular(10.r)),
                                                  child: CachedNetworkImage(
                                                    height: 180..h,
                                                    width: MediaQuery.of(context).size.width,
                                                    imageUrl:cont.listingModelList[index].gallery !=null&&cont.listingModelList[index].gallery!.isNotEmpty? "${cont.listingModelList[index].gallery?.first}" : "",
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
                                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                //height: 65..h,
                                                color: Colors.white,
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      width:140.w,
                                                      child: Text(
                                                        cont.listingModelList[index].title ?? "",
                                                        maxLines: 2,
                                                        textAlign: TextAlign.center,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 17..sp,
                                                            fontWeight: FontWeight.w600,
                                                            color: Colors.black),
                                                      ),
                                                    ),
                                                    Text(
                                                      '${cont.listingModelList[index].address ?? ""}',
                                                      style: TextStyle(
                                                          fontSize: 13..sp,
                                                          fontWeight: FontWeight.w400,
                                                          color: AppColors.k0xFF403C3C),
                                                    ),
                                                    SizedBox(
                                                      height: 2..h,
                                                    ),
                                                    SelectionArea(
                                                      child: Text(
                                                        cont.listingModelList[index].price == "0"
                                                            ? " "
                                                            : '\$${cont.listingModelList[index].price}',
                                                        style: TextStyle(
                                                            fontSize: 16..sp,
                                                            fontWeight: FontWeight.w600,
                                                            color: AppColors.k0xFF0254B8),
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
                                                cont.listingModel = cont.listingModelList[index];
                                                cont.listingModelList[index].isFavorite == "0"
                                                    ? cont.listingModelList[index].isFavorite = "1"
                                                    : cont.listingModelList[index].isFavorite = "0";
                                                cont.update();
                                                bool isAddedF = await cont.favouriteItem();
                                                if (isAddedF) {
                                                  errorAlertToast("Successfully".tr);
                                                } else {
                                                  cont.listingModelList[index].isFavorite == "0"
                                                      ? cont.listingModelList[index].isFavorite = "1"
                                                      : cont.listingModelList[index].isFavorite = "0";
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
                                                color: cont.listingModelList[index].isFavorite == '0'
                                                    ? Colors.grey
                                                    : Colors.red,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ));
                              },
                            )
                          : ListView.separated(
                              itemCount: cont.subCategoriesModel?.data?.length ?? 0,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                    onTap: () {
                                      cont.selectedSubCategory = cont.subCategoriesModel?.data?[index];
                                      cont.isNavigate = true;
                                      cont.getSubSubCategories();
                                    },
                                    child: ProfileList(text: cont.subCategoriesModel?.data?[index].name ?? ""));
                              },
                              separatorBuilder: (BuildContext context, int index) {
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
