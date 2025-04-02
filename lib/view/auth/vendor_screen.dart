import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/util/my_button.dart';
import 'package:venta_cuba/view/Navigation%20bar/post.dart';
import 'package:venta_cuba/view/auth/login.dart';
import 'package:venta_cuba/view/constants/Colors.dart';

import '../../Controllers/home_controller.dart';
import '../../Controllers/location_controller.dart';
import '../../Utils/funcations.dart';
import '../../cities_list/cites_list.dart';

class VendorScreen extends StatefulWidget {
  const VendorScreen({super.key});

  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  final authCont = Get.put(AuthController());
  final locationCont = Get.put(LocationController());
  final homeCont = Get.put(HomeController());

  void imagePickerOption(String imageType) {
    Get.bottomSheet(
      SingleChildScrollView(
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pick Image From'.tr,
                    style: TextStyle(fontSize: 22..h, fontWeight: FontWeight.w600, color: AppColors.black),
                  ),
                  SizedBox(
                    height: 40..h,
                  ),
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          pickImage(ImageSource.camera, imageType);
                          Get.back();
                        });
                      },
                      child: MyButton(text: 'Camera'.tr)),
                  SizedBox(
                    height: 20..h,
                  ),
                  GestureDetector(
                      onTap: () {
                        pickImage(ImageSource.gallery, imageType);
                        Get.back();
                      },
                      child: MyButton(text: 'Gallery'.tr)),
                  SizedBox(
                    height: 20..h,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      height: 60..h,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: AppColors.k0xFFA9ABAC, borderRadius: BorderRadius.circular(10)),
                      child: Center(
                        child: Text(
                          'Cancel'.tr,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  File? image;

  pickImage(ImageSource source, String imageFirst) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return;
    final imageTemp = File(image.path);
    authCont.businessLogo = imageTemp.path;
    authCont.update();
  }

  final FocusNode _focusNodeCity = FocusNode();
  final FocusNode _focusNodeProvince = FocusNode();
  final FocusNode _focusNodeAddress = FocusNode();
  void _closeKeyboard() {
    _focusNodeCity.unfocus();
    _focusNodeProvince.unfocus();
    _focusNodeAddress.unfocus();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _focusNodeProvince.dispose();
    _focusNodeCity.dispose();
    _focusNodeAddress.dispose();
    super.dispose();
  }

  final TextEditingController textEditingController = TextEditingController();

  CustomCitiesList? address;
  CustomCitiesList? city;
  CustomProvinceNameList? province;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white,
        body: GetBuilder(
          init: AuthController(),
          builder: (cont) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20..h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Icon(Icons.arrow_back_ios),
                          ),
                          Text(
                            'Complete Your Details'.tr,
                            style: TextStyle(
                                fontSize: 24..sp, fontWeight: FontWeight.w700, color: AppColors.black),
                          ),
                          Opacity(
                            opacity: 0,
                            child: Icon(Icons.arrow_back_ios),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5..h,
                      ),
                      Text(
                        'Please Complete your details to proceed Further'.tr,
                        style: TextStyle(
                            fontSize: 12..sp, fontWeight: FontWeight.w400, color: AppColors.k0xFFA9ABAC),
                      ),
                      SizedBox(
                        height: 50..h,
                      ),
                      Row(
                        children: [
                          Text(
                            'Business Name'.tr,
                            style: TextStyle(
                                fontSize: 16..sp, fontWeight: FontWeight.w500, color: AppColors.black),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 25..h,
                      ),
                      Container(
                        height: 58..h,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: AppColors.k0xFFA9ABAC.withOpacity(.33))),
                        child: TextField(
                          controller: cont.businessNameCont,
                          inputFormatters: [
                            FilteringTextInputFormatter.singleLineFormatter,
                            CapitalizeFirstLetterFormatter(),
                            LengthLimitingTextInputFormatter(60),
                          ],
                          decoration: InputDecoration(
                            hintText: "i.e NEWTECH".tr,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                          ),
                          cursorColor: AppColors.black,
                        ),
                      ),
                      // SizedBox(
                      //   height: 25..h,
                      // ),
                      // Row(
                      //   children: [
                      //     Text(
                      //       'Business Address'.tr,
                      //       style: TextStyle(
                      //           fontSize: 16..sp, fontWeight: FontWeight.w500, color: AppColors.black),
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(
                      //   height: 25..h,
                      // ),
                      // Container(
                      //     height: 58..h,
                      //     decoration: BoxDecoration(
                      //         color: Colors.transparent,
                      //         borderRadius: BorderRadius.circular(5),
                      //         border: Border.all(color: AppColors.k0xFFA9ABAC.withOpacity(.33))),
                      //     child: Center(
                      //       child: DropdownButtonHideUnderline(
                      //         child: DropdownButton2<CustomCitiesList>(
                      //           isExpanded: true,
                      //           hint: Text(
                      //             'Select city',
                      //             style: TextStyle(
                      //               fontSize: 14,
                      //               color: Theme.of(context).hintColor,
                      //             ),
                      //           ),
                      //           iconStyleData: IconStyleData(iconSize: 0),
                      //           value: city,
                      //           items: citiesList
                      //               .map((item) => DropdownMenuItem(
                      //                     value: item,
                      //                     child: Text(
                      //                       "${item.cityName} ${item.provinceName} ${item.countryName}",
                      //                       style: const TextStyle(
                      //                         fontSize: 14,
                      //                       ),
                      //                     ),
                      //                   ))
                      //               .toList(),
                      //
                      //           onChanged: (value) {
                      //             setState(() {
                      //               address = value;
                      //               // cont.lat = city!.latitude;
                      //               // cont.lng = city!.longitude;
                      //               // city?.cityName = "${selectedValue1!.cityName}";
                      //               // print(".............${cont.addressCont.text}");
                      //             });
                      //           },
                      //
                      //           buttonStyleData: const ButtonStyleData(
                      //             padding: EdgeInsets.symmetric(horizontal: 10),
                      //             height: 40,
                      //           ),
                      //           dropdownStyleData:
                      //               const DropdownStyleData(maxHeight: 600, useRootNavigator: true),
                      //           menuItemStyleData: const MenuItemStyleData(
                      //             height: 40,
                      //           ),
                      //           dropdownSearchData: DropdownSearchData(
                      //             searchController: textEditingController,
                      //             searchInnerWidgetHeight: 50,
                      //             searchInnerWidget: Container(
                      //               height: 50,
                      //               padding: const EdgeInsets.only(
                      //                 top: 8,
                      //                 bottom: 4,
                      //                 right: 8,
                      //                 left: 8,
                      //               ),
                      //               child: TextFormField(
                      //                 controller: textEditingController,
                      //                 decoration: InputDecoration(
                      //                   // isDense: true,
                      //                   contentPadding: const EdgeInsets.symmetric(
                      //                     horizontal: 10,
                      //                     vertical: 8,
                      //                   ),
                      //                   hintText: 'Search your city',
                      //                   hintStyle: const TextStyle(fontSize: 16),
                      //                   border: OutlineInputBorder(
                      //                     borderRadius: BorderRadius.circular(8),
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //             searchMatchFn: (item, searchValue) {
                      //               return item.value.toString().contains(searchValue);
                      //             },
                      //           ),
                      //           //This to clear the search value when you close the menu
                      //           onMenuStateChange: (isOpen) {
                      //             if (!isOpen) {
                      //               textEditingController.clear();
                      //             }
                      //           },
                      //         ),
                      //       ),
                      //     )),
                      // Stack(
                      //   children: [
                      //     Obx(
                      //       () => Container(
                      //         margin: const EdgeInsets.only(left: 10, right: 90.0, bottom: 0),
                      //         color: Colors.white.withOpacity(0.9),
                      //         child: Visibility(
                      //           visible: locationCont.isTextFiled == 3 &&
                      //               locationCont.showOrHideLocationsList.value,
                      //           child: SingleChildScrollView(
                      //             child: Column(
                      //               children: List.generate(
                      //                 locationCont.placeList.length,
                      //                 (index) => ListTile(
                      //                   title: Text(
                      //                     locationCont.placeList[index]["description"],
                      //                     style: TextStyle(
                      //                       fontSize: 16.sp,
                      //                       fontWeight: FontWeight.w600,
                      //                     ),
                      //                   ),
                      //                   onTap: () async {
                      //                     locationCont.selectLocation(index);
                      //                     _closeKeyboard();
                      //                   },
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      SizedBox(
                        height: 25..h,
                      ),
                      Row(
                        children: [
                          Text(
                            'Business Province'.tr,
                            style: TextStyle(
                                fontSize: 16..sp, fontWeight: FontWeight.w500, color: AppColors.black),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 25..h,
                      ),
                      Container(
                          height: 58..h,
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: AppColors.k0xFFA9ABAC.withOpacity(.33))),
                          child: Center(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2<CustomProvinceNameList>(
                                isExpanded: true,
                                hint: Text(
                                  'Select province'.tr,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                                iconStyleData: IconStyleData(iconSize: 0),
                                items: provinceName
                                    .map((item) => DropdownMenuItem(
                                          value: item,
                                          child: Text(
                                            "${item.provinceName}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                value: province,
                                onChanged: (value) {
                                  setState(() {
                                    if (city != null) {
                                      city = null;
                                      province = value;
                                    } else {
                                      province = value;
                                    }
                                    // province?.provinceName = "${selectedValue!.provinceName}";
                                    print(".............${province?.provinceName}");
                                  });
                                },

                                buttonStyleData: const ButtonStyleData(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  height: 40,
                                ),
                                dropdownStyleData:
                                    const DropdownStyleData(maxHeight: 600, useRootNavigator: true),
                                menuItemStyleData: const MenuItemStyleData(
                                  height: 40,
                                ),
                                dropdownSearchData: DropdownSearchData(
                                  searchController: textEditingController,
                                  searchInnerWidgetHeight: 50,
                                  searchInnerWidget: Container(
                                    height: 50,
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                      bottom: 4,
                                      right: 8,
                                      left: 8,
                                    ),
                                    child: TextFormField(
                                      // expands: true,
                                      // maxLines: null,
                                      controller: textEditingController,
                                      decoration: InputDecoration(
                                        // isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                        hintText: 'Search your province'.tr,
                                        hintStyle: const TextStyle(fontSize: 16),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  searchMatchFn: (item, searchValue) {
                                    return item.value.toString().contains(searchValue);
                                  },
                                ),
                                //This to clear the search value when you close the menu
                                onMenuStateChange: (isOpen) {
                                  if (!isOpen) {
                                    textEditingController.clear();
                                  }
                                },
                              ),
                            ),
                          )),
                      // Stack(
                      //   children: [
                      //     Obx(
                      //       () => Container(
                      //         margin: const EdgeInsets.only(left: 10, right: 90.0, bottom: 0),
                      //         color: Colors.white.withOpacity(0.9),
                      //         child: Visibility(
                      //           visible: locationCont.isTextFiled == 2 &&
                      //               locationCont.showOrHideLocationsList.value,
                      //           child: SingleChildScrollView(
                      //             child: Column(
                      //               children: List.generate(
                      //                 locationCont.placeList.length,
                      //                 (index) => ListTile(
                      //                   title: Text(
                      //                     locationCont.placeList[index]["description"],
                      //                     style: TextStyle(
                      //                       fontSize: 16.sp,
                      //                       fontWeight: FontWeight.w600,
                      //                     ),
                      //                   ),
                      //                   onTap: () async {
                      //                     locationCont.selectLocation(index);
                      //                     _closeKeyboard();
                      //                   },
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      SizedBox(height: 25..h),
                      Row(
                        children: [
                          Text(
                            'Business City'.tr,
                            style: TextStyle(
                                fontSize: 16..sp, fontWeight: FontWeight.w500, color: AppColors.black),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 25..h,
                      ),
                      Container(
                          height: 58..h,
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: AppColors.k0xFFA9ABAC.withOpacity(.33))),
                          child: Center(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2<CustomCitiesList>(
                                isExpanded: true,
                                hint: Text(
                                  'Select city'.tr,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                                iconStyleData: IconStyleData(iconSize: 0),
                                value: city,
                                items: citiesList
                                    .where((element) =>
                                        element.provinceName.contains(province?.provinceName ?? ""))
                                    .map((item) => DropdownMenuItem(
                                          value: item,
                                          child: Text(
                                            "${item.cityName}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ))
                                    .toList(),

                                onChanged: (value) {
                                  setState(() {
                                    city = value;
                                    homeCont.lat = city!.latitude;
                                    homeCont.lng = city!.longitude;
                                    // city?.cityName = "${selectedValue1!.cityName}";
                                    // print(".............${cont.addressCont.text}");
                                  });
                                },

                                buttonStyleData: const ButtonStyleData(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  height: 40,
                                ),
                                dropdownStyleData:
                                    const DropdownStyleData(maxHeight: 600, useRootNavigator: true),
                                menuItemStyleData: const MenuItemStyleData(
                                  height: 40,
                                ),
                                dropdownSearchData: DropdownSearchData(
                                  searchController: textEditingController,
                                  searchInnerWidgetHeight: 50,
                                  searchInnerWidget: Container(
                                    height: 50,
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                      bottom: 4,
                                      right: 8,
                                      left: 8,
                                    ),
                                    child: TextFormField(
                                      controller: textEditingController,
                                      decoration: InputDecoration(
                                        // isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                        hintText: 'Search your city'.tr,
                                        hintStyle: const TextStyle(fontSize: 16),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  searchMatchFn: (item, searchValue) {
                                    return item.value.toString().contains(searchValue);
                                  },
                                ),
                                //This to clear the search value when you close the menu
                                onMenuStateChange: (isOpen) {
                                  if (!isOpen) {
                                    textEditingController.clear();
                                  }
                                },
                              ),
                            ),
                          )),
                      // Stack(
                      //   children: [
                      //     Obx(
                      //       () => Container(
                      //         margin: const EdgeInsets.only(left: 10, right: 90.0, bottom: 0),
                      //         color: Colors.white.withOpacity(0.9),
                      //         child: Visibility(
                      //           visible: locationCont.isTextFiled == 1 &&
                      //               locationCont.showOrHideLocationsList.value,
                      //           child: SingleChildScrollView(
                      //             child: Column(
                      //               children: List.generate(
                      //                 locationCont.placeList.length,
                      //                 (index) => ListTile(
                      //                   title: Text(
                      //                     locationCont.placeList[index]["description"],
                      //                     style: TextStyle(
                      //                       fontSize: 16.sp,
                      //                       fontWeight: FontWeight.w600,
                      //                     ),
                      //                   ),
                      //                   onTap: () async {
                      //                     locationCont.selectLocation(index);
                      //                     _closeKeyboard();
                      //                   },
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      SizedBox(
                        height: 25..h,
                      ),
                      SizedBox(
                        height: 25..h,
                      ),
                      Row(
                        children: [
                          Text(
                            'Business Logo'.tr,
                            style: TextStyle(
                                fontSize: 16..sp, fontWeight: FontWeight.w500, color: AppColors.black),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 25..h,
                      ),
                      GestureDetector(
                        onTap: () => pickImage(ImageSource.gallery, ""),
                        // imagePickerOption('image'),
                        child: Container(
                          height: 165..h,
                          width: MediaQuery.of(context).size.width,
                          child: DottedBorder(
                              borderType: BorderType.RRect,
                              color: AppColors.k0xFFC4C4C4,
                              // Border color
                              strokeWidth: 1,
                              // Border width
                              radius: Radius.circular(10),
                              child: Container(
                                child: Center(
                                  child: cont.businessLogo != null
                                      ? Container(
                                          width: MediaQuery.of(context).size.width,
                                          child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.file(File(cont.businessLogo ?? ""),)),
                                        )
                                      : Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Image.asset('assets/images/upload.png'),
                                            Text(
                                              'Upload Your Image Here'.tr,
                                              style: TextStyle(
                                                  fontSize: 13..sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.black),
                                            ),
                                            Text(
                                              'Maximum 50mb Size'.tr,
                                              style: TextStyle(
                                                  fontSize: 10..sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: AppColors.k0xFFA9ABAC),
                                            ),
                                          ],
                                        ),
                                ),
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 45..h,
                      ),
                      GestureDetector(
                          onTap: () {
                            if (cont.businessNameCont.text.isEmpty) {
                              errorAlertToast("Please Enter Business Name".tr);
                            } else if (city == null) {
                              errorAlertToast("Please Enter Business City".tr);
                            } else if (province == null) {
                              errorAlertToast("Please Enter Business Province".tr);
                            } else {
                              cont.addBusiness(province!.provinceName, city!.cityName);
                            }
                          },
                          child: MyButton(text: 'Add Business'.tr)),
                      SizedBox(
                        height: 45..h,
                      ),
                      Text(
                        'Already have an account?'.tr,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.offAll(Login());
                        },
                        child: Text(
                          'Sign in to an existing account'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0254B8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }
}
