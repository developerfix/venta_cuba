import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/cities_list/cites_list.dart';
import 'package:venta_cuba/view/constants/Colors.dart';

class DefaultLocation extends StatefulWidget {
  const DefaultLocation({super.key});

  @override
  State<DefaultLocation> createState() => _DefaultLocationState();
}

class _DefaultLocationState extends State<DefaultLocation> {
  final authCont = Get.put(AuthController());

  @override
  void initState() {
    print(authCont.user?.province);
    authCont.firstNameCont.text = authCont.user?.firstName ?? "";
    authCont.lastNameCont.text = authCont.user?.lastName ?? "";
    provinceName.forEach((element) {
      if (element.provinceName == authCont.user?.province) {
        province = element;
      }
    });
    citiesList.forEach((element) {
      if (element.cityName == authCont.user?.city) {
        city = element;
      }
    });
    super.initState();
  }

  CustomCitiesList? city;
  CustomProvinceNameList? province;
  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: GetBuilder<AuthController>(
          builder: (cont) {
            return SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
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
                          Text(
                            'Default Location'.tr,
                            style: TextStyle(
                                fontSize: 21..sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.black),
                          ),
                          Container(
                            height: 24..h,
                            width: 24..w,
                            color: Colors.transparent,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 35..h,
                      ),
                      Text(
                        'This Information will be displayed on your public business profile page'
                            .tr,
                        style: TextStyle(
                            fontSize: 17..sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.k0xFF9F9F9F),
                      ),
                      SizedBox(
                        height: 30..h,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10..h),
                          Column(
                            children: [
                              Container(
                                width: double.maxFinite,
                                height: 58..h,
                                // padding: EdgeInsets.only(left: 10),
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.black
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                        width: 1)),
                                child: DropdownButtonHideUnderline(
                                  child:
                                      DropdownButton2<CustomProvinceNameList>(
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
                                        print(
                                            ".............${province?.provinceName}");
                                      });
                                    },

                                    buttonStyleData: const ButtonStyleData(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      height: 40,
                                    ),
                                    dropdownStyleData: const DropdownStyleData(
                                        maxHeight: 600, useRootNavigator: true),
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
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 8,
                                            ),
                                            hintText: 'Search your province',
                                            hintStyle:
                                                const TextStyle(fontSize: 16),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      searchMatchFn: (item, searchValue) {
                                        return item.value
                                            .toString()
                                            .contains(searchValue);
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
                              ),
                              SizedBox(height: 10),
                              Container(
                                width: double.maxFinite,
                                height: 58..h,
                                // padding: EdgeInsets.only(left: 10),
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.black
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                        width: 1)),
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
                                        .where((element) => element.provinceName
                                            .contains(
                                                province?.provinceName ?? ""))
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
                                        // cont.lat = city!.latitude;
                                        // cont.lng = city!.longitude;
                                        // cont.addressCont.text =
                                        // "${province!.provinceName}, ${city!.cityName}";
                                      });
                                    },

                                    buttonStyleData: const ButtonStyleData(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      height: 40,
                                    ),
                                    dropdownStyleData: const DropdownStyleData(
                                        maxHeight: 600, useRootNavigator: true),
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
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 8,
                                            ),
                                            hintText: 'Search your city',
                                            hintStyle:
                                                const TextStyle(fontSize: 16),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      searchMatchFn: (item, searchValue) {
                                        return item.value
                                            .toString()
                                            .contains(searchValue);
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
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 45..h,
                      ),
                      InkWell(
                        onTap: () {
                          cont.editProfile(true,
                              city: city?.cityName,
                              province: province?.provinceName);
                        },
                        child: Container(
                          height: 60..h,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Color(0xFF0254B8),
                              borderRadius: BorderRadius.circular(10)),
                          child: Center(
                            child: Text(
                              'Save Changes'.tr,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
