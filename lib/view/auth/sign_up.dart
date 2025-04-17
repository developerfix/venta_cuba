import 'package:country_list_pick/country_list_pick.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venta_cuba/Controllers/auth_controller.dart';
import 'package:venta_cuba/view/auth/login.dart';
import '../../Controllers/home_controller.dart';
import '../../Utils/funcations.dart';
import '../../cities_list/cites_list.dart';
import '../constants/Colors.dart';
import '../privacy_policy/privacy_policy_screen.dart';
import '../terms_of_use/terms_of_use_screen.dart';

final authControl = Get.find<AuthController>();

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String password = '';
  int strength = 0;

  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasDigits = false;
  bool hasSymbols = false;

  void checkPasswordStrength(String value) {
    hasUppercase = value.contains(RegExp(r'[A-Z]'));
    hasLowercase = value.contains(RegExp(r'[a-z]'));
    hasDigits = value.contains(RegExp(r'[0-9]'));
    hasSymbols = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    int newStrength = 0;
    if (hasUppercase) newStrength++;
    if (hasLowercase) newStrength++;
    if (hasDigits) newStrength++;
    if (hasSymbols) newStrength++;
    if (password.length >= 7) newStrength++;
    // value != null && value.isNotEmpty ? null : ""

    setState(() {
      password = value;
      strength = newStrength;
    });
  }

  Color getColor(int barIndex) {
    return barIndex < strength ? Colors.green : Colors.grey;
  }

  Widget _buildStrengthBar(int barIndex) {
    return Flexible(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 1),
        height: 3.0,
        color: getColor(barIndex),
      ),
    );
  }

  List<CustomCitiesList>? searchCity = [];
  List<CustomCitiesList>? list;
  List<CustomProvinceNameList>? searchCity1 = [];
  double height = 0;
  double height1 = 0;
  String currentText = '';
  String currentText1 = '';
  CustomProvinceNameList? dropdownvalue;
  CustomCitiesList? dropdownvalue1;
  CustomCitiesList? city;
  CustomProvinceNameList? province;
  final TextEditingController textEditingController = TextEditingController();
  HomeController homeController = Get.put(HomeController());

  var items = [
    'Apple',
    'Banana',
    'Grapes',
    'Orange',
    'watermelon',
    'Pineapple'
  ];
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    authControl.firstNameCont.clear();
    authControl.lastNameCont.clear();
    authControl.emailCreateCont.clear();
    city = null;
    province = null;
    textEditingController.clear();
    // authControl.phoneCont.clear();
    authControl.passCreateCont.clear();
    authControl.confirmPassCont.clear();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          backgroundColor: Colors.white,
          body: GetBuilder(
            init: AuthController(),
            builder: (cont) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    child: Column(
                      children: [
                        SizedBox(height: 30..h),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: Icon(Icons.arrow_back_ios),
                            ),
                          ],
                        ),
                        SizedBox(height: 30..h),
                        Image.asset(
                          "assets/images/watermark.png",
                          height: 130,
                          width: 130,
                        ),
                        SizedBox(height: 30..h),
                        Container(
                          height: 60..h,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: TextField(
                              controller: cont.firstNameCont,
                              textCapitalization: TextCapitalization.sentences,
                              textAlignVertical: TextAlignVertical.center,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.fromLTRB(0, 20, 0, 10),
                                prefixIcon: Icon(
                                  Icons.person_outline_outlined,
                                  color: Color(0xFFA9ABAC),
                                ),
                                hintText: 'Enter First Name'.tr,
                                hintStyle: TextStyle(
                                    color: Color(0xFFA9ABAC),
                                    fontWeight: FontWeight.w400),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                      // color: AppColors.textFieldColor,
                                      ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                      // color: AppColors.red,
                                      ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                      // color: AppColors.red,
                                      ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                      // color: AppColors.textFieldColor,/
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 15..h),
                        Container(
                          height: 60..h,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: TextField(
                              controller: cont.lastNameCont,
                              textCapitalization: TextCapitalization.words,
                              textAlignVertical: TextAlignVertical.center,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.fromLTRB(0, 20, 0, 10),
                                prefixIcon: Icon(
                                  Icons.person_outline_outlined,
                                  color: Color(0xFFA9ABAC),
                                ),
                                hintText: 'Enter Last Name'.tr,
                                hintStyle: TextStyle(
                                    color: Color(0xFFA9ABAC),
                                    fontWeight: FontWeight.w400),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                      // color: AppColors.textFieldColor,
                                      ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                      // color: AppColors.red,
                                      ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                      // color: AppColors.red,
                                      ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                      // color: AppColors.textFieldColor,/
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 15..h),
                        Container(
                          height: 60..h,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: TextField(
                              controller: cont.emailCreateCont,
                              textAlignVertical: TextAlignVertical.center,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        // color: AppColors.textFieldColor,
                                        ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        // color: AppColors.red,
                                        ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        // color: AppColors.red,
                                        ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        // color: AppColors.textFieldColor,/
                                        ),
                                  ),
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0, 20, 0, 10),
                                  prefixIcon: Icon(
                                    Icons.mail_outline,
                                    color: Color(0xFFA9ABAC),
                                  ),
                                  hintText: 'Enter Email Address'.tr,
                                  hintStyle: TextStyle(
                                      color: Color(0xFFA9ABAC),
                                      fontWeight: FontWeight.w400)),
                            ),
                          ),
                        ),
                        SizedBox(height: 15..h),
                        Container(
                          height: 55..h,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.not_listed_location,
                                  color: Color(0xFFA9ABAC)),
                              // SizedBox(width: 10..w),
                              Flexible(
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
                                      // padding: EdgeInsets.symmetric(horizontal: 10),
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
                                            hintText: 'Search your province'.tr,
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
                        ),
                        SizedBox(height: 15..h),
                        Container(
                          height: 55..h,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_city,
                                  color: Color(0xFFA9ABAC)),
                              Flexible(
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

                                    onChanged: (value) async {
                                      SharedPreferences share =
                                          await SharedPreferences.getInstance();
                                      setState(() {
                                        city = value;
                                        homeController.lat = city!.latitude;
                                        homeController.lng = city!.longitude;
                                        share.setString("lat", city!.latitude);
                                        share.setString("lng", city!.longitude);
                                      });
                                    },

                                    buttonStyleData: const ButtonStyleData(
                                      // padding: EdgeInsets.symmetric(horizontal: 10),
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
                                            hintText: 'Search your city'.tr,
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
                        ),
                        // Container(
                        //   height: 60..h,
                        //   width: MediaQuery.of(context).size.width,
                        //   child: Center(
                        //     child: TextField(
                        //       controller: cont.cityCont,
                        //       textAlignVertical: TextAlignVertical.center,
                        //       cursorColor: Colors.black,
                        //       decoration: InputDecoration(
                        //           focusedBorder: OutlineInputBorder(
                        //             borderRadius: BorderRadius.circular(10.0),
                        //             borderSide: BorderSide(
                        //                 // color: AppColors.textFieldColor,
                        //                 ),
                        //           ),
                        //           errorBorder: OutlineInputBorder(
                        //             borderRadius: BorderRadius.circular(10.0),
                        //             borderSide: BorderSide(
                        //                 // color: AppColors.red,
                        //                 ),
                        //           ),
                        //           focusedErrorBorder: OutlineInputBorder(
                        //             borderRadius: BorderRadius.circular(10.0),
                        //             borderSide: BorderSide(
                        //                 // color: AppColors.red,
                        //                 ),
                        //           ),
                        //           enabledBorder: OutlineInputBorder(
                        //             borderRadius: BorderRadius.circular(10.0),
                        //             borderSide: BorderSide(
                        //                 // color: AppColors.textFieldColor,/
                        //                 ),
                        //           ),
                        //           contentPadding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                        //           prefixIcon: Icon(
                        //             Icons.location_city,
                        //             color: Color(0xFFA9ABAC),
                        //           ),
                        //           hintText: 'Enter City'.tr,
                        //           hintStyle:
                        //               TextStyle(color: Color(0xFFA9ABAC), fontWeight: FontWeight.w400)),
                        //       onChanged: (value) {
                        //         searchCity = citiesList
                        //             .where((element) => element.cityName.toLowerCase().contains(value))
                        //             .toList();
                        //         setState(() {});
                        //         value.isEmpty ? searchCity?.clear() : searchCity;
                        //         value.isEmpty || searchCity?.length == 0 ? height1 = 0 : height1 = 300;
                        //         currentText = value;
                        //         print(value.length);
                        //         print(currentText.length);
                        //
                        //         setState(() {});
                        //       },
                        //     ),
                        //   ),
                        // ),
                        // Container(
                        //   height: searchCity?.length == 4
                        //       ? 200
                        //       : searchCity?.length == 3
                        //           ? 150
                        //           : searchCity?.length == 2
                        //               ? 100
                        //               : searchCity?.length == 1
                        //                   ? 40
                        //                   : height1,
                        //   margin: const EdgeInsets.only(left: 10, right: 10.0, bottom: 0),
                        //   color: Colors.white.withOpacity(0.9),
                        //   child: SingleChildScrollView(
                        //     child: Column(
                        //       children: List.generate(
                        //         searchCity?.length ?? 0,
                        //         (index) => ListTile(
                        //           title: Column(
                        //             crossAxisAlignment: CrossAxisAlignment.start,
                        //             children: [
                        //               Text(
                        //                 searchCity?.length == 0 ? "" : "${searchCity![index].cityName}",
                        //                 style: TextStyle(
                        //                   fontSize: 16.sp,
                        //                   fontWeight: FontWeight.w600,
                        //                 ),
                        //               ),
                        //               index == searchCity!.length - 1 ? SizedBox() : Divider(),
                        //             ],
                        //           ),
                        //           onTap: () async {
                        //             cont.cityCont.text = "${searchCity![index].cityName}";
                        //             FocusScope.of(context).unfocus();
                        //             setState(() {});
                        //             searchCity?.length = 0;
                        //             height1 = 0;
                        //           },
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(height: 15..h),
                        // Container(
                        //     height: 55..h,
                        //     width: MediaQuery.of(context).size.width,
                        //     decoration: BoxDecoration(
                        //         borderRadius:
                        //             BorderRadius.all(Radius.circular(10)),
                        //         border: Border.all()),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       children: [
                        //         Container(
                        //           height: 55.h,
                        //           width: 90.w,
                        //           child: CountryListPick(
                        //             pickerBuilder:
                        //                 (context, CountryCode? countryCode) {
                        //               return Row(
                        //                 mainAxisAlignment:
                        //                     MainAxisAlignment.spaceEvenly,
                        //                 crossAxisAlignment:
                        //                     CrossAxisAlignment.center,
                        //                 children: [
                        //                   Image.asset(
                        //                     countryCode!.flagUri!,
                        //                     package: 'country_list_pick',
                        //                     height: 20.h,
                        //                     width: 25.w,
                        //                   ),
                        //                   Text(
                        //                     countryCode.dialCode!,
                        //                     style: const TextStyle(
                        //                         color: Colors.black,
                        //                         fontSize: 10),
                        //                   ),
                        //                   const Icon(
                        //                     Icons.keyboard_arrow_down,
                        //                     color: Color(0xff7F8492),
                        //                     size: 18,
                        //                   )
                        //                 ],
                        //               );
                        //             },
                        //             theme: CountryTheme(
                        //                 isDownIcon: true, isShowTitle: false),
                        //             initialSelection: '+53',
                        //             onChanged: (CountryCode? code) async {
                        //               cont.countryCode = code;
                        //               SharedPreferences share =
                        //                   await SharedPreferences.getInstance();
                        //               share.setString(
                        //                   "country_code", code!.dialCode!);
                        //               cont.update();
                        //             },
                        //           ),
                        //           //
                        //         ),
                        //         Flexible(
                        //           child: TextFormField(
                        //             controller: cont.phoneCont,
                        //             cursorColor: const Color(0xff5AD6FE),
                        //             keyboardType: TextInputType.number,
                        //             decoration: InputDecoration(
                        //               border: InputBorder.none,
                        //               contentPadding: EdgeInsets.only(
                        //                   top: 4.h,
                        //                   bottom: 4.h,
                        //                   left: 15.w,
                        //                   right: 10.w),
                        //               hintText: "(525)333-1254",
                        //               hintStyle: TextStyle(
                        //                   fontFamily: "DM Sans",
                        //                   color: const Color(0xffC0C0C0),
                        //                   fontWeight: FontWeight.w400,
                        //                   fontSize: 16.sp),
                        //             ),
                        //           ),
                        //         )
                        //       ],
                        //     )),
                        SizedBox(height: 15..h),
                        Container(
                          height: 60..h,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                              child: Obx(
                            () => TextField(
                              obscureText: !cont.isPasswordVisible1.value,
                              controller: cont.passCreateCont,
                              textAlignVertical: TextAlignVertical.center,
                              cursorColor: Colors.black,
                              onChanged: (value) {
                                checkPasswordStrength(value);
                              },
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      cont.isPasswordVisible1.value
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      cont.togglePasswordVisibility1();
                                    },
                                  ),
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0, 20, 0, 10),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        // color: AppColors.textFieldColor,
                                        ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        // color: AppColors.red,
                                        ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        // color: AppColors.red,
                                        ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        // color: AppColors.textFieldColor,/
                                        ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: Color(0xFFA9ABAC),
                                  ),
                                  hintText: 'Enter Password'.tr,
                                  hintStyle: TextStyle(
                                      color: Color(0xFFA9ABAC),
                                      fontWeight: FontWeight.w400)),
                            ),
                          )),
                        ),
                        SizedBox(height: 5..h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStrengthBar(0),
                            _buildStrengthBar(1),
                            _buildStrengthBar(2),
                            _buildStrengthBar(3),
                            _buildStrengthBar(4),
                          ],
                        ),
                        SizedBox(height: 5..h),
                        Wrap(
                          spacing: 20,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 10..h,
                                  width: 10..w,
                                  decoration: BoxDecoration(
                                      color: password.length >= 8
                                          ? Colors.green
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                          width: 2,
                                          color: password.length >= 8
                                              ? Colors.green
                                              : Colors.grey)),
                                ),
                                SizedBox(width: 3),
                                Text(
                                  "at least 8 characters".tr,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                            ValidationState(
                                value: hasDigits, text: "1 number".tr),
                            ValidationState(
                                value: hasUppercase, text: "1 uppercase".tr),
                            ValidationState(
                                value: hasLowercase, text: "1 lowercase".tr),
                            ValidationState(
                                value: hasSymbols, text: "1 symbol".tr),
                          ],
                        ),
                        SizedBox(height: 5..h),
                        Container(
                          height: 60..h,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                              child: Obx(
                            () => TextField(
                              obscureText: cont.isPasswordVisible2.value,
                              controller: cont.confirmPassCont,
                              textAlignVertical: TextAlignVertical.center,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      cont.isPasswordVisible2.value
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      cont.togglePasswordVisibility2();
                                    },
                                  ),
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0, 20, 0, 10),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        // color: AppColors.textFieldColor,
                                        ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        // color: AppColors.red,
                                        ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        // color: AppColors.red,
                                        ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        // color: AppColors.textFieldColor,/
                                        ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: Color(0xFFA9ABAC),
                                  ),
                                  hintText: 'Confirm Password'.tr,
                                  hintStyle: TextStyle(
                                      color: Color(0xFFA9ABAC),
                                      fontWeight: FontWeight.w400)),
                            ),
                          )),
                        ),
                        SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(
                              () => SizedBox(
                                height: 24.0,
                                width: 24.0,
                                child: Checkbox(
                                  value: cont.isChecked.value,
                                  onChanged: (value) {
                                    cont.toggleCheckbox();
                                  },
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            SizedBox(
                              width: 270..w,
                              child: Text.rich(
                                TextSpan(
                                  text: '', // default text style
                                  children: [
                                    TextSpan(
                                      text: "I understand and agree".tr,
                                    ),
                                    TextSpan(
                                      text: 'Terms of Use'.tr,
                                      style: TextStyle(
                                          decoration: TextDecoration.underline),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => Get.to(TermsOfUse()),
                                    ),
                                    TextSpan(
                                      text: "to VentaCuba".tr,
                                    ),
                                  ],
                                ),
                              ),
                              // child: CustomText(text: "I understand and agree to VentaCuba Terms of Use".tr),
                            )
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(
                              () => SizedBox(
                                height: 24.0,
                                width: 24.0,
                                child: Checkbox(
                                  visualDensity:
                                      VisualDensity(horizontal: 0, vertical: 0),
                                  value: cont.isChecked1.value,
                                  onChanged: (value) {
                                    cont.toggleCheckbox1();
                                  },
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Padding(
                              padding: EdgeInsets.only(top: .0.h),
                              child: SizedBox(
                                width: 270..w,
                                child: Text.rich(
                                  TextSpan(
                                    text: '', // default text style
                                    children: [
                                      TextSpan(
                                        text:
                                            "I understand and agree that my personal information will be processed in according with VentaCuba's"
                                                .tr,
                                      ),
                                      TextSpan(
                                        text: ' Privacy Policy'.tr,
                                        style: TextStyle(
                                            decoration:
                                                TextDecoration.underline),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap =
                                              () => Get.to(PrivacyPolicy()),
                                      ),
                                      TextSpan(
                                        text: "to VentaCuba".tr,
                                      ),
                                      TextSpan(
                                        text: 'acknowledg'.tr,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                            onTap: () {
                              if (cont.firstNameCont.text.isEmpty) {
                                errorAlertToast("Please Enter First Name".tr);
                              } else if (cont.lastNameCont.text.isEmpty) {
                                errorAlertToast("Please Enter Last Name".tr);
                              } else if (province == null) {
                                errorAlertToast("Please Enter Province".tr);
                              } else if (city == null) {
                                errorAlertToast("Please Enter City".tr);
                              } else if (cont.emailCreateCont.text.isEmpty ||
                                  !GetUtils.isEmail(
                                      cont.emailCreateCont.text)) {
                                errorAlertToast(
                                    "Please Enter Correct Email".tr);
                              } else if (cont.passCreateCont.text.isEmpty ||
                                  cont.passCreateCont.text.length < 8 ||
                                  hasSymbols == false ||
                                  hasDigits == false ||
                                  hasUppercase == false ||
                                  hasLowercase == false) {
                                errorAlertToast(
                                    "Please Enter a Strong Password".tr);
                              } else if (cont.passCreateCont.text.isEmpty ||
                                  cont.passCreateCont.text.length < 8) {
                                errorAlertToast(
                                    "Please Enter 8 Character Password".tr);
                              } else if (cont.confirmPassCont.text.isEmpty ||
                                  cont.confirmPassCont.text.length < 8) {
                                errorAlertToast(
                                    "Please Enter 8 Character Confirm Password"
                                        .tr);
                              } else if (cont.passCreateCont.text !=
                                  cont.confirmPassCont.text) {
                                errorAlertToast("Password dose not match".tr);
                              }
                              // else if (cont.phoneCont.text.isEmpty) {
                              //   errorAlertToast(
                              //       "Please Enter Correct number".tr);
                              // }
                              else if (cont.isChecked.value == false) {
                                errorAlertToast(
                                    "Please read and accept the terms of use to proceed your signup"
                                        .tr);
                              } else if (cont.isChecked1.value == false) {
                                errorAlertToast(
                                    "Please read and accept the VentaCuba's Privacy Policy"
                                        .tr);
                              } else {
                                cont.validateEmailAndProceed(
                                    province!.provinceName, city!.cityName);
                              }
                            },
                            child: Container(
                              height: 50..h,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: AppColors.k0xFF0254B8,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Center(
                                child: Text(
                                  'Sign up'.tr,
                                  style: TextStyle(
                                      fontSize: 17..sp,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white),
                                ),
                              ),
                            )),
                        SizedBox(height: 20..h),
                        Text(
                          'Already have an account?'.tr,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.black),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Login(),
                                ));
                          },
                          child: Text(
                            'Sign in to an existing account'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
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
          )),
    );
  }
}

class ValidationState extends StatelessWidget {
  const ValidationState({
    super.key,
    required this.value,
    required this.text,
  });

  final bool value;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 10..h,
          width: 10..w,
          decoration: BoxDecoration(
              color: value ? Colors.green : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                  width: 2, color: value ? Colors.green : Colors.grey)),
        ),
        SizedBox(width: 3),
        Text(
          text.tr,
          style: TextStyle(
              fontSize: 12..sp,
              fontWeight: FontWeight.w400,
              color: Colors.grey),
        ),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Sample data for provinces and cities
  List<String> provinces = ['Province A', 'Province B', 'Province C'];
  Map<String, List<String>> cities = {
    'Province A': ['City A1', 'City A2', 'City A3'],
    'Province B': ['City B1', 'City B2', 'City B3'],
    'Province C': ['City C1', 'City C2', 'City C3'],
  };

  String selectedProvince = 'Province A';
  List<String> selectedCities = ['City A1', 'City A2', 'City A3'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dropdown Menu Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Province Dropdown
            DropdownButton<String>(
              value: selectedProvince,
              onChanged: (String? newValue) {
                setState(() {
                  selectedProvince = newValue!;
                  selectedCities = cities[selectedProvince]!;
                });
              },
              items: provinces.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20.0),

            // City Dropdown based on selected province
            DropdownButton<String>(
              value: selectedCities.first,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCities = cities[selectedProvince]!;
                });
              },
              items:
                  selectedCities.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
