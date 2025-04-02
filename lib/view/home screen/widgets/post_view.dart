import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import 'package:venta_cuba/Utils/funcations.dart';
import 'package:venta_cuba/view/auth/login.dart';
import 'package:venta_cuba/view/constants/Colors.dart';
import 'package:venta_cuba/view/frame/frame.dart';
import 'package:flutter_svg/flutter_svg.dart';
  final authCont = Get.find<AuthController>();
class ListingView extends StatelessWidget {
  const ListingView({super.key});



  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (cont) {
        return  GridView.builder(
            // controller: cont.scrollsController,
            itemCount: cont.listingModelList.length + 1,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                 crossAxisCount: 2,
                                  childAspectRatio: 0.55.r,
                                  mainAxisSpacing: 25,
                                  crossAxisSpacing: 25,
            ),
            itemBuilder: (BuildContext context, int index) {
              Get.log("has more ${cont.hasMore.value}");
              // Get.log("checking ${cont.scrollsController.position.maxScrollExtent.toString()}");
              if (index == cont.listingModelList.length) {
                return cont.hasMore.value ? Center(child: CircularProgressIndicator()) : SizedBox.shrink();
              }
              return GestureDetector(
                onTap: () {
                  cont.isListing = 0;
                  cont.listingModel = cont.listingModelList[index];
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const FrameScreen()));
                },
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            offset: Offset(0, 3),
                            blurRadius: 6,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            // height: 173.h,
                            width: MediaQuery.of(context).size.width,
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.r),
                                topRight: Radius.circular(10.r),
                              ),
                              child: CachedNetworkImage(
                                height: 180..h,
                                width: MediaQuery.of(context).size.width,
                                imageUrl: cont.listingModelList[index].gallery != null &&
                                        cont.listingModelList[index].gallery!.isNotEmpty
                                    ? "${cont.listingModelList[index].gallery?.first}"
                                    : "",
                                imageBuilder: (context, imageProvider) => Container(
                                  height: 180.h,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) => Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                errorWidget: (context, url, error) => Center(child: Text("No Image".tr)),
                              ),
                            ),
                          ),
                          Container(
                            
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 140.w,
                                  child: Text(
                                    cont.listingModelList[index].title ?? "",
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: SizedBox(
                                    height: 17.h,
                                    child: Text(
                                      '${cont.listingModelList[index].address ?? ""}',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w400, color: AppColors.k0xFF403C3C),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  cont.listingModelList[index].price == "0" ? " " : '\$${cont.listingModelList[index].price}',
                                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.k0xFF0254B8),
                                ),
                                // SizedBox(height: 5.h),
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
                            cont.listingModel = cont.listingModelList[index];
                            cont.listingModelList[index].isFavorite = cont.listingModelList[index].isFavorite == "0" ? "1" : "0";
                            cont.update();
                            bool isAddedF = await cont.favouriteItem();
                            if (!isAddedF) {
                              cont.listingModelList[index].isFavorite = cont.listingModelList[index].isFavorite == "0" ? "1" : "0";
                            }
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          height: 36.h,
                          width: 36.h,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100)),
                          child: SvgPicture.asset(
                            'assets/icons/heart1.svg',
                            color: cont.listingModelList[index].isFavorite == '0' ? Colors.grey : Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          
        );
      },
    );
  }
}
