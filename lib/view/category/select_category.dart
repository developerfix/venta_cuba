import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/home_controller.dart';
import 'package:venta_cuba/util/category_list.dart';
import 'package:venta_cuba/view/Chat/custom_text.dart';
import 'package:venta_cuba/view/category/category_from.dart';
import 'package:venta_cuba/view/constants/Colors.dart';
import 'package:flutter_svg/svg.dart';

class SelectCategories extends StatefulWidget {
  const SelectCategories({super.key});

  @override
  State<SelectCategories> createState() => _SelectCategoriesState();
}

class _SelectCategoriesState extends State<SelectCategories> {
  final homeCont = Get.put(HomeController());
  @override
  void dispose() {
    homeCont.selectedSubCategory = null;
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white,
        body: GetBuilder(
          init: HomeController(),
          builder: (cont) {
            return SelectionArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
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
                        'Select a Category'.tr,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.black),
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
                                cont.selectedCategory = cont.categoriesModel?.data?[index];
                                cont.isNavigate = true;
                                 if(cont.loadingSubCategory.value == false && cont.loadingCategory.value == false){
                                  cont.getSubCategories();
                                }
                                
                              },
                              child: CategoryList(
                                  imagePath: cont.categoriesModel?.data?[index].icon ?? "",
                                  text: cont.categoriesModel?.data?[index].name ?? ""),
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
              ),
            );
          },
        ));
  }
}
