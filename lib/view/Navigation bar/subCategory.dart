import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import 'package:venta_cuba/Models/SelectedCategoryModel.dart';
import 'package:venta_cuba/util/profile_list.dart';
import 'package:venta_cuba/view/Navigation%20bar/post.dart';

import '../../Utils/funcations.dart';
import '../Chat/custom_text.dart';
import '../Navigation bar/search.dart';
import '../auth/login.dart';
import '../constants/Colors.dart';
import 'package:flutter_svg/svg.dart';

import '../frame/frame.dart';

class CategoryFromBottom extends StatefulWidget {
  const CategoryFromBottom({super.key});

  @override
  State<CategoryFromBottom> createState() => _CategoryFromBottomState();
}

class _CategoryFromBottomState extends State<CategoryFromBottom> {
  final authCont = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   children: [
                      //     SvgPicture.asset(
                      //       'assets/icons/heartSimple.svg',
                      //     ),
                      //     SizedBox(
                      //       width: 20..w,
                      //     ),
                      //     SvgPicture.asset(
                      //         'assets/icons/notificationSimple.svg'),
                      //   ],
                      // ),
                    ],
                  ),
                  SizedBox(
                    height: 20..h,
                  ),
                  SelectionArea(
                    child: Text(
                      'Select a Category From'.tr,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black),
                    ),
                  ),
                  SizedBox(height: 15..h),
                  SelectionArea(
                    child: Text(
                      '${cont.selectedCategory?.name}',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black),
                    ),
                  ),
                  SizedBox(height: 20..h),
                  // Text(cont.subCategoriesModel?.data?[1].name??"N/A"),
                  Expanded(
                    child: ListView.separated(
                      itemCount: cont.isSubSubCategories
                          ? cont.subSubCategoriesModel?.data?.length ?? 0
                          : cont.subCategoriesModel?.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            onTap: () {
                              if (cont.isSubSubCategories) {
                                cont.selectedSubSubCategory =
                                    cont.subSubCategoriesModel?.data?[index];
                                cont.selectedCategoryModel = SelectedCategoryModel(
                                    id: cont.subSubCategoriesModel?.data?[index].id,
                                    name: cont.subSubCategoriesModel?.data?[index].name,
                                    icon: "",
                                    type: 2);
                                cont.isSubSubCategories = false;
                                Get.to(Post(isUpdate: false));
                              } else {

                                cont.selectedSubCategory =
                                    cont.subCategoriesModel?.data?[index];
                                cont.selectedCategoryModel = SelectedCategoryModel(
                                    id: cont.subCategoriesModel?.data?[index].id,
                                    name: cont.subCategoriesModel?.data?[index].name,
                                    icon: "",
                                    type: 1);
                                cont.getSubSubCategoriesBottom();
                              }
                            },
                            child: ProfileList(
                                text: cont.isSubSubCategories
                                    ? "${cont.subSubCategoriesModel?.data?[index].name}"
                                    : "${cont.subCategoriesModel?.data?[index].name}"));
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
    );
  }
}
