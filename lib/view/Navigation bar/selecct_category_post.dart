import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import 'package:venta_cuba/util/category_list.dart';

import '../../Models/SelectedCategoryModel.dart';

class SelectCategoriesPost extends StatefulWidget {
  const SelectCategoriesPost({super.key});

  @override
  State<SelectCategoriesPost> createState() => _SelectCategoriesPostState();
}

class _SelectCategoriesPostState extends State<SelectCategoriesPost> {
  final homeCont = Get.put(HomeController());
  @override
  void dispose() {
    homeCont.selectedSubCategory = null;
    super.dispose();
  }

  @override
  void initState() {
    homeCont.checkUserPackage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: GetBuilder(
          init: HomeController(),
          builder: (cont) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20..h,
                    ),
                    SelectionArea(
                      child: Text(
                        'Select a Category'.tr,
                        style: TextStyle(
                            fontSize: 22.sp,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color),
                      ),
                    ),
                    SizedBox(
                      height: 45..h,
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: cont.categoriesModel?.data?.length ?? 0,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              // Reset all subcategory and sub-subcategory selections when selecting a new category
                              cont.resetSubCategorySelections();

                              cont.selectedCategory =
                                  cont.categoriesModel?.data?[index];
                              cont.isNavigate = true;
                              if (cont.isType == 0) {
                                cont.selectedCategory =
                                    cont.categoriesModel?.data?[index];

                                cont.selectedCategoryModel =
                                    SelectedCategoryModel(
                                        id: cont
                                            .categoriesModel?.data?[index].id,
                                        name: cont
                                            .categoriesModel?.data?[index].name,
                                        icon: cont
                                            .categoriesModel?.data?[index].icon,
                                        type: 0);

                                cont.getSubCategoriesBottom();
                              }
                            },
                            child: CategoryList(
                                imagePath:
                                    cont.categoriesModel?.data?[index].icon ??
                                        "",
                                text: cont.categoriesModel?.data?[index].name ??
                                    ""),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return SizedBox(
                            height: 20..h,
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ));
  }
}
